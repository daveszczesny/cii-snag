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
  static const String categoryHint = 'This allows you to group snags into categories. Each snag can be assigned a single category';

  static const String tag = 'Tag';
  static const String tags = 'Tags';
  static const String tagHint = 'This allows you to assign tags to snags. Each snag can be assigned multiple tags';

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
  static const String snag = 'Snag';
  static const String snags = 'Snags';

  // Project List
  static const String myProjects = 'My Projects';
  static const String noProjectsFound = 'No Projects Found';
  static const String noProjectsFoundQuickAdd = 'No projects found. Add a project first.';
  // Project Create
  static String projectNameDefault(String name) =>  'Project name is empty. Default name $name will be used';

  static const String projectTite = 'Project Title';
  static const String projectTitleExample = 'Ex. My new project';

  static const String projectDescription = 'Description';
  static const String projectDescriptionExample = 'Ex. Short desciption of project';

  static const String projectLocation = 'Location';
  static const String projectLocationExample = 'Ex. London';

  static const String projectRef = 'Project Ref';
  static const String projectRefExample = 'Ex. PID012';

  static const String projectClient = 'Client';
  static const String projectClientExample = 'Ex. London Underground';

  static const String projectContractor = 'Contractor';
  static const String projectContractorExample = 'Ex. Emico';
  static const String projectCreate = 'Create Project';

  // Project Details
  static const String projectDetails = 'Details';
  static const String projectId = 'Project ID';

  // Snag Create
  static String snagNameDefault(String name) =>  'Snag name is empty. Default name $name will be used';

  static const String snagCreate = 'Create Snag';
  
  static const String snagName = 'Snag Name';
  static const String name = 'Name';
  static const String snagNameExample = 'Ex. Broken Light';

  static const String assignee = 'Assignee';
  static const String assigneeExample = 'Ex. John Doe';

  static const String snagLocationExample = 'Ex. Living Room';

  static const String progressPictures = 'Progress Pictures';
  static const String addProgressPictures = 'Add $progressPictures';

  static const String finalRemarks = 'Final Remarks';

  // Card Widget
  static const String noSnagsFound = 'No Snags Found';

  // Quick actions : Project
  static const String viewProject = 'View Project';
  static const String shareProject = 'Share Project';
  static const String editProject = 'Edit Project';
  static const String deleteProject = 'Delete Project';
  static const String addSnag = 'Add Snag';
  static const String deleteProjectConfirmation = 'Are you sure you want to delete this project?';
  static const String cancel = 'Cancel';
  static const String delete = 'Delete';

  // Quick actions : Snag
  static const String viewSnag = 'View Snag';
  static const String shareSnag = 'Share Snag';
  static const String editSnag = 'Edit Snag';
  static const String deleteSnag = 'Delete Snag';

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
