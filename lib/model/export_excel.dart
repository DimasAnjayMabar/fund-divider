import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:fund_divider/model/hive.dart';

class ExcelExport {
  static Future<Map<String, dynamic>> exportExpensesToExcel(List<Expenses> expenses) async {
    return await exportToCSV(expenses);
  }

  // Buat CSV dengan format yang benar - TANPA AUTO OPEN
  static Future<Map<String, dynamic>> exportToCSV(List<Expenses> expenses) async {
    try {
      if (expenses.isEmpty) {
        throw Exception('No expenses to export');
      }
      
      print('📊 Creating CSV file for ${expenses.length} expenses...');
      
      // Sort by date (newest first)
      final sortedExpenses = List<Expenses>.from(expenses)
        ..sort((a, b) => b.date_added.compareTo(a.date_added));
      
      // 1. BUAT CSV CONTENT
      final csvContent = _createFormattedCSV(sortedExpenses);
      
      // 2. GENERATE FILENAME
      final fileName = 'expenses_${DateFormat('yyyy_MM_dd_HHmm').format(DateTime.now())}.csv';
      
      // 3. SIMPAN FILE - HANYA SIMPAN, TIDAK BUKA!
      final downloadPath = '/storage/emulated/0/Download';
      final downloadDir = Directory(downloadPath);
      
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }
      
      final filePath = '$downloadPath/$fileName';
      final file = File(filePath);
      
      // Tulis file
      await file.writeAsString(csvContent, flush: true, encoding: utf8);
      
      // Sync ke disk
      final raf = await file.open(mode: FileMode.append);
      await raf.flush();
      await raf.close();
      
      // Verifikasi file tersimpan
      if (!await file.exists()) {
        throw Exception('File was not created');
      }
      
      final fileSize = await file.length();
      
      print('✅ File saved: $filePath ($fileSize bytes)');
      
      // RETURN TANPA MEMBUKA FILE
      return {
        'success': true,
        'filePath': filePath,
        'fileName': fileName,
        'message': 'File exported successfully',
        'fileSize': fileSize,
      };
      
    } catch (e) {
      print('❌ Export error: $e');
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Failed to export CSV file',
      };
    }
  }
  
  // Buat CSV dengan format Rp yang benar
  static String _createFormattedCSV(List<Expenses> expenses) {
    final lines = <String>[];
    
    // HEADER dengan format yang Excel-friendly
    lines.add('No,Description,Amount,Date,Time,Category');
    
    // Format untuk display
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    final dateFormat = DateFormat('dd-MMM-yyyy');
    final timeFormat = DateFormat('HH:mm');
    
    double totalAmount = 0;
    
    // DATA ROWS
    for (int i = 0; i < expenses.length; i++) {
      final expense = expenses[i];
      totalAmount += expense.amount;
      
      // Format amount dengan Rp
      String formattedAmount = currencyFormat.format(expense.amount);
      // Tambahkan spasi setelah Rp
      if (formattedAmount.startsWith('Rp')) {
        formattedAmount = 'Rp ${formattedAmount.substring(2).trim()}';
      }
      
      // Format date dan time
      final date = dateFormat.format(expense.date_added);
      final time = timeFormat.format(expense.date_added);
      
      // Tambahkan baris (semua field dalam quotes untuk keamanan)
      lines.add('"${i + 1}","${_escapeCSV(expense.description)}","${_escapeCSV(formattedAmount)}","$date","$time","Expense"');
    }
    
    // SUMMARY SECTION
    lines.add(''); // Baris kosong
    lines.add('"SUMMARY","","","","",""');
    lines.add('"Total Expenses","${expenses.length}","","","",""');
    final totalFormatted = currencyFormat.format(totalAmount).replaceAll('Rp', 'Rp ');
    lines.add('"Total Amount","${_escapeCSV(totalFormatted)}","","","",""');
    final avgFormatted = currencyFormat.format(totalAmount / expenses.length).replaceAll('Rp', 'Rp ');
    lines.add('"Average Amount","${_escapeCSV(avgFormatted)}","","","",""');
    lines.add('"Exported Date","${DateFormat('dd-MMM-yyyy HH:mm').format(DateTime.now())}","","","",""');
    
    // Gunakan Windows line endings untuk kompatibilitas
    return lines.join('\r\n');
  }
  
  // Helper untuk escape CSV
  static String _escapeCSV(String text) {
    if (text.isEmpty) return '';
    // Ganti double quotes dengan dua double quotes (CSV standard)
    return text.replaceAll('"', '""');
  }
  
  // Helper untuk mendapatkan informasi file
  static Future<String> getFileInfo(String filePath) async {
    try {
      final file = File(filePath);
      final exists = await file.exists();
      final size = await file.length();
      final modified = await file.lastModified();
      
      return 'File: ${file.path}\n'
             'Exists: $exists\n'
             'Size: $size bytes\n'
             'Modified: ${DateFormat('dd-MMM-yyyy HH:mm:ss').format(modified)}';
    } catch (e) {
      return 'Cannot get file info: $e';
    }
  }
}