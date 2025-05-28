class AppAssets {
  // Icons
  static const String projectIcon = 'lib/assets/icons/png/project_icon.png';
  static const String snagIcon = 'lib/assets/icons/png/snag_icon.png';
}

class AppStrings {
  // Navigation bar labels
  static const String home = 'Home';
  static const String search = 'Search';
  static const String notifications = 'Notifications';
  static const String add = 'Add';

  static const String uploadImage = 'Upload Image';
  static const String priority = 'Priority';
  static const String category = 'Category';
  static const String categories = 'Categories';
  static String categoryHint() => 'This allows you to group ${AppTerminology.plurlaSnag.toLowerCase()} into categories. Each ${AppTerminology.singularSnag.toLowerCase()} can be assigned a single category';

  static const String tag = 'Tag';
  static const String tags = 'Tags';
  static String tagHint() => 'This allows you to assign tags to ${AppTerminology.plurlaSnag.toLowerCase()}. Each ${AppTerminology.singularSnag.toLowerCase()} can be assigned multiple tags';

  static const String imageAnnotation = 'Image Annotation';
  static const String imageAnnotationExport = 'Image exported successfully';

  static const String photoLibrary = 'Photo Library';
  static const String photoCamera = 'Camera';

  static const String id = 'ID';

  // Titles
  static const String appTitle = 'CII';
  static const String newProject = 'New Project';

  // Text labels
  static const String project = 'Project';
  static String snag() => AppTerminology.singularSnag;
  static String snags() => AppTerminology.plurlaSnag;

  static String snagsInProject(String projectName) => '${AppTerminology.plurlaSnag} in $projectName';
  static String createInProject(String projectName) => 'Create ${AppTerminology.singularSnag} in $projectName';

  // Project List
  static const String myProjects = 'My Projects';
  static const String noProjectsFound = 'No Projects Found';
  static const String noProjectsFoundQuickAdd = 'No projects found. Add a project first.';
  // Project Create
  static String projectNameDefault(String name) =>  'Project name is empty. Default name $name will be used';

  static const String projectTite = 'Project Title';
  static const String projectTitleExample = 'E.g. My new project';

  static const String projectDescription = 'Description';
  static const String projectDescriptionExample = 'E.g. Short desciption of project';

  static const String projectLocation = 'Location';
  static const String projectLocationExample = 'E.g. London';

  static const String projectRef = 'Project Ref';
  static const String projectRefExample = 'E.g. PID012';

  static const String projectClient = 'Client';
  static const String projectClientExample = 'E.g. London Underground';

  static const String projectContractor = 'Contractor';
  static const String projectContractorExample = 'E.g. Emico';
  static const String projectCreate = 'Create Project';

  // Project Details
  static const String projectDetails = 'Details';
  static const String projectId = 'Project ID';

  // Snag Create

  static String snagNameDefault(String name) =>  '${AppTerminology.singularSnag} name is empty. Default name $name will be used';

  static String snagCreate() => 'Create ${AppTerminology.singularSnag}';
  
  static String snagName() => '${AppTerminology.singularSnag} Name';
  static const String name = 'Name';
  static const String snagNameExample = 'E.g. Broken Light';

  static const String assignee = 'Assignee';
  static const String assigneeExample = 'E.g. John Doe';

  static const String snagLocationExample = 'E.g. Living Room';

  static const String progressPictures = 'Progress Pictures';
  static const String addProgressPictures = 'Add $progressPictures';

  static const String finalRemarks = 'Final Remarks';

  // Card Widget
  static String noSnagsFound() => 'No ${AppTerminology.plurlaSnag} Found';

  // Quick actions : Project
  static const String viewProject = 'View Project';
  static const String shareProject = 'Export Project';
  static const String editProject = 'Edit Project';
  static const String deleteProject = 'Delete Project';
  static String addSnag() => 'Add ${AppTerminology.singularSnag}';
  static const String deleteProjectConfirmation = 'Are you sure you want to delete this project?';
  static const String cancel = 'Cancel';
  static const String delete = 'Delete';

  // Quick actions : Snag
  static String viewSnag() => 'View ${AppTerminology.singularSnag}';
  static String shareSnag() => 'Share ${AppTerminology.singularSnag}';
  static String editSnag() => 'Edit ${AppTerminology.singularSnag}';
  static String deleteSnag() => 'Delete ${AppTerminology.singularSnag}';

  // Status
  static const String status = 'Status';
  static const String statusTodo = 'To Do';
  static const String statusInProgress = 'In Progress';
  static const String statusCompleted = 'Completed';
  static const String statusBlocked = 'On Hold';
  static const String all = 'All';
}

class AppSizing {
  // Bottom navigation bar height
  static const double bottomNavBarHeight = 60.0;
}


class AppTerminology {
  static String singularSnag = 'Snag';
  static String plurlaSnag = 'Snags';

  static void setSnagTerm({required String singular, required String plural}) {
    singularSnag = singular;
    plurlaSnag = plural;
  }
}