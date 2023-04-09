import 'package:intl/intl.dart';

class Generals{
   static String getTime() {
    DateTime now = new DateTime.now();
    DateTime date =
    DateTime(now.year, now.month, now.day, now.hour, now.minute);
    String dateToday = date.toString().substring(0, 16);
    return dateToday;
  }

  static getDaysBetweenDates(String date1, String date2) {
    DateFormat format = DateFormat("yyyy-MM-dd HH:mm");
    DateTime startDate = format.parse(date1);
    DateTime endDate = format.parse(date2);
    int differenceInMilliseconds = endDate.difference(startDate).inMilliseconds;
    return (differenceInMilliseconds / (1000 * 60 * 60 * 24)).floor();
  }
}