import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';


part 'comment.g.dart';

@HiveType(typeId: 99)
class Comment extends HiveObject {
  // A unique identifier for the comment
  @HiveField(0)
  final String uuid;

  @HiveField(1)
  String text;

  // the date posted
  @HiveField(2)
  DateTime datePosted;

  Comment({
    String? uuid,
    required this.text,
    DateTime? datePosted,
  })  :
        uuid = uuid ?? const Uuid().v4(),
        datePosted = datePosted ?? DateTime.now();
  
}