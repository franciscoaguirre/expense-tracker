import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatePickerFormField extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateChanged;

  const DatePickerFormField(
      {super.key, required this.selectedDate, required this.onDateChanged});

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedDate) {
      onDateChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        _selectDate(context);
      },
      child: IgnorePointer(
        child: TextFormField(
          controller: TextEditingController(
              text: DateFormat('dd-MM-yyyy').format(selectedDate)),
          decoration: const InputDecoration(labelText: 'Select Date'),
        ),
      ),
    );
  }
}
