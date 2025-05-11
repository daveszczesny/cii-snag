import 'package:cii/models/priority.dart';
import 'package:hive/hive.dart';

class PriorityAdapter extends TypeAdapter<Priority> {
  @override
  final int typeId = 5;

  @override
  Priority read(BinaryReader reader) {
    switch(reader.readByte()) {
      case 0:
        return Priority.low;
      case 1:
        return Priority.medium;
      case 2:
        return Priority.high;
      default:
        return Priority.low; // Default to low if no match
    }
  }

  @override
  void write(BinaryWriter writer, Priority obj) {
    switch(obj) {
      case Priority.low:
        writer.writeByte(0);
        break;
      case Priority.medium:
        writer.writeByte(1);
        break;
      case Priority.high:
        writer.writeByte(2);
        break;
    }
  }
}