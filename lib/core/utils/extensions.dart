/// Extensions utilitaires sur les types Dart
/// Équivalent aux helpers dans core/utils/ du professeur

extension StringExtension on String {
  bool get isValidEmail {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(this);
  }

  bool get isValidPassword {
    return length >= 6;
  }
}

extension DoubleExtension on double {
  String toFormattedPrice() {
    return '${toStringAsFixed(2)} MAD';
  }
}
