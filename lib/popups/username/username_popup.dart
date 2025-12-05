import 'package:flutter/material.dart';
import 'package:fund_divider/storage/money_storage.dart';

class SaveUsername extends StatefulWidget {
  final bool isEditMode;
  final Color? primaryColor;
  final Color? backgroundColor;
  
  const SaveUsername({
    super.key, 
    this.isEditMode = false,
    this.primaryColor,
    this.backgroundColor,
  });

  @override
  State<SaveUsername> createState() => _SaveUsernameState();
}

class _SaveUsernameState extends State<SaveUsername> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadExistingUsername();
  }

  void _loadExistingUsername() {
    if (WalletService.hasUsername()) {
      final existingUsername = WalletService.getUsername();
      _usernameController.text = existingUsername;
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);
      final username = _usernameController.text.trim();
      
      try {
        await WalletService.saveUsername(username);
        
        if (mounted) {
          Navigator.pop(context, username);
          
          // Tampilkan snackbar sukses
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.isEditMode 
                  ? 'Username updated to "$username"!'
                  : 'Welcome, $username!',
              ),
              backgroundColor: _getPrimaryColor(),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving username: $e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
    }
  }

  Color _getPrimaryColor() {
    return widget.primaryColor ?? const Color(0xff6F41F2);
  }

  Color _getBackgroundColor() {
    return widget.backgroundColor ?? Colors.white;
  }

  Color _getTextColor() {
    return widget.backgroundColor == Colors.black ? Colors.white : Colors.black;
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = _getPrimaryColor();
    final backgroundColor = _getBackgroundColor();
    final textColor = _getTextColor();
    final isDarkTheme = backgroundColor == Colors.black;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
          border: isDarkTheme
              ? Border.all(color: Colors.white.withOpacity(0.2), width: 1)
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header dengan icon
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    widget.isEditMode 
                        ? Icons.person_outline_rounded 
                        : Icons.person_add_alt_1_rounded,
                    color: primaryColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.isEditMode ? "Change Username" : "Create Username",
                        style: TextStyle(
                          color: textColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.isEditMode 
                            ? "Update your display name"
                            : "Set up your profile",
                        style: TextStyle(
                          color: textColor.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Form
            Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Username",
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Text Field
                  TextFormField(
                    controller: _usernameController,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: isDarkTheme 
                          ? Colors.grey[900] 
                          : Colors.grey[50],
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: primaryColor.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: primaryColor,
                          width: 2,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.red,
                          width: 1.5,
                        ),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.red,
                          width: 2,
                        ),
                      ),
                      hintText: "Enter your username",
                      hintStyle: TextStyle(
                        color: textColor.withOpacity(0.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      prefixIcon: Icon(
                        Icons.person_rounded,
                        color: primaryColor.withOpacity(0.7),
                      ),
                      suffixIcon: _usernameController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.clear,
                                color: primaryColor.withOpacity(0.5),
                              ),
                              onPressed: () {
                                _usernameController.clear();
                                setState(() {});
                              },
                            )
                          : null,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Username is required";
                      }
                      if (value.trim().length < 2) {
                        return "Username must be at least 2 characters";
                      }
                      if (value.trim().length > 20) {
                        return "Username is too long (max 20 characters)";
                      }
                      if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value.trim())) {
                        return "Only letters, numbers and underscore allowed";
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {});
                    },
                    autofocus: true,
                    textCapitalization: TextCapitalization.words,
                  ),
                  
                  // Character count
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        "${_usernameController.text.length}/20",
                        style: TextStyle(
                          color: _usernameController.text.length > 20 
                              ? Colors.red 
                              : textColor.withOpacity(0.5),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Cancel Button
                OutlinedButton(
                  onPressed: _isSubmitting 
                      ? null 
                      : () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(
                      color: primaryColor.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Save Button
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                    shadowColor: Colors.transparent,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : Text(
                          widget.isEditMode ? "Update" : "Save",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}