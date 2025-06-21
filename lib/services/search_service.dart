import 'package:cii/models/project.dart';
import 'package:cii/models/snag.dart';
import 'package:cii/models/category.dart';
import 'package:cii/models/tag.dart';
import 'package:cii/models/status.dart';
import 'package:cii/controllers/project_controller.dart';

enum SearchResultType { project, snag }

class SearchResult {
  final String id;
  final String title;
  final String? subtitle;
  final SearchResultType type;
  final Status? status;
  final DateTime? dateCreated;
  final DateTime? dueDate;
  final List<Category>? categories;
  final List<Tag>? tags;
  final dynamic data; // Original Project or Snag object

  SearchResult({
    required this.id,
    required this.title,
    this.subtitle,
    required this.type,
    this.status,
    this.dateCreated,
    this.dueDate,
    this.categories,
    this.tags,
    required this.data,
  });
}

class SearchFilters {
  final List<Category>? categories;
  final List<Status>? statuses;
  final List<Tag>? tags;
  final DateTime? dueDateFrom;
  final DateTime? dueDateTo;
  final DateTime? createdDateFrom;
  final DateTime? createdDateTo;
  final SearchResultType? type;
  final List<String>? assignees;
  final bool? showUnassigned;

  SearchFilters({
    this.categories,
    this.statuses,
    this.tags,
    this.dueDateFrom,
    this.dueDateTo,
    this.createdDateFrom,
    this.createdDateTo,
    this.type,
    this.assignees,
    this.showUnassigned,
  });
}

class SearchService {
  final ProjectController projectController;

  SearchService(this.projectController);

  List<SearchResult> search(String query, {SearchFilters? filters}) {
    final results = <SearchResult>[];
    final projects = projectController.getAllProjects();
    
    // Search projects
    for (final project in projects) {
      if (_matchesFilters(project, null, filters) && _matchesQuery(project, null, query)) {
        results.add(_createProjectResult(project));
      }
      
      // Search snags within projects
      for (final snag in project.snags) {
        if (_matchesFilters(project, snag, filters) && _matchesQuery(project, snag, query)) {
          results.add(_createSnagResult(snag, project));
        }
      }
    }
    
    // Sort by relevance (exact matches first, then by date)
    results.sort((a, b) {
      final aExact = a.title.toLowerCase().contains(query.toLowerCase());
      final bExact = b.title.toLowerCase().contains(query.toLowerCase());
      
      if (aExact && !bExact) return -1;
      if (!aExact && bExact) return 1;
      
      return (b.dateCreated ?? DateTime(0)).compareTo(a.dateCreated ?? DateTime(0));
    });
    
    return results;
  }

  bool _matchesQuery(Project project, Snag? snag, String query) {
    if (query.isEmpty) return true;
    
    final searchText = query.toLowerCase();
    
    if (snag != null) {
      // Search snag fields
      return snag.name.toLowerCase().contains(searchText) ||
             snag.id.toLowerCase().contains(searchText) ||
             (snag.description?.toLowerCase().contains(searchText) ?? false) ||
             (snag.assignee?.toLowerCase().contains(searchText) ?? false) ||
             (snag.location?.toLowerCase().contains(searchText) ?? false) ||
             (snag.finalRemarks?.toLowerCase().contains(searchText) ?? false) ||
             _searchInTags(snag.tags, searchText) ||
             _searchInCategories(snag.categories, searchText);
    } else {
      // Search project fields
      return project.name.toLowerCase().contains(searchText) ||
             (project.description?.toLowerCase().contains(searchText) ?? false) ||
             (project.client?.toLowerCase().contains(searchText) ?? false) ||
             (project.contractor?.toLowerCase().contains(searchText) ?? false) ||
             (project.location?.toLowerCase().contains(searchText) ?? false) ||
             (project.projectRef?.toLowerCase().contains(searchText) ?? false) ||
             _searchInTags(project.createdTags, searchText) ||
             _searchInCategories(project.createdCategories, searchText);
    }
  }

  bool _matchesFilters(Project project, Snag? snag, SearchFilters? filters) {
    if (filters == null) return true;
    
    final targetCategories = snag?.categories ?? project.createdCategories;
    final targetTags = snag?.tags ?? project.createdTags;
    final targetStatus = snag?.status ?? project.status;
    final targetDueDate = snag?.dueDate ?? project.dueDate;
    final targetCreatedDate = snag?.dateCreated ?? project.dateCreated;
    
    // Filter by type
    if (filters.type != null) {
      final expectedType = snag != null ? SearchResultType.snag : SearchResultType.project;
      if (filters.type != expectedType) return false;
    }
    
    // Filter by categories
    if (filters.categories != null && filters.categories!.isNotEmpty) {
      if (targetCategories == null || targetCategories.isEmpty) return false;
      final hasMatchingCategory = filters.categories!.any(
        (filterCat) => targetCategories.any((cat) => cat.name == filterCat.name)
      );
      if (!hasMatchingCategory) return false;
    }
    
    // Filter by statuses
    if (filters.statuses != null && filters.statuses!.isNotEmpty) {
      if (targetStatus == null) return false;
      final hasMatchingStatus = filters.statuses!.any((filterStatus) => filterStatus.name == targetStatus.name);
      if (!hasMatchingStatus) return false;
    }
    
    // Filter by tags
    if (filters.tags != null && filters.tags!.isNotEmpty) {
      if (targetTags == null || targetTags.isEmpty) return false;
      final hasMatchingTag = filters.tags!.any(
        (filterTag) => targetTags.any((tag) => tag.name == filterTag.name)
      );
      if (!hasMatchingTag) return false;
    }
    
    // Filter by due date range
    if (filters.dueDateFrom != null || filters.dueDateTo != null) {
      if (targetDueDate == null) return false;
      if (filters.dueDateFrom != null && targetDueDate.isBefore(filters.dueDateFrom!)) return false;
      if (filters.dueDateTo != null && targetDueDate.isAfter(filters.dueDateTo!)) return false;
    }
    
    // Filter by created date range
    if (filters.createdDateFrom != null || filters.createdDateTo != null) {
      if (targetCreatedDate == null) return false;
      if (filters.createdDateFrom != null && targetCreatedDate.isBefore(filters.createdDateFrom!)) return false;
      if (filters.createdDateTo != null && targetCreatedDate.isAfter(filters.createdDateTo!)) return false;
    }
    
    // Filter by assignees (only applies to snags)
    if (snag != null && (filters.assignees != null || filters.showUnassigned != null)) {
      final assignee = snag.assignee;
      final isUnassigned = assignee == null || assignee.isEmpty;
      
      if (filters.showUnassigned == true && !isUnassigned) return false;
      if (filters.assignees != null && filters.assignees!.isNotEmpty) {
        if (isUnassigned) return false;
        if (!filters.assignees!.contains(assignee)) return false;
      }
    }
    
    return true;
  }

  bool _searchInTags(List<Tag>? tags, String searchText) {
    if (tags == null) return false;
    return tags.any((tag) => tag.name.toLowerCase().contains(searchText));
  }

  bool _searchInCategories(List<Category>? categories, String searchText) {
    if (categories == null) return false;
    return categories.any((cat) => cat.name.toLowerCase().contains(searchText));
  }

  SearchResult _createProjectResult(Project project) {
    return SearchResult(
      id: project.uuid,
      title: project.name,
      subtitle: project.description,
      type: SearchResultType.project,
      status: project.status,
      dateCreated: project.dateCreated,
      dueDate: project.dueDate,
      categories: project.createdCategories,
      tags: project.createdTags,
      data: project,
    );
  }

  SearchResult _createSnagResult(Snag snag, Project project) {
    return SearchResult(
      id: snag.uuid,
      title: snag.name,
      subtitle: '${project.name} • ${snag.description ?? ''}',
      type: SearchResultType.snag,
      status: snag.status,
      dateCreated: snag.dateCreated,
      dueDate: snag.dueDate,
      categories: snag.categories,
      tags: snag.tags,
      data: snag,
    );
  }

  // Get all unique categories from projects and snags
  List<Category> getAllCategories() {
    final categories = <String, Category>{};
    final projects = projectController.getAllProjects();
    
    for (final project in projects) {
      project.createdCategories?.forEach((cat) => categories[cat.name] = cat);
      for (final snag in project.snags) {
        snag.categories?.forEach((cat) => categories[cat.name] = cat);
      }
    }
    
    return categories.values.toList();
  }

  // Get all unique tags from projects and snags
  List<Tag> getAllTags() {
    final tags = <String, Tag>{};
    final projects = projectController.getAllProjects();
    
    for (final project in projects) {
      project.createdTags?.forEach((tag) => tags[tag.name] = tag);
      for (final snag in project.snags) {
        snag.tags?.forEach((tag) => tags[tag.name] = tag);
      }
    }
    
    return tags.values.toList();
  }

  // Get all unique statuses
  List<Status> getAllStatuses() {
    return Status.values;
  }

  // Get all unique assignees from snags
  List<String> getAllAssignees() {
    final assignees = <String>{};
    final projects = projectController.getAllProjects();
    
    for (final project in projects) {
      for (final snag in project.snags) {
        if (snag.assignee != null && snag.assignee!.isNotEmpty) {
          assignees.add(snag.assignee!);
        }
      }
    }
    
    return assignees.toList()..sort();
  }
}