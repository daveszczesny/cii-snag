import 'package:cii/controllers/snag_controller.dart';
import 'package:cii/models/status.dart';
import 'package:cii/utils/colors/app_colors.dart';
import 'package:cii/view/utils/constants.dart';
import 'package:flutter/material.dart';

class SnagCardWidget extends StatefulWidget {
  final SnagController snagController;
  final VoidCallback onStatusChanged;

  const SnagCardWidget({
    super.key,
    required this.snagController,
    required this.onStatusChanged,
  });

  @override
  State<SnagCardWidget> createState() => _SnagCardWidgetState();
}

class _SnagCardWidgetState extends State<SnagCardWidget> {

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
                      widget.snagController.status = status;
                    });
                    widget.onStatusChanged();
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
      },
      child: Container(
        height: 110,
        child: Card(
          color: AppColors.cardColor,
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  color: Colors.grey,
                  child: const Icon(Icons.image, color: Colors.white),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            widget.snagController.priority.icon,
                            width: 16.0,
                            height: 16.0,
                          ),
                          const SizedBox(width: 8.0),
                          Expanded(
                            child: Text(
                              widget.snagController.name,
                              style: const TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryGreen,
                                fontFamily: 'Roboto',
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8.0),
                      GestureDetector(
                        onTap: () => _showStatusModal(context),
                        child: Container(
                          width: 90,
                          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                          decoration: BoxDecoration(
                            color: Status.getStatus(widget.snagController.status.name, context)!.color,
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            widget.snagController.status.name,
                            style: const TextStyle(
                              fontSize: 12.0,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                              fontFamily: 'Roboto',
                            )
                          )
                        )
                      )
                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        // Handle menu actions
                      },
                      // Quick actions for a selected project
                      itemBuilder: (BuildContext context) {
                        return const [
                          PopupMenuItem<String>(
                            value: 'View snag',
                            child: Text(AppStrings.viewSnag),
                          ),
                          PopupMenuItem<String>(
                            value: 'Share snag',
                            child: Text(AppStrings.shareSnag),
                          ),
                          PopupMenuItem<String>(
                            value: 'Edit snag',
                            child: Text(AppStrings.editSnag),
                          ),
                          PopupMenuDivider(
                            height: 1.0,
                          ),
                          PopupMenuItem<String>(
                            value: 'Delete snag',
                            child: Text(AppStrings.deleteSnag, style: TextStyle(color: AppColors.red)),
                          ),
                        ];
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}