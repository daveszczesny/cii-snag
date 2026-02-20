import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:cii/models/status.dart';

void main() {
  group("Status Model Tests", () {

    test("should create status with required name", () {
      final status = Status(name: "Test Status");

      expect(status.name, "Test Status");
      expect(status.uuid, isNotNull);
      expect(status.color, isNull);
    });

    test("should create status with name and color", () {
      final status = Status(name: "Test Status", color: Colors.red);

      expect(status.name, "Test Status");
      expect(status.color, Colors.red);
      expect(status.uuid, isNotNull);
    });

    test("should generate unique uuid when not provided", () {
      final status1 = Status(name: "Status 1");
      final status2 = Status(name: "Status 2");

      expect(status1.uuid, isNotNull);
      expect(status2.uuid, isNotNull);
      expect(status1.uuid, isNot(equals(status2.uuid)));
    });

    test("should use provided uuid", () {
      const customUuid = "custom-uuid-123";
      final status = Status(name: "Test Status", uuid: customUuid);

      expect(status.uuid, customUuid);
    });

    test("should have predefined status values", () {
      expect(Status.todo.name, "Open");
      expect(Status.inProgress.name, "In Progress");
      expect(Status.completed.name, "Closed");
      expect(Status.blocked.name, "On Hold");
    });

    test("should contain all predefined statuses in values list", () {
      expect(Status.values, hasLength(4));
      expect(Status.values, contains(Status.todo));
      expect(Status.values, contains(Status.inProgress));
      expect(Status.values, contains(Status.completed));
      expect(Status.values, contains(Status.blocked));
    });

    test("should get status by name - case insensitive", () {
      expect(Status.getStatus("open")?.name, "Open");
      expect(Status.getStatus("OPEN")?.name, "Open");
      expect(Status.getStatus("in progress")?.name, "In Progress");
      expect(Status.getStatus("inprogress")?.name, "In Progress");
      expect(Status.getStatus("closed")?.name, "Closed");
      expect(Status.getStatus("blocked")?.name, "On Hold");
      expect(Status.getStatus("on hold")?.name, "On Hold");
      expect(Status.getStatus("onhold")?.name, "On Hold");
    });

    test("should return default status for unknown names", () {
      expect(Status.getStatus("unknown")?.name, "Open");
      expect(Status.getStatus("")?.name, "Open");
      expect(Status.getStatus("random")?.name, "Open");
    });

  });
}