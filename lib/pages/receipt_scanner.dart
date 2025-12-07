// [file name]: receipt_scanner.dart (UPDATE)
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:fund_divider/popups/error/error.dart';
import 'package:fund_divider/storage/money_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:fund_divider/model/hive.dart';
import 'package:fund_divider/model/error_handler.dart';
import 'package:intl/intl.dart';

class ReceiptScanner extends StatefulWidget {
  const ReceiptScanner({super.key});

  @override
  State<ReceiptScanner> createState() => _ReceiptScannerState();
}

class _ReceiptScannerState extends State<ReceiptScanner> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraReady = false;
  bool _isProcessing = false;
  bool _showCamera = true;
  File? _capturedImage;
  Map<String, dynamic>? _processingResult;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        // Gunakan kamera belakang jika ada
        final backCamera = _cameras!.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.back,
          orElse: () => _cameras!.first,
        );
        
        _cameraController = CameraController(
          backCamera,
          ResolutionPreset.high,
          enableAudio: false,
        );

        await _cameraController!.initialize();
        if (mounted) {
          setState(() {
            _isCameraReady = true;
          });
        }
      } else {
        // Tidak ada kamera yang tersedia
        _showCameraError('No camera available on this device');
      }
    } catch (e) {
      _showCameraError('Failed to initialize camera: ${e.toString()}');
    }
  }

  void _showCameraError(String message) {
    if (mounted) {
      // Show error modal
      showDialog(
        context: context,
        builder: (context) => ErrorPopup(errorMessage: message),
      );
      
      // Log ke console
      ErrorHandler.showError(message);
    }
  }

  Future<void> _captureImage() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      _showErrorModal('Camera is not ready. Please try again.');
      return;
    }

    try {
      setState(() {
        _isProcessing = true;
      });

      final XFile imageFile = await _cameraController!.takePicture();
      final File image = File(imageFile.path);
      
      // Crop image jika diperlukan
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: image.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1.4),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Receipt',
            toolbarColor: Colors.black,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
          IOSUiSettings(
            title: 'Crop Receipt',
          ),
        ],
      );

      if (croppedFile != null) {
        await _processImage(File(croppedFile.path));
      } else {
        await _processImage(image);
      }
    } catch (e) {
      _showErrorModal('Failed to capture image: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _isProcessing = true;
        });

        // Crop image
        final croppedFile = await ImageCropper().cropImage(
          sourcePath: image.path,
          aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1.4),
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Crop Receipt',
              toolbarColor: Colors.black,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false,
            ),
            IOSUiSettings(
              title: 'Crop Receipt',
            ),
          ],
        );

        if (croppedFile != null) {
          await _processImage(File(croppedFile.path));
        } else {
          await _processImage(File(image.path));
        }
      }
    } catch (e) {
      _showErrorModal('Failed to pick image: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _processImage(File imageFile) async {
    try {
      setState(() {
        _capturedImage = imageFile;
        _showCamera = false;
      });

      // Process receipt menggunakan WalletService
      final result = await WalletService.processReceiptImage(imageFile);
      
      if (mounted) {
        setState(() {
          _processingResult = result;
        });
        
        if (result['success'] == true) {
          _showSuccessDialog(result);
        } else {
          _showErrorModal(result['error'] ?? 'Failed to process receipt');
        }
      }
    } catch (e) {
      _showErrorModal('Processing error: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _showSuccessDialog(Map<String, dynamic> result) {
    final NumberFormat currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Receipt Processed Successfully'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Store: ${result['store_name']}'),
            const SizedBox(height: 8),
            Text('Amount: ${currencyFormatter.format(result['amount'])}'),
            const SizedBox(height: 8),
            Text('Description: ${result['description']}'),
            const SizedBox(height: 8),
            Text('Items detected: ${result['items_count']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetScanner();
            },
            child: const Text('OK'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Tampilkan detail teks
              _showRawText(result['raw_text']);
            },
            child: const Text('Show Details'),
          ),
        ],
      ),
    );
  }

  void _showRawText(String rawText) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Extracted Text'),
        content: SingleChildScrollView(
          child: Text(
            rawText,
            style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetScanner();
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showErrorModal(String message) {
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => ErrorPopup(errorMessage: message),
      );
      
      // Juga log ke console untuk debugging
      ErrorHandler.showError(message);
    }
  }

  void _resetScanner() {
    if (mounted) {
      setState(() {
        _capturedImage = null;
        _processingResult = null;
        _showCamera = true;
      });
    }
  }

  Widget _buildCameraPreview() {
    if (!_isCameraReady || _cameraController == null) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text(
                'Initializing camera...',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      );
    }

    return CameraPreview(_cameraController!);
  }

  Widget _buildCapturedImage() {
    if (_capturedImage == null) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Text('No image captured', style: TextStyle(color: Colors.white)),
        ),
      );
    }

    return Image.file(_capturedImage!, fit: BoxFit.contain);
  }

  Widget _buildProcessingOverlay() {
    if (!_isProcessing) return const SizedBox.shrink();

    return Container(
      color: Colors.black.withOpacity(0.7),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Processing receipt...\nPlease wait',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Scan Receipt'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.photo_library),
            onPressed: _pickImageFromGallery,
            tooltip: 'Pick from gallery',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera preview atau captured image
          if (_showCamera)
            _buildCameraPreview()
          else
            _buildCapturedImage(),
          
          // Processing overlay
          _buildProcessingOverlay(),
          
          // Capture button (hanya muncul saat camera aktif)
          if (_showCamera && !_isProcessing)
            Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              child: Center(
                child: FloatingActionButton(
                  onPressed: _captureImage,
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.camera_alt, color: Colors.black, size: 30),
                ),
              ),
            ),
          
          // Back button untuk kembali ke camera
          if (!_showCamera && !_isProcessing)
            Positioned(
              top: 20,
              left: 20,
              child: FloatingActionButton.small(
                onPressed: _resetScanner,
                backgroundColor: Colors.black.withOpacity(0.5),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}