part of 'extension.dart';

extension DateTimeHelper on DateTime {
  String dateTimeString({bool? isShowDate}) {
    String dateInString = '';
    final DateFormat formatter = DateFormat('dd MMMM yyyy');
    dateInString = formatter.format(this);

    return dateInString;
  }

  String taskDateTimeString({bool? isShowDate}) {
    String dateInString = '';
    final DateFormat formatter = DateFormat('hh:mm a');
    dateInString = formatter.format(this);
    return dateInString;
  }

  String getTimeToString() {
    String dateInString = '';
    final DateFormat formatter = DateFormat('HH:mm');
    dateInString = formatter.format(toLocal());
    return dateInString;
  }

  String dateToyyyymmdd() {
    String dateInString = '';
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    dateInString = formatter.format(this);
    return dateInString;
  }

  String showDayMonth() {
    String dateInString = '';
    final DateFormat formatter = DateFormat('dd, MMMM');
    dateInString = formatter.format(this);
    return dateInString;
  }

  String dateTimeStringForAnnouncement() {
    String dateInString = '';
    final DateFormat formatter = DateFormat('EEEE, MMMM dd yyyy');
    dateInString = formatter.format(this);

    return dateInString;
  }

  String dateTimeStringForNotification() {
    String fullString = '';
    final DateFormat formatter = DateFormat('MMMM dd yyyy');
    final String dateInString = formatter.format(this);

    final DateFormat formatterTime = DateFormat('hh:mm a');
    final String timeInString = formatterTime.format(this);

    fullString = '$dateInString at $timeInString';

    return fullString;
  }

  bool isBeforeCurrentTime() {
    final DateTime now = DateTime.now();
    return isBefore(now);
  }

  bool isToday() {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime dateToCheck = DateTime(year, month, day);

    if (today == dateToCheck) {
      return true;
    }

    return false;
  }

  bool isYesterDay() {
    final DateTime now = DateTime.now();
    final DateTime yesterday = now.subtract(const Duration(days: 1));
    if (day == yesterday.day &&
        month == yesterday.month &&
        year == yesterday.year) {
      return true;
    }

    return false;
  }

  DateTime timeIn15Interval() {
    //String nearestHoursInterval = now.hour;
    //String nearestMinuteInterval = now.minute;
    // round to nearest 15 minutes
    int hoursInterval = hour;
    int minuteInterval = minute;
    if (minute % 15 != 0) {
      minuteInterval += 15 - (minute % 15);
    }

    if (minuteInterval > 59) {
      hoursInterval += 1;
      minuteInterval = 00;
    }

    DateFormat dateFormat = DateFormat('HH:mm');
    DateTime currentTime = dateFormat.parse('$hoursInterval:$minuteInterval');
    // String todaysTime = DateFormat.Hm().format(dt);
    return currentTime;
  }

  String timeString() {
    var formatter = DateFormat('hh:mm a');
    return formatter.format(this);
  }

  String dateDay() {
    var formatterDay = DateFormat('dd');
    return formatterDay.format(this);
  }

  String dateMonth() {
    var formatterMonth = DateFormat('MMMM');
    return formatterMonth.format(this);
  }

  // String dayName(isFullName) {
  //   var formatter = DateFormat(isFullName ? 'EEEE' : 'E');
  //   return formatter.format(this);
  // }

  String dateDifferenceInHours(DateTime dateToCompare) {
    int diff = difference(dateToCompare).inHours;
    if (diff > 24) {
      diff = difference(dateToCompare).inDays;
      return '${diff}d left';
    }
    return '${diff}h left';
  }

  String timeStringIn24Format() {
    DateFormat dateFormat = DateFormat('HH:mm');
    DateTime currentTime = dateFormat.parse('$hour:$minute');
    String todaysTime = DateFormat.Hm().format(currentTime);
    return todaysTime;
  }

  DateTime dateForTime(DateTime time) {
    DateTime dateTime =
        DateTime(year, month, day, time.hour, time.minute);
    return dateTime;
  }

  DateTime dateConvert(String time) {
    DateTime timeOfDay = DateFormat('HH:mm').parse(time);

    DateTime dateTime = DateTime(
        year, month, day, timeOfDay.hour, timeOfDay.minute);
    return dateTime;
  }

  DateTime addDay(int days) {
    DateTime newDate = DateTime(year, month, day + days);
    return newDate;
  }

  DateTime addMinutes(int minutes) {
    DateTime newDate = DateTime(
        year, month, day, hour, minute + minutes);
    return newDate;
  }

  DateTime minusMinutes(int minutes) {
    DateTime newDate = DateTime(
        year, month, day, hour, minute - minutes);
    return newDate;
  }

  DateTime addMonth(int value) {
    DateTime newDate = DateTime(year, month + value, day);
    return newDate;
  }

  String timeAfter({bool numericDates = true}) {
    final date2 = DateTime.now();
    final difference = date2.difference(this);

    if (difference.inDays == 0) {
      return 'AppConstants.today';
    } else if (difference.inDays == 1) {
      return 'AppConstants.tomorrow';
    } else {
      var formatter = DateFormat('MMM dd');
      return formatter.format(this);
    }
  }

  String timeAgo({bool numericDates = true}) {
    final date2 = DateTime.now();
    final difference = date2.difference(this);

    if (difference.inDays > 360) {
      final DateFormat formatter = DateFormat('MMM dd yyyy');
      return formatter.format(this);
    } else if (difference.inDays > 8) {
      final DateFormat formatter = DateFormat('MMM dd');
      return formatter.format(this);
    } else if ((difference.inDays / 7).floor() >= 1) {
      return numericDates ? '1 week' : 'Last week';
    } else if (difference.inDays >= 2) {
      return '${difference.inDays} d';
    } else if (difference.inDays >= 1) {
      return numericDates ? '1 d' : 'Yesterday';
    } else if (difference.inHours >= 2) {
      return '${difference.inHours} h';
    } else if (difference.inHours >= 1) {
      return numericDates ? '1 h' : 'h';
    } else if (difference.inMinutes >= 2) {
      return '${difference.inMinutes} m';
    } else if (difference.inMinutes >= 1) {
      return numericDates ? '1 m' : '1 m';
    } else if (difference.inSeconds >= 3) {
      return '${difference.inSeconds} sec';
    } else {
      return 'Just now';
    }
  }

  bool isEqualDate(DateTime nextDate) {
    return year == nextDate.year &&
        month == nextDate.month &&
        day == nextDate.day;
  }
}
