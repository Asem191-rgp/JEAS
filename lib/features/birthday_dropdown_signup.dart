import 'package:flutter/material.dart';

class DateField extends StatelessWidget {
  final TextEditingController dateController;

  const DateField({super.key, required this.dateController});

  @override
  Widget build(BuildContext context) {
    return DateFieldWidget(dateController: dateController);
  }
}

class DateFieldWidget extends StatefulWidget {
  final TextEditingController dateController;

  const DateFieldWidget({super.key, required this.dateController});

  @override
  State<DateFieldWidget> createState() => _DateFieldWidgetState();
}

class _DateFieldWidgetState extends State<DateFieldWidget> {
  String hiText = "Select Your Birthday";

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      barrierColor: Colors.white,
      context: context,
      initialDate: DateTime(2006),
      firstDate: DateTime(1900),
      lastDate: DateTime(2006),
    );

    if (picked != null) {
      setState(() {
        widget.dateController.text =
            "${picked.year}-${picked.month}-${picked.day}";
        hiText = "${picked.year}-${picked.month}-${picked.day}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 7, horizontal: 20),
      child: TextFormField(
        controller: widget.dateController,
        readOnly: true,
        onTap: () => _selectDate(context),
        decoration: InputDecoration(
          hintText: hiText,
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
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "please dont leave the field empty!";
          }
          return null;
        },
      ),
    );
  }
}
