import 'package:flutter_contacts/flutter_contacts.dart';

class ContactChecker {
  static Future<bool> isInContacts(String? number) async {
    if (number == null) return false;

    // Request permission if not granted
    if (!await FlutterContacts.requestPermission()) {
      return false;
    }

    final contacts = await FlutterContacts.getContacts(withProperties: true);

    final cleaned = number.replaceAll(' ', '');

    for (var c in contacts) {
      for (var phone in c.phones) {
        if (phone.number.replaceAll(' ', '') == cleaned) {
          return true;
        }
      }
    }

    return false;
  }
}
