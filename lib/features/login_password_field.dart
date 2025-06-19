import 'package:flutter/material.dart';

class LoginPasswordTextField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final bool pass;

  const LoginPasswordTextField(
      this.label, this.controller, this.hint, this.pass,
      {super.key});

  @override
  State<LoginPasswordTextField> createState() => _LoginPasswordTextFieldState();
}

class _LoginPasswordTextFieldState extends State<LoginPasswordTextField> {
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
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            obscureText: widget.pass ? _obscureText : false,
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
              suffixIcon: widget.pass
                  ? IconButton(
                      icon: Icon(_obscureText
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    )
                  : null,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Please don't leave the field empty!";
              }
              return null;
            },
            onChanged: (value) {
              widget.controller.text = value;
            },
          ),
        ],
      ),
    );
  }
}
