import 'package:flutter/material.dart';
import 'package:fund_divider/storage/money_storage.dart';

class SaveUsername extends StatefulWidget {
  final bool isEditMode;
  
  const SaveUsername({super.key, this.isEditMode = false});

  @override
  State<SaveUsername> createState() => _SaveUsernameState();
}

class _SaveUsernameState extends State<SaveUsername> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();

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
      final username = _usernameController.text.trim();
      
      try {
        await WalletService.saveUsername(username);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Username changed to "$username" successfully!'
              ),
              backgroundColor: Colors.green,
            ),
          );
          
          Navigator.pop(context, username);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving username: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Colors.white, width: 1)
      ),
      title: const Text(
        "Enter a username",
        style: TextStyle(
          color: Colors.yellow,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Label
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Username",
                style: TextStyle(color: Colors.yellow),
              ),
            ),
            const SizedBox(height: 8),
            // Username Text Field
            TextFormField(
              controller: _usernameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[900],
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.yellow),
                ),
                hintText: "Enter your username",
                hintStyle: const TextStyle(color: Colors.grey),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Username required";
                }
                if (value.trim().length < 2) {
                  return "Username must be at least 2 characters";
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Cancel Button
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
                "Cancel",
                style: TextStyle(color: Colors.black),
              ),
            ),
            const SizedBox(width: 10),

            // Save Button
            ElevatedButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.yellow,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: _submit,
              child: const Text(
                "Save",
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ],
    );
  }
}