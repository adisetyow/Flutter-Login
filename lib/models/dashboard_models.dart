import 'package:flutter/material.dart';

class FinancialData {
  final String month;
  final int income;
  final int expense;

  FinancialData(this.month, this.income, this.expense);
}

class UpcomingEvent {
  final String title;
  final String date;
  final String location;
  final IconData icon;
  final Color color;

  UpcomingEvent(this.title, this.date, this.location, this.icon, this.color);
}
