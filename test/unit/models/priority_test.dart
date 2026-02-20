import 'package:flutter_test/flutter_test.dart';
import 'package:cii/models/priority.dart';

void main() {
  group("Priority Model Tests", () {

    test("should have all priority values", () {
      expect(Priority.values, hasLength(3));
      expect(Priority.values, contains(Priority.low));
      expect(Priority.values, contains(Priority.medium));
      expect(Priority.values, contains(Priority.high));
    });

    test("should get priority by string - case insensitive", () {
      expect(Priority.getPriorityByString("low"), Priority.low);
      expect(Priority.getPriorityByString("LOW"), Priority.low);
      expect(Priority.getPriorityByString("medium"), Priority.medium);
      expect(Priority.getPriorityByString("MEDIUM"), Priority.medium);
      expect(Priority.getPriorityByString("high"), Priority.high);
      expect(Priority.getPriorityByString("HIGH"), Priority.high);
    });

    test("should return default priority for unknown strings", () {
      expect(Priority.getPriorityByString("unknown"), Priority.low);
      expect(Priority.getPriorityByString(""), Priority.low);
      expect(Priority.getPriorityByString("invalid"), Priority.low);
    });

    test("should return correct icon paths", () {
      expect(Priority.low.icon, "lib/assets/icons/png/priority_low_icon.png");
      expect(Priority.medium.icon, "lib/assets/icons/png/priority_medium_icon.png");
      expect(Priority.high.icon, "lib/assets/icons/png/priority_high_icon.png");
    });

  });
}