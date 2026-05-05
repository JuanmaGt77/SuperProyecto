class Validators {
  Validators._();

  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'El correo es requerido';
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!regex.hasMatch(value)) return 'Ingresa un correo válido';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'La contraseña es requerida';
    if (value.length < 6) return 'Mínimo 6 caracteres';
    return null;
  }

  static String? passwordConfirm(String? value, String original) {
    if (value == null || value.isEmpty) return 'Confirma tu contraseña';
    if (value != original) return 'Las contraseñas no coinciden';
    return null;
  }

  static String? required(String? value, [String field = 'Este campo']) {
    if (value == null || value.trim().isEmpty) return '$field es requerido';
    return null;
  }

  static String? fullName(String? value) {
    if (value == null || value.trim().isEmpty) return 'El nombre es requerido';
    if (value.trim().length < 3) return 'Ingresa tu nombre completo';
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.isEmpty) return null; // Opcional
    final regex = RegExp(r'^\+?[0-9]{7,15}$');
    if (!regex.hasMatch(value.replaceAll(RegExp(r'\s|-'), ''))) {
      return 'Número de teléfono inválido';
    }
    return null;
  }

  static String? positiveNumber(String? value, [String field = 'El valor']) {
    if (value == null || value.isEmpty) return '$field es requerido';
    final number = double.tryParse(value);
    if (number == null) return 'Ingresa un número válido';
    if (number <= 0) return '$field debe ser mayor a 0';
    return null;
  }

  static String? minLength(String? value, int min, [String field = 'Este campo']) {
    if (value == null || value.isEmpty) return '$field es requerido';
    if (value.length < min) return '$field debe tener al menos $min caracteres';
    return null;
  }

  static String? maxLength(String? value, int max, [String field = 'Este campo']) {
    if (value == null) return null;
    if (value.length > max) return '$field no puede superar $max caracteres';
    return null;
  }
}
