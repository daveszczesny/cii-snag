import 'package:cii/models/tag.dart';

class TagController {
  final Tag tag;
  TagController(this.tag);

  String get name {
    return tag.name;
  }

  String get description {
    return tag.description ?? '';
  }
  
}