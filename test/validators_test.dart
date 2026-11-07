import 'package:campus_incident_app/utils/constants.dart';
import 'package:campus_incident_app/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Validators.email', () {
    test('rejects an empty email', () {
      expect(Validators.email(''), 'Email is required');
    });

    test('rejects a badly formed email', () {
      expect(Validators.email('abc'), 'Enter a valid email address');
    });

    test('rejects a non-ALU email', () {
      expect(Validators.email('test@gmail.com'), 'Use your ALU email address');
    });

    test('accepts an alustudent.com email', () {
      expect(Validators.email('student@alustudent.com'), isNull);
    });

    test('accepts an alueducation.com email', () {
      expect(Validators.email('staff@alueducation.com'), isNull);
    });
  });

  group('Validators.password', () {
    test('rejects an empty password', () {
      expect(Validators.password(''), 'Password is required');
    });

    test('rejects a short password', () {
      expect(
        Validators.password('1234567'),
        'Password must be at least 8 characters',
      );
    });

    test('accepts a valid password', () {
      expect(Validators.password('12345678'), isNull);
    });
  });

  group('Validators.confirmPassword', () {
    test('rejects a different password', () {
      expect(
        Validators.confirmPassword('abcdefgh', '12345678'),
        'Passwords do not match',
      );
    });

    test('accepts a matching password', () {
      expect(Validators.confirmPassword('12345678', '12345678'), isNull);
    });
  });

  group('Validators.required', () {
    test('rejects blank text', () {
      expect(Validators.required('   ', 'Title'), 'Title is required');
    });

    test('accepts text', () {
      expect(Validators.required('Water', 'Title'), isNull);
    });
  });

  group('AppConstants.statusLabel', () {
    test('returns readable labels', () {
      expect(AppConstants.statusLabel(AppConstants.statusSubmitted), 'Submitted');
      expect(
        AppConstants.statusLabel(AppConstants.statusInProgress),
        'In Progress',
      );
      expect(AppConstants.statusLabel(AppConstants.statusResolved), 'Resolved');
    });
  });
}