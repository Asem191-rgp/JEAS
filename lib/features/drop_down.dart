import 'package:flutter/material.dart';
import 'package:jeas/features/job_dropdown.dart';

class DropDownValue extends StatefulWidget {
  final TextEditingController job;
  final String personality;
  final Function(String, String) onUpdatePersonality;

  const DropDownValue(this.job, this.personality, this.onUpdatePersonality,
      {super.key});

  @override
  State<DropDownValue> createState() => _DropDownValueState();
}

class _DropDownValueState extends State<DropDownValue> {
  String? _selectedItem = 'Customer';
  final List<String> _items = ["Customer", "Worker"];
  bool _showAdditionalFields = false;
  TextEditingController job = TextEditingController();

  String jo = "", bi = "";

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 7, horizontal: 20),
          child: DropdownButtonFormField<String>(
            value: _selectedItem,
            items: _items.map((String item) {
              return DropdownMenuItem(
                value: item,
                child: Text(
                  item,
                  style: const TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 12,
                  ),
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedItem = newValue;
                _showAdditionalFields = newValue == 'Worker';
              });
            },
            decoration: InputDecoration(
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
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 5,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Please don't leave the field empty!";
              }
              return null;
            },
          ),
        ),
        Visibility(
          visible: _showAdditionalFields,
          child: Column(
            children: [
              JobDropDown(
                widget.job,
                onJobSelected: (selectedJob) {
                  setState(() {
                    job.text = selectedJob;
                    widget.onUpdatePersonality(_selectedItem!, job.text);
                  });
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ],
    );
  }
}
