// A basic function to format the iso date to readable form
String formatIsoToReadableDate(String isoDate) {
  try {
    DateTime dateTime = DateTime.parse(isoDate);

    String formattedDate =
        '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
    String formattedTime =
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

    return '$formattedDate $formattedTime';
  } catch (e) {
    // Return an error message if parsing fails
    return 'Invalid date';
  }
}
