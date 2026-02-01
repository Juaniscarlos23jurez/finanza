import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  static final NumberFormat _formatter = NumberFormat.decimalPattern();

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Count digits before cursor to maintain position
    int selectionIndex = newValue.selection.end;
    String textBeforeCursor = newValue.text.substring(0, selectionIndex);
    int digitsBeforeCursor = textBeforeCursor.replaceAll(RegExp(r'[^\d]'), '').length;

    // Remove everything EXCEPT digits
    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    
    if (digitsOnly.isEmpty) {
      return newValue.copyWith(text: '', selection: const TextSelection.collapsed(offset: 0));
    }

    double? value = double.tryParse(digitsOnly);
    if (value == null) return oldValue;

    String formattedText = _formatter.format(value);
    
    // Find new selection index based on the number of digits we had before
    int newSelectionIndex = 0;
    int digitCount = 0;
    while (newSelectionIndex < formattedText.length && digitCount < digitsBeforeCursor) {
      if (RegExp(r'[\d]').hasMatch(formattedText[newSelectionIndex])) {
        digitCount++;
      }
      newSelectionIndex++;
    }
    
    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: newSelectionIndex),
    );
  }
}
