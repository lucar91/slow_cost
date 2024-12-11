/// Converte una [DateTime] in una stringa nel formato ISO `yyyy-MM-dd`.
/// Il formato richiesto da doPost nell'app script google
String formatIsoDate(DateTime? date) {
  if (date == null) {
    throw ArgumentError('La data non può essere null');
  }
  return '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
