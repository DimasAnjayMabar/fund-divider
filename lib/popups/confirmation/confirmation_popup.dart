import 'package:flutter/material.dart';

class ConfirmationPopup extends StatelessWidget {
  final String errorMessage;
  final String title;
  final VoidCallback onConfirm;
  final Color? primaryColor;
  final Color? backgroundColor;
  final Color? textColor;

  const ConfirmationPopup({
    super.key, 
    required this.errorMessage, 
    required this.title, 
    required this.onConfirm,
    this.primaryColor,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    // Menggunakan warna dari tema aplikasi atau custom
    final themePrimaryColor = primaryColor ?? const Color(0xff6F41F2);
    final themeBackgroundColor = backgroundColor ?? Colors.white;
    final themeTextColor = textColor ?? Colors.black;
    final themeSecondaryColor = themePrimaryColor.withOpacity(0.1);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: themeBackgroundColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: themeSecondaryColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                color: themePrimaryColor,
                size: 36,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Title
            Text(
              title,
              style: TextStyle(
                color: themeTextColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 12),
            
            // Message
            Text(
              errorMessage,
              style: TextStyle(
                color: Colors.black54,
                fontSize: 15,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 24),
            
            // Buttons Row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Cancel Button
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(
                        color: themePrimaryColor.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      "Cancel",
                      style: TextStyle(
                        color: themePrimaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Confirm Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      onConfirm();
                      Navigator.of(context).pop(true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themePrimaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                      shadowColor: Colors.transparent,
                    ),
                    child: Text(
                      "Confirm",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
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