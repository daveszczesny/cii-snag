import 'package:cii/controllers/single_project_controller.dart';
import 'package:cii/controllers/snag_controller.dart';
import 'package:cii/models/status.dart';
import 'package:flutter/material.dart';

class SnagDetail extends StatefulWidget {
  final SingleProjectController projectController;
  final SnagController snag;
  final VoidCallback? onStatusChanged;

  const SnagDetail({super.key, required this.projectController, required this.snag, this.onStatusChanged});

  @override
  State<SnagDetail> createState() => _SnagDetailState();
}

class _SnagDetailState extends State<SnagDetail> {

  @override
  void initState() {
    super.initState();
  }

  void _showStatusModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: FractionallySizedBox(
            heightFactor: 0.7,
            child: Column(
              children: Status.values
              // .where((status) => status.name.toLowerCase() != 'completed')
              .map((status) {
                return ListTile(
                  title: Text(status.name),
                  onTap: () {
                    setState(() {
                      widget.snag.status = status;
                    });
                    widget.onStatusChanged!();
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            )
          )
        );
      },
    );
  }

  void _showCategoryModal(BuildContext context) {
    showModalBottomSheet(
      context: context, 
      builder: (BuildContext context) {
        final categories = widget.projectController.getCategories!;
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: FractionallySizedBox(
            heightFactor: 0.7,
            child: ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                return ListTile(
                  title: Text(cat.name),
                  onTap: () {
                    setState(() {
                      widget.snag.setCategory(cat);
                    });
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      }
    );
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.snag.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(38.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.snag.getId != '') ... [
                    Text('ID: ${widget.snag.getId}'),
                    const SizedBox(height: 28.0)
                  ],
                  if (widget.snag.name != '') ...[
                    Text('Name: ${widget.snag.name}'),
                    const SizedBox(height: 28.0)
                  ],
                  if (widget.snag.location != '') ... [
                    Text('Location: ${widget.snag.location}'),
                    const SizedBox(height: 28.0)
                  ],

                  GestureDetector(
                    onTap: () => _showStatusModal(context),
                    child: Container(
                      width: 90,
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: Status.getStatus(widget.snag.status.name, context)!.color,
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        widget.snag.status.name,
                        style: const TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                          fontFamily: 'Roboto',
                        )
                      )
                    )
                  ),

                  if (widget.snag.categories.isNotEmpty) ... [
                    const Text('Category'),
                    const SizedBox(height: 8.0),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: widget.snag.categories.map((cat) {
                        return GestureDetector(
                          onTap: () => _showCategoryModal(context),
                          child: Container(
                            constraints: const BoxConstraints(
                              minWidth: 90,
                              maxWidth: 140,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                            decoration: BoxDecoration(
                              color: cat.color,
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              cat.name,
                              style: const TextStyle(
                                fontSize: 12.0,
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                                fontFamily: 'Roboto',
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            )
                          )
                        );
                    }).toList()),
                    const SizedBox(height: 28.0)
                  ],

                  if (widget.snag.tags.isNotEmpty) ... [
                    const Text('Tags'),
                    const SizedBox(height: 8.0),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: widget.snag.tags.map((tag) {
                        return GestureDetector(
                          onTap: () => {},
                          child: Container(
                            constraints: const BoxConstraints(
                              minWidth: 90,
                              maxWidth: 140,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                            decoration: BoxDecoration(
                              color: tag.color,
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              tag.name,
                              style: const TextStyle(
                                fontSize: 12.0,
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                                fontFamily: 'Roboto',
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            )
                          )
                        );
                    }).toList()),
                    const SizedBox(height: 28.0)
                  ],

                  if (widget.snag.assignee != '') ... [
                    Text('Assignee: ${widget.snag.assignee}'),
                    const SizedBox(height: 28.0)
                  ],
                  if (widget.snag.finalRemarks != '') ... [
                    Text('Final Remarks: ${widget.snag.finalRemarks}'),
                    const SizedBox(height: 28.0)
                  ],
                ],
              ),
            )
          ]
        )
      ),
    );
  }
}