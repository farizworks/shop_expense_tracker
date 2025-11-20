import 'constants.dart';

class Validators {
  static String? validateRequired(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null
          ? '$fieldName ${AppConstants.errorEmptyField.toLowerCase()}'
          : AppConstants.errorEmptyField;
    }
    return null;
  }

  static String? validateNumber(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null
          ? '$fieldName ${AppConstants.errorEmptyField.toLowerCase()}'
          : AppConstants.errorEmptyField;
    }
    if (double.tryParse(value) == null) {
      return AppConstants.errorInvalidNumber;
    }
    return null;
  }

  static String? validatePositiveNumber(String? value, [String? fieldName]) {
    final numberValidation = validateNumber(value, fieldName);
    if (numberValidation != null) return numberValidation;

    final number = double.parse(value!);
    if (number < 0) {
      return 'Please enter a positive number';
    }
    return null;
  }
}
