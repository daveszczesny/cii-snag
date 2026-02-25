import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:cii/services/project_service.dart';
import 'package:cii/view/project/project_detail.dart';
import 'package:cii/view/snag/snag_detail.dart';
import 'package:cii/view/utils/constants.dart';
import 'package:cii/services/search_service.dart';
import 'package:cii/models/project.dart';
import 'package:cii/models/snag.dart';
import 'package:cii/models/category.dart';
import 'package:cii/models/status.dart';
import 'package:cii/models/tag.dart';
import 'package:cii/utils/colors/app_colors.dart';

class Search extends ConsumerStatefulWidget{
  const Search({super.key});

  @override
  ConsumerState<Search> createState() => _SearchState(); 
}

class _SearchState extends ConsumerState<Search> {
  late SearchService _searchService;
  final TextEditingController _searchController = TextEditingController();
  List<SearchResult> _results = [];
  bool _isLoading = false;
  Timer? _debounceTimer;
  
  // Filter state
  List<Category> _selectedCategories = [];
  List<Status> _selectedStatuses = [];
  List<Tag> _selectedTags = [];
  List<String> _selectedAssignees = [];
  bool _showUnassigned = false;
  DateTime? _dueDateFrom;
  DateTime? _dueDateTo;
  DateTime? _createdDateFrom;
  DateTime? _createdDateTo;
  SearchResultType? _selectedType;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final List<Project> projects = ProjectService.getProjects(ref);
    _searchService = SearchService.fromProjects(projects);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _performSearch();
    });
  }

  void _performSearch() {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });

    final filters = SearchFilters(
      categories: _selectedCategories.isEmpty ? null : _selectedCategories,
      statuses: _selectedStatuses.isEmpty ? null : _selectedStatuses,
      tags: _selectedTags.isEmpty ? null : _selectedTags,
      assignees: _selectedAssignees.isEmpty ? null : _selectedAssignees,
      showUnassigned: _showUnassigned ? true : null,
      dueDateFrom: _dueDateFrom,
      dueDateTo: _dueDateTo,
      createdDateFrom: _createdDateFrom,
      createdDateTo: _createdDateTo,
      type: _selectedType,
    );

    final results = _searchService.search(_searchController.text, ref, filters: filters);
    
    setState(() {
      _results = results;
      _isLoading = false;
    });
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _FilterModal(
        searchService: _searchService,
        selectedCategories: _selectedCategories,
        selectedStatuses: _selectedStatuses,
        selectedTags: _selectedTags,
        selectedAssignees: _selectedAssignees,
        showUnassigned: _showUnassigned,
        selectedType: _selectedType,
        onFiltersChanged: (categories, statuses, tags, assignees, showUnassigned, type) {
          setState(() {
            _selectedCategories = categories;
            _selectedStatuses = statuses;
            _selectedTags = tags;
            _selectedAssignees = assignees;
            _showUnassigned = showUnassigned;
            _selectedType = type;
          });
          _performSearch();
        },
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _selectedCategories.clear();
      _selectedStatuses.clear();
      _selectedTags.clear();
      _selectedAssignees.clear();
      _showUnassigned = false;
      _selectedType = null;
      _dueDateFrom = null;
      _dueDateTo = null;
      _createdDateFrom = null;
      _createdDateTo = null;
    });
    _performSearch();
  }

  bool get _hasActiveFilters => 
    _selectedCategories.isNotEmpty ||
    _selectedStatuses.isNotEmpty ||
    _selectedTags.isNotEmpty ||
    _selectedAssignees.isNotEmpty ||
    _showUnassigned ||
    _selectedType != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      backgroundColor: AppColors.backgroundColor,
      body: Column(
        children: [
          // Search bar and filters
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search projects, ${AppStrings.snags()}, descriptions...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _results.clear();
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                ),
                const SizedBox(height: 12),
                // Filter chips
                Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            FilterChip(
                              label: Text('Filters${_hasActiveFilters ? ' (${_getActiveFilterCount()})' : ''}'),
                              selected: _hasActiveFilters,
                              onSelected: (_) => _showFilterModal(),
                              backgroundColor: Colors.grey[100],
                              selectedColor: AppColors.primaryBlue.withOpacity(0.2),
                            ),
                            if (_hasActiveFilters) ... [
                              const SizedBox(width: 8),
                              ActionChip(
                                label: const Text('Clear'),
                                onPressed: _clearFilters,
                                backgroundColor: Colors.grey[100],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Results
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _searchController.text.isEmpty && !_hasActiveFilters
                    ? _buildEmptyState()
                    : _results.isEmpty
                        ? _buildNoResults()
                        : _buildResults(),
          ),
        ],
      ),
    );
  }

  int _getActiveFilterCount() {
    return _selectedCategories.length + 
           _selectedStatuses.length + 
           _selectedTags.length + 
           _selectedAssignees.length +
           (_showUnassigned ? 1 : 0) +
           (_selectedType != null ? 1 : 0);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'Search across all Projects and ${AppStrings.snags()}',
            style: const TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            'Find anything by name, description, or content',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No results found',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    return ListView.builder(
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final result = _results[index];
        return _SearchResultCard(result: result);
      },
    );
  }
}

class _SearchResultCard extends ConsumerWidget {
  final SearchResult result;
  
  const _SearchResultCard({required this.result});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        // Navigate to detail page based on type
        if (result.type == SearchResultType.project) {
          // navigate to project detail
          final project = result.data as Project;
          Navigator.push(context, MaterialPageRoute(
            builder: (context) => ProjectDetail(projectId: project.uuid)));
        } else if (result.type == SearchResultType.snag) {
          final snag = result.data as Snag;
          // find the parent project
          final List<Project> projects = ProjectService.getProjects(ref);
          final Project project = projects.firstWhere((p) => p.uuid == snag.projectId);
          Navigator.push(context, MaterialPageRoute(
            builder: (context) => SnagDetail(projectId: project.uuid, snagId: snag.uuid, onStatusChanged: () {
              ProjectService.updateProject(ref, project);
            },)));
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              spreadRadius: 2,
              offset: const Offset(0, 0),
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Row(
            children: [
              // Type icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: result.type == SearchResultType.project 
                      ? AppColors.primaryBlue.withOpacity(0.1)
                      : AppColors.ctaOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  result.type == SearchResultType.project 
                      ? Icons.folder_outlined
                      : Icons.bug_report_outlined,
                  color: result.type == SearchResultType.project 
                      ? AppColors.primaryBlue
                      : AppColors.ctaOrange,
                ),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (result.subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        result.subtitle!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // Status chip
                        if (result.status != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: (result.status!.color ?? Colors.blue).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              result.status!.name,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ),
                        const SizedBox(width: 8),
                        // Type badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            result.type == SearchResultType.project ? 'Project' : 'Snag',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.black38),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterModal extends ConsumerStatefulWidget {
  final SearchService searchService;
  final List<Category> selectedCategories;
  final List<Status> selectedStatuses;
  final List<Tag> selectedTags;
  final List<String> selectedAssignees;
  final bool showUnassigned;
  final SearchResultType? selectedType;
  final Function(List<Category>, List<Status>, List<Tag>, List<String>, bool, SearchResultType?) onFiltersChanged;

  const _FilterModal({
    required this.searchService,
    required this.selectedCategories,
    required this.selectedStatuses,
    required this.selectedTags,
    required this.selectedAssignees,
    required this.showUnassigned,
    required this.selectedType,
    required this.onFiltersChanged,
  });

  @override
  ConsumerState<_FilterModal> createState() => _FilterModalState();
}

class _FilterModalState extends ConsumerState<_FilterModal> {
  late List<Category> _categories;
  late List<Status> _statuses;
  late List<Tag> _tags;
  late List<String> _assignees;
  late bool _showUnassigned;
  late SearchResultType? _type;

  @override
  void initState() {
    super.initState();
    _categories = List.from(widget.selectedCategories);
    _statuses = List.from(widget.selectedStatuses);
    _tags = List.from(widget.selectedTags);
    _assignees = List.from(widget.selectedAssignees);
    _showUnassigned = widget.showUnassigned;
    _type = widget.selectedType;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filters',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  widget.onFiltersChanged(_categories, _statuses, _tags, _assignees, _showUnassigned, _type);
                  Navigator.pop(context);
                },
                child: const Text('Apply'),
              ),
            ],
          ),
          const Divider(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type filter
                  const Text('Type', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      FilterChip(
                        label: const Text('Projects'),
                        selected: _type == SearchResultType.project,
                        onSelected: (selected) {
                          setState(() {
                            _type = selected ? SearchResultType.project : null;
                          });
                        },
                      ),
                      FilterChip(
                        label: Text(AppStrings.snags()),
                        selected: _type == SearchResultType.snag,
                        onSelected: (selected) {
                          setState(() {
                            _type = selected ? SearchResultType.snag : null;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Status filter
                  const Text('Status', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: widget.searchService.getAllStatuses().map((status) {
                      return FilterChip(
                        label: Text(status.name),
                        selected: _statuses.contains(status),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _statuses.add(status);
                            } else {
                              _statuses.remove(status);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  // Categories filter
                  const Text('Categories', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: widget.searchService.getAllCategories(ref).map((category) {
                      return FilterChip(
                        label: Text(category.name),
                        selected: _categories.any((c) => c.name == category.name),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _categories.add(category);
                            } else {
                              _categories.removeWhere((c) => c.name == category.name);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  // Tags filter
                  const Text('Tags', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: widget.searchService.getAllTags(ref).map((tag) {
                      return FilterChip(
                        label: Text(tag.name),
                        selected: _tags.any((t) => t.name == tag.name),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _tags.add(tag);
                            } else {
                              _tags.removeWhere((t) => t.name == tag.name);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  // Assignees filter
                  const Text('Assignees', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  // Unassigned toggle
                  FilterChip(
                    label: const Text('Unassigned'),
                    selected: _showUnassigned,
                    onSelected: (selected) {
                      setState(() {
                        _showUnassigned = selected;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  // Assignee chips
                  Wrap(
                    spacing: 8,
                    children: widget.searchService.getAllAssignees(ref).map((assignee) {
                      return FilterChip(
                        label: Text(assignee),
                        selected: _assignees.contains(assignee),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _assignees.add(assignee);
                            } else {
                              _assignees.remove(assignee);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}