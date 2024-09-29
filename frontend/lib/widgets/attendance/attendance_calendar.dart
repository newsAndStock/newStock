import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class AttendanceCalendar extends StatelessWidget {
  final double screenWidth;
  final DateTime focusedDay;
  final DateTime selectedDay;
  final List<DateTime> checkedDates;
  final Function(DateTime, DateTime) onDaySelected;

  AttendanceCalendar({
    required this.screenWidth,
    required this.focusedDay,
    required this.selectedDay,
    required this.checkedDates,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: screenWidth * 0.8,
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color.fromARGB(255, 237, 237, 237),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2024, 1, 1),
        lastDay: DateTime.utc(2024, 12, 31),
        focusedDay: focusedDay,
        selectedDayPredicate: (day) {
          return checkedDates.any((d) =>
              d.year == day.year && d.month == day.month && d.day == day.day);
        },
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          selectedDecoration: BoxDecoration(
            color: Color(0xFF3A2E6A),
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: Colors.grey[300],
            shape: BoxShape.circle,
          ),
          weekendTextStyle: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
          defaultTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 16,
          ),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekendStyle: TextStyle(
            color: Color(0xFF3A2E6A),
          ),
          weekdayStyle: TextStyle(
            color: Colors.black,
          ),
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF3A2E6A),
          ),
          leftChevronIcon: Icon(
            Icons.chevron_left,
            color: Colors.black,
          ),
          rightChevronIcon: Icon(
            Icons.chevron_right,
            color: Colors.black,
          ),
        ),
        onDaySelected: onDaySelected,
      ),
    );
  }
}
