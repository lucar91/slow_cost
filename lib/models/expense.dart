import '../utilities/formatDatetime.dart';

class Expense {
  int? idMovimento;
  DateTime? date;
  String? name;
  String? category;
  String? subcategory;
  double? amount;

  Expense({
    this.idMovimento,
    this.date,
    this.name,
    this.category,
    this.subcategory,
    this.amount,
  });

  Map<String, dynamic> toJson() {
    return {
      'idMovimento': null,
      'data': date != null ? formatIsoDate(date) : null, // Formato ISO
      'nome': name,
      'categoria': category,
      'sottocategoria': subcategory,
      'importo': amount,
    };
  }
}
