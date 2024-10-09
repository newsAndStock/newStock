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
    // 오늘의 달의 첫날과 마지막 날 계산
    final firstDayOfMonth = DateTime(focusedDay.year, focusedDay.month, 1);
    final lastDayOfMonth = DateTime(focusedDay.year, focusedDay.month + 1, 0);

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
        firstDay: firstDayOfMonth, // 오늘의 달의 첫날로 고정
        lastDay: lastDayOfMonth, // 오늘의 달의 마지막 날로 고정
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
          formatButtonVisible: false, // 형식 버튼 숨김
          titleCentered: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF3A2E6A),
          ),
          leftChevronVisible: false, // 왼쪽 화살표 숨김
          rightChevronVisible: false, // 오른쪽 화살표 숨김
        ),
        onDaySelected: onDaySelected,
      ),
    );
  }
}
