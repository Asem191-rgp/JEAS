import 'package:flutter/material.dart';

class PasswordField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final String hint;

  const PasswordField(this.label, this.controller, this.hint, {super.key});

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 7, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: const TextStyle(
              fontFamily: 'TiffanyHeavy',
              fontSize: 10,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            obscureText: _obscureText,
            controller: widget.controller,
            style: const TextStyle(color: Colors.black),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: const TextStyle(
                color: Colors.grey,
                fontFamily: 'TiffanyHeavy',
                fontSize: 8,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: Colors.lightBlue),
              ),
              filled: true,
              fillColor: Colors.white30,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              suffixIcon: IconButton(
                icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Please don't leave the field empty!";
              }
              RegExp reg = RegExp(r'[!@#%^&*$-_(),.?":{}|<>]');
              RegExp r = RegExp(r'[0-9]');
              RegExp re = RegExp(r'[a-z]');
              if (!value.contains(reg)) {
                return "please make password more complex\n by adding symbols and Numbers";
              }
              if (!value.contains(r)) {
                return "please make password more complex\n by adding symbols and Numbers";
              }
              if (!value.contains(re)) {
                return "please add at least one alphabet";
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}
