import 'package:flutter/material.dart';
import 'package:csc_picker_plus/csc_picker_plus.dart';
import '../../../core/theme/app_spacing.dart';

class AppCountryStatePicker extends StatelessWidget {
  final String label;
  final String? initialCountry;
  final String? initialState;
  final Function(String) onCountryChanged;
  final Function(String?) onStateChanged;
  final bool showCities;

  const AppCountryStatePicker({
    super.key,
    required this.label,
    this.initialCountry,
    this.initialState,
    required this.onCountryChanged,
    required this.onStateChanged,
    this.showCities = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
        ],
        CSCPickerPlus(
          showStates: true,
          showCities: showCities,
          flagState: CountryFlag.ENABLE,
          dropdownDecoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            color: isDark ? const Color(0xFF0F1115) : Colors.white,
            border: Border.all(
              color: isDark ? Colors.white10 : Colors.grey.shade300,
            ),
          ),
          disabledDropdownDecoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            color: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
            border: Border.all(
              color: isDark ? Colors.white10 : Colors.grey.shade300,
            ),
          ),
          countrySearchPlaceholder: "Country",
          stateSearchPlaceholder: "State",
          citySearchPlaceholder: "City",
          countryDropdownLabel: "Country",
          stateDropdownLabel: "State",
          cityDropdownLabel: "City",
          selectedItemStyle: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 14,
          ),
          dropdownHeadingStyle: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
          dropdownItemStyle: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 14,
          ),
          dropdownDialogRadius: 10.0,
          searchBarRadius: 10.0,
          onCountryChanged: (value) {
            onCountryChanged(value);
          },
          onStateChanged: (value) {
            if (value != null) {
              onStateChanged(value);
            }
          },
          onCityChanged: (value) {},
          currentCountry: initialCountry,
          currentState: initialState,
        ),
      ],
    );
  }
}
