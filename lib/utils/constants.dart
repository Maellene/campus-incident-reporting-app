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
}