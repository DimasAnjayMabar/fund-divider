import 'package:flutter/material.dart';
import 'package:fund_divider/error_popup.dart/error_handler.dart';

class ErrorPopup extends StatelessWidget {
  final String errorMessage;

  const ErrorPopup({super.key, required this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Colors.white, width: 1)
      ),
      title: const Text("Warning", style: TextStyle(color: Colors.yellow),), 
      content: Text(errorMessage, style: TextStyle(color: Colors.yellow),),
      actions: [
         ElevatedButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.yellow,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                "OK",
                style: TextStyle(color: Colors.black),
              ),
            ),
      ],
    );
  }
}
