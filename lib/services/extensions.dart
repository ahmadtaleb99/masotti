extension xString on String? {
  bool isNumeric() {
    if (this == null) {
      return false;
    }
    return double.tryParse(this!) != null;
  }
}