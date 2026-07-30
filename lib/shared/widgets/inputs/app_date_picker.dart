import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'app_text_field.dart';

class AppDatePicker extends StatefulWidget {
  final String? label;
  final String? placeholder;
  final String? helperText;
  final String? errorText;
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final ValueChanged<DateTime?>? onChanged;
  final bool isRequired;

  const AppDatePicker({
    super.key,
    this.label,
    this.placeholder,
    this.helperText,
    this.errorText,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.onChanged,
    this.isRequired = false,
  });

  @override
  State<AppDatePicker> createState() => _AppDatePickerState();
}

class _AppDatePickerState extends State<AppDatePicker> {
  late TextEditingController _controller;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _controller = TextEditingController(
      text: _selectedDate != null ? DateFormat('yyyy-MM-dd').format(_selectedDate!) : '',
    );
  }

  @override
  void didUpdateWidget(AppDatePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialDate != oldWidget.initialDate) {
      _selectedDate = widget.initialDate;
      _controller.text = _selectedDate != null ? DateFormat('yyyy-MM-dd').format(_selectedDate!) : '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: widget.firstDate ?? DateTime(1900),
      lastDate: widget.lastDate ?? DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            datePickerTheme: const DatePickerThemeData(
              elevation: 0,
            ),
            colorScheme: Theme.of(context).brightness == Brightness.dark
                ? const ColorScheme.dark(
                    primary: Color(0xFF90276E),
                    onPrimary: Colors.white,
                    surface: Color(0xFF181A1F),
                    onSurface: Colors.white,
                  )
                : const ColorScheme.light(
                    primary: Color(0xFF90276E),
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: Colors.black,
                  ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _controller.text = DateFormat('yyyy-MM-dd').format(picked);
      });
      if (widget.onChanged != null) {
        widget.onChanged!(picked);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: widget.label,
      placeholder: widget.placeholder ?? 'YYYY-MM-DD',
      helperText: widget.helperText,
      errorText: widget.errorText,
      controller: _controller,
      isRequired: widget.isRequired,
      readOnly: true,
      onTap: () => _selectDate(context),
      suffixIcon: IconButton(
        icon: const Icon(LucideIcons.calendar),
        onPressed: () => _selectDate(context),
      ),
    );
  }
}
