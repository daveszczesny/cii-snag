import 'package:cii/models/comment.dart';
import 'package:cii/models/snag.dart';
import 'package:cii/models/status.dart';
import 'package:cii/models/priority.dart' as snag_priority;

class SnagController {

  final Snag snag;
  SnagController(this.snag);

  String get getId {
    return snag.id;
  }

  DateTime get dateCreated {
    return snag.dateCreated;
  }

  String get name {
    return snag.name;
  }

  Status get status {
    return snag.status;
  }

  set status(Status status) {
    snag.status = status;
  }

  snag_priority.Priority get priority {
    return snag.priority;
  }

  String get assignee {
    return snag.assignee ?? '';
  }

  String get location {
    return snag.location ?? '';
  }

  String get finalRemarks {
    return snag.finalRemarks ?? '';
  }

  List<String> get imagePaths {
    return snag.imagePaths ?? [];
  }
  
  List<Comment> get comments {
    return snag.comments ?? [];
  }
  
  DateTime? get lastModified {
    return snag.lastModified;
  }
  
  DateTime? get dateCompleted {
    return snag.dateCompleted;
  }
  
  String get description {
    return snag.description ?? '';
  }

}