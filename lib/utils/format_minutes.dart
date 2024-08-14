String formatDurationFromTotalMinutes(int totalMinutes) {
  if (totalMinutes <= 0) {
    return '3 min';
  }

  int hours = totalMinutes ~/ 60;
  int minutes = totalMinutes % 60;

  if (hours > 0) {
    if (minutes >= 30) {
      // Round up to the next hour if 30 minutes or more
      return '${hours + 1} hr';
    } else {
      // If less than 30 minutes, just show the hours
      return '$hours hr';
    }
  } else {
    return '$minutes min';
  }
}
