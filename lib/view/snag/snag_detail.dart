import 'package:cii/controllers/single_project_controller.dart';
import 'package:cii/controllers/snag_controller.dart';
import 'package:flutter/material.dart';

class SnagDetail extends StatefulWidget {
  final SingleProjectController projectController;
  final SnagController snag;

  const SnagDetail({super.key, required this.projectController, required this.snag});

  @override
  State<SnagDetail> createState() => _SnagDetailState();
}

class _SnagDetailState extends State<SnagDetail> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(38.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.snag.getId != '') ... {
            Text('ID: ${widget.snag.getId}'),
            const SizedBox(height: 28.0)
          },
          if (widget.snag.name != '') ...{
            Text('Name: ${widget.snag.name}'),
            const SizedBox(height: 28.0)
          },
          if (widget.snag.location != '') ... {
            Text('Location: ${widget.snag.location}'),
            const SizedBox(height: 28.0)
          },
          if (widget.snag.assignee != '') ... {
            Text('Assignee: ${widget.snag.assignee}'),
            const SizedBox(height: 28.0)
          },
          if (widget.snag.finalRemarks != '') ... {
            Text('Final Remarks: ${widget.snag.finalRemarks}'),
            const SizedBox(height: 28.0)
          },
        ],
      ),
    );
  }
}