class Generals{
   static String getTime() {
    DateTime now = new DateTime.now();
    DateTime date =
    DateTime(now.year, now.month, now.day, now.hour, now.minute);
    String dateToday = date.toString().substring(0, 16);
    return dateToday;
  }
}