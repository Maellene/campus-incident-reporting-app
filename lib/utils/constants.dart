class AppConstants {
  static const List<String> allowedEmailDomains = [
    'alustudent.com',
    'alueducation.com',
  ];

  static const String studentRole = 'student';
  static const String staffRole = 'staff';

  static const String usersCollection = 'users';
  static const String incidentsCollection = 'incidents';

  static const List<String> categories = [
    'Facilities',
    'Water',
    'Electricity',
    'Safety',
    'Sanitation',
  ];

  static const String statusSubmitted = 'submitted';
  static const String statusInProgress = 'in_progress';
  static const String statusResolved = 'resolved';

  static const List<String> _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static String statusLabel(String status) {
    switch (status) {
      case statusInProgress:
        return 'In Progress';
      case statusResolved:
        return 'Resolved';
      default:
        return 'Submitted';
    }
  }

  static String timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    if (diff.inDays < 30) return '${diff.inDays} days ago';
    return '${(diff.inDays / 30).floor()} months ago';
  }

  static String formatShort(DateTime date) {
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '${_months[date.month - 1]} ${date.day}, $hour:$minute $period';
  }

  static String formatDateTime(DateTime date) {
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '${_months[date.month - 1]} ${date.day}, ${date.year} at $hour:$minute $period';
  }
}