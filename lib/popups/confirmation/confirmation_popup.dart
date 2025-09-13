import 'package:flutter/material.dart';

class ConfirmationPopup extends StatelessWidget {
  final String errorMessage;
  final String title;
  final VoidCallback onConfirm;

  const ConfirmationPopup({
    super.key, 
    required this.errorMessage, 
    required this.title, 
    required this.onConfirm
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Colors.white, width: 1)
      ),
      title: Text(title, style: const TextStyle(color: Colors.yellow)), 
      content: Text(errorMessage, style: const TextStyle(color: Colors.yellow)),
      actions: [
        ElevatedButton(
          style: TextButton.styleFrom(
            backgroundColor: Colors.yellow,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text(
            "Cancel",
            style: TextStyle(color: Colors.black),
          ),
        ),
        ElevatedButton(
          style: TextButton.styleFrom(
            backgroundColor: Colors.yellow,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {
            onConfirm();
            Navigator.of(context).pop(true); // Return true untuk konfirmasi
          },
          child: const Text(
            "Yes",
            style: TextStyle(color: Colors.black),
          ),
        ),
      ],
    );
  }
}