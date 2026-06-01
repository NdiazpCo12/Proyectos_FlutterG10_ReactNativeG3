String formatUserErrorMessage(
  Object error, {
  String fallback = 'Ocurrio un problema. Intenta de nuevo.',
}) {
  var message = error.toString().trim();
  if (message.isEmpty) {
    return fallback;
  }

  message = message.replaceFirst(RegExp(r'^Exception:\s*'), '');
  message = message.replaceFirst(RegExp(r'^\[[0-9]{3}\]\s*'), '');
  message = message.trim();

  return message.isEmpty ? fallback : message;
}
