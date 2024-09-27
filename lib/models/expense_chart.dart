import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class IncomeExpenseChart extends StatelessWidget {
  final List<DocumentSnapshot> transactions;

  const IncomeExpenseChart({super.key, required this.transactions});
  
  @override
  Widget build(BuildContext context) {
    // Prepare data for the chart
    Map<String, double> incomeData = {};
    Map<String, double> expenseData = {};

    for (var doc in transactions) {
      String date = doc['date'].substring(0, 10); // Assuming date is in the format YYYY-MM-DD
      double amount = doc['amount'];

      if (doc['type'] == 'Income') {
        incomeData[date] = (incomeData[date] ?? 0) + amount;
      } else {
        expenseData[date] = (expenseData[date] ?? 0) + amount;
      }
    }
    
    List<FlSpot> incomeSpots = incomeData.entries.map((e) {
      return FlSpot(
        DateTime.parse(e.key).millisecondsSinceEpoch.toDouble(),
        e.value,
      );
    }).toList();

    List<FlSpot> expenseSpots = expenseData.entries.map((e) {
      return FlSpot(
        DateTime.parse(e.key).millisecondsSinceEpoch.toDouble(),
        e.value,
      );
    }).toList();

    return LineChart(
      LineChartData(
        titlesData: FlTitlesData(show: true),
        borderData: FlBorderData(show: true),
        gridData: FlGridData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: incomeSpots,
            isCurved: true,
            color: Colors.green, // Changed from colors to color
            belowBarData: BarAreaData(show: false),
            dotData: FlDotData(show: false), // Optional: Hide dots
          ),
          LineChartBarData(
            spots: expenseSpots,
            isCurved: true,
            color: Colors.red, // Changed from colors to color
            belowBarData: BarAreaData(show: false),
            dotData: FlDotData(show: false), // Optional: Hide dots
          ),
        ],
      ),
    );
  }
}
