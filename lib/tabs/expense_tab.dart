import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../models/expense.dart';
import '../utilities/formatDatetime.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ExpenseTab extends StatefulWidget {
  @override
  _ExpenseTabState createState() => _ExpenseTabState();
}

class _ExpenseTabState extends State<ExpenseTab> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;
  String? _name;
  String? selectedCategory;
  String? selectedSubcategory;
  double? _amount;

  Map<String, List<String>> categories = {};
  final TextEditingController _dateController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  Future<void> loadCategories() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/expense_categories.json');
      final dynamic decodedJson = json.decode(jsonString);
      setState(() {
        categories = (decodedJson as Map<String, dynamic>).map(
          (key, value) => MapEntry(key, List<String>.from(value as List)),
        );
      });
    } catch (e) {
      print('Errore nel caricamento del file JSON: $e');
    }
  }

  Future<void> _submitData() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    // Ottieni l'ID dell'utente loggato
    final user = Supabase.instance.client.auth.currentUser;
    final userId = user?.id;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore: utente non autenticato')),
      );
      return;
    }

    final expense = Expense(
      idMovimento: null,
      date: _selectedDate,
      name: _name,
      category: selectedCategory,
      subcategory: selectedSubcategory,
      amount: _amount,
    );

    setState(() {
      _isLoading = true; // Mostra il loader
    });

    try {
      final response = await Supabase.instance.client
          .from('expenses') // Nome della tabella in Supabase
          .insert({
        'user_id': userId, // Aggiungi l'ID dell'utente loggato
        'date': expense.date?.toIso8601String(),
        'name': expense.name,
        'category': expense.category,
        'subcategory': expense.subcategory,
        'amount': expense.amount,
      });

      if (response.error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Riga aggiunta correttamente!')),
        );
        _resetForm();
      } else {
        throw Exception(response.error?.message);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false; // Nascondi il loader
      });
    }
  }

  Future<void> _resetForm() async {
    setState(() {
      _selectedDate = null;
      _dateController.clear();
      selectedCategory = null;
      selectedSubcategory = null;
      _formKey.currentState?.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(35.0),
              child: Image.asset(
                'assets/money_loader.gif',
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
          )
        : Padding(
            padding: EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  TextFormField(
                    readOnly: true,
                    controller: _dateController,
                    decoration: InputDecoration(
                      labelText: 'Data',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate ?? DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          _selectedDate = pickedDate;
                          _dateController.text = formatIsoDate(pickedDate);
                        });
                      }
                    },
                    validator: (value) =>
                        _selectedDate == null ? 'Seleziona una data' : null,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Nome'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Inserisci un nome';
                      }
                      return null;
                    },
                    onSaved: (value) => _name = value,
                  ),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(labelText: 'Categoria'),
                    value: selectedCategory,
                    items: categories.keys.map((String cat) {
                      return DropdownMenuItem<String>(
                        value: cat,
                        child: Text(cat),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value;
                        selectedSubcategory = null;
                      });
                    },
                    onSaved: (value) => selectedCategory = value,
                    validator: (value) =>
                        value == null ? 'Seleziona una categoria' : null,
                  ),
                  if (selectedCategory != null)
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(labelText: 'Sottocategoria'),
                      value: selectedSubcategory,
                      items: (categories[selectedCategory!] ?? [])
                          .map((String subcat) {
                        return DropdownMenuItem<String>(
                          value: subcat,
                          child: Text(subcat),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedSubcategory = value;
                        });
                      },
                      onSaved: (value) => selectedSubcategory = value,
                      validator: (value) =>
                          value == null ? 'Seleziona una sottocategoria' : null,
                    ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Importo'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Inserisci un importo';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Inserisci un numero valido';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _amount = value != null ? double.tryParse(value) : null;
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _submitData,
                    child: Text('Invia'),
                  ),
                ],
              ),
            ),
          );
  }
}
