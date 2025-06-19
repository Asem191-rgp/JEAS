import 'package:flutter/material.dart';

class LoginTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final bool pass;
  const LoginTextField(this.label, this.controller, this.hint, this.pass,
      {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 7, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'TiffanyHeavy',
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            obscureText: pass,
            controller: controller,
            style: const TextStyle(color: Colors.black),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: Colors.grey,
                fontFamily: 'TiffanyHeavy',
                fontSize: 8,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.lightBlue),
              ),
              filled: true,
              fillColor: Colors.white30,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "please dont leave the field empty!";
              }
              return null;
            },
            onChanged: (value) {
              controller.text = value.replaceAll(" ", "");
            },
          ),
        ],
      ),
    );
  }
}
