import 'package:flutter/material.dart';
import 'tabs/expense_tab.dart';
import 'tabs/budget_tab.dart';
import 'tabs/kpi_tab.dart';
import 'tabs/charts_tab.dart';
import 'tabs/edit_tab.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 2;

  final List<Widget> _tabs = [
    BudgetTab(), // Budget
    KpiTab(), // KPI
    ExpenseTab(), // Home
    ChartsTab(), // Grafici
    EditTab(), // Modifica
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestione Spese'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              /*Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsPage(),
                ),
              );*/
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: _tabs[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.account_balance), label: 'Budget'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'KPI'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.pie_chart), label: 'Grafici'),
          BottomNavigationBarItem(icon: Icon(Icons.edit), label: 'Modifica'),
        ],
      ),
    );
  }
}
