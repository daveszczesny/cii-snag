import 'package:cii/models/project.dart';
import 'package:cii/utils/colors/app_colors.dart';
import 'package:cii/utils/common.dart';
import 'package:flutter/material.dart';


Widget buildTextDetail(String label, String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF333333), fontSize: 14, fontWeight: FontWeight.w300, fontFamily: 'Roboto')),
        const SizedBox(height: 6.0),
        Text(text, style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w400, fontFamily: 'Roboto'))
      ],
    );
}

Widget buildTextDetailWithIcon(String label, String text, Icon? icon, {String subtext = '',  Color subtextColor = const Color(0xFF333333)}) {
  return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(color: Color(0xFF333333), fontSize: 14, fontWeight: FontWeight.w300, fontFamily: 'Roboto')),
            if (icon != null) ...[
              const SizedBox(width: 8.0),
              icon,
            ],
            if (subtext.isNotEmpty) ...[
              const SizedBox(width: 8.0),
              Text(subtext, style: TextStyle(color: subtextColor, fontSize: 12, fontWeight: FontWeight.w300, fontFamily: 'Roboto')),
            ]
          ],
        ),
        const SizedBox(height: 6.0),
        Text(text, style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w400, fontFamily: 'Roboto'))
      ],
    );
}

Widget buildJustifiedTextDetail(String label, String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF333333), fontSize: 14, fontWeight: FontWeight.w300, fontFamily: 'Roboto')),
        const SizedBox(height: 6.0),
        Text(text, style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w400, fontFamily: 'Roboto'), textAlign: TextAlign.justify)
      ],
    );
}

Widget buildEditableTextDetail(BuildContext context, String label, String text, TextEditingController controller, {VoidCallback? onChanged}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(color: Color(0xFF333333), fontSize: 14, fontWeight: FontWeight.w300, fontFamily: 'Roboto')),
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(text, style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w400, fontFamily: 'Roboto')),
          ),
          IconButton(
            icon: const Icon(Icons.edit, size: 20),
            onPressed: () async {
              controller.text = text;
              controller.selection = TextSelection(baseOffset: 0, extentOffset: text.length);
              final result = await showDialog<String>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Edit $label'),
                    content: TextField(controller: controller, autofocus: true),
                    actions: [
                      TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
                      TextButton(onPressed: () => Navigator.of(context).pop(controller.text), child: const Text('Save')),
                    ],
                  );
                },
              );
              if (result != null && result != text) {
                controller.text = result;
                if (onChanged != null) onChanged();
              }
            },
          ),
        ],
      ),
    ],
  );
}

Widget buildTextInput(String label, String hintText, TextEditingController controller, {bool optional = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(color: Color(0xFF333333), fontSize: 14, fontWeight: FontWeight.w300, fontFamily: 'Roboto')),
            if (!optional) const Text(' *',style: TextStyle(color: Colors.red, fontSize: 20, fontWeight: FontWeight.w600, fontFamily: 'Roboto')),
          ],
        ),
        TextField(
          controller: controller,
          style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w400, fontFamily: 'Roboto'),
          decoration: InputDecoration(
            hintText: hintText, hintStyle: const TextStyle(color: Color(0xFF333333), fontSize: 14, fontWeight: FontWeight.w300, fontFamily: 'Roboto'),
            enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF333333))),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF333333))),
          ),
        ),
      ],
    );
}

Widget buildDatePickerInput(BuildContext context, String label, String hintText, TextEditingController controller, {bool optional = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(color: Color(0xFF333333), fontSize: 14, fontWeight: FontWeight.w300, fontFamily: 'Roboto')),
            if (!optional) const Text(' *',style: TextStyle(color: Colors.red, fontSize: 20, fontWeight: FontWeight.w600, fontFamily: 'Roboto')),
          ],
        ),
        TextField(
          controller: controller,
          style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w400, fontFamily: 'Roboto'),
          decoration: InputDecoration(
            hintText: hintText, hintStyle: const TextStyle(color: Color(0xFF333333), fontSize: 14, fontWeight: FontWeight.w300, fontFamily: 'Roboto'),
            enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF333333))),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF333333))),
          ),
          onTap: () async {
            FocusScope.of(context).requestFocus(FocusNode());
            DateTime? selectedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.utc(DateTime.now().year, DateTime.now().month, DateTime.now().day),
              lastDate: DateTime.utc(DateTime.now().year + 20, 12, 31),
            );
            if (selectedDate != null) {
              controller.text = formatDate(selectedDate);
            }
          }
        ),
      ],
    );
}

Widget buildLongTextInput(label, hintText, controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF333333), fontSize: 14, fontWeight: FontWeight.w300, fontFamily: 'Roboto')),
        const SizedBox(height: 8.0),
        TextField(
          controller: controller,
          maxLines: null,
          style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w400, fontFamily: 'Roboto'),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Color(0xFF333333), fontSize: 14, fontWeight: FontWeight.w300, fontFamily: 'Roboto'),
            enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF333333), width: 0.5)),
            focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF333333), width: 0.5)),
          ),
        ),
      ],
    );
}

Widget buildDropdownInput(String label, List<String> options, TextEditingController controller) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(color: Color(0xFF333333), fontSize: 14, fontWeight: FontWeight.w300, fontFamily: 'Roboto')),
      const SizedBox(height: 12.0),
      DropdownButtonFormField<String>(
        value: controller.text.isEmpty ? null : controller.text,
        items: options.map((String option) {
          return DropdownMenuItem(value: option, child: Text(option));
        }).toList(),
        onChanged: (String? value) { controller.text = value ?? ''; },
        decoration: InputDecoration(
          hintText: 'Select $label',
          hintStyle: const TextStyle(color: Color(0xFF333333), fontSize: 14, fontWeight: FontWeight.w300, fontFamily: 'Roboto'),
          enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF333333))),
          focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF333333))),
        ),
      ),
    ],
  );
}

Widget buildCustomSegmentedControl({
  required String label,
  required List<String> options,
  required ValueNotifier<String> selectedNotifier,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(color: Color(0xFF333333), fontSize: 14, fontWeight: FontWeight.w300, fontFamily: 'Roboto')),
      const SizedBox(height: 12.0),
      Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400, width: 1),
          borderRadius: BorderRadius.circular(30),
        ),
        child: ValueListenableBuilder<String>(
          valueListenable: selectedNotifier,
          builder: (context, value, _) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(options.length, (index) {
                final isSelected = value == options[index];
                return Expanded(
                  child: GestureDetector(
                    onTap: () => selectedNotifier.value = options[index],
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue : Colors.transparent,
                        borderRadius: BorderRadius.horizontal(
                          left: index == 0 ? const Radius.circular(30) : Radius.zero,
                          right: index == options.length - 1 ? const Radius.circular(30) : Radius.zero,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        options[index],
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                          fontFamily: 'Roboto',
                        ),
                      ),
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ),
    ],
  );
}

// TODO: Remove this function
Widget buildSegmentedControl({
  required String label,
  required List<String> options,
  required ValueNotifier<String> selectedNotifier,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, fontFamily: 'Roboto')),
      const SizedBox(height: 12.0),
      ValueListenableBuilder<String>(
        valueListenable: selectedNotifier,
        builder: (context, value, _) {
          return SegmentedButton<String>(
            segments: options.map((e) => ButtonSegment(
              value: e,
              label: Text(
                e,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w300, fontFamily: 'Roboto'),
              ),
            )).toList(),
            selected: {value},
            onSelectionChanged: (Set<String> newSelection) {
              selectedNotifier.value = newSelection.first;
            },
            showSelectedIcon: false,
            style: ButtonStyle(
              side: WidgetStateProperty.all(BorderSide.none),
              // padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30), // Large value for pill shape
                ),
              ),
              backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.blue;
                }
                return null;
              }),
              foregroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.white;
                }
                return null;
              }),
            ),
          );
        },
      ),
    ],
  );
}


Widget buildDropdownInputForObjects({
  required String label,
  required List<Project> options,
  required Project? selectedProject,
  required ValueChanged<Project?> onChanged,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, fontFamily: 'Roboto')),
      const SizedBox(height: 12.0),
      DropdownButtonFormField<Project>(
        value: selectedProject,
        items: options.map((Project option) {
          return DropdownMenuItem<Project>(value: option, child: Text(option.name));
        }).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Select $label',
          hintStyle: const TextStyle(color: Color(0xFF333333), fontSize: 16, fontWeight: FontWeight.w300, fontFamily: 'Roboto'),
          enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF333333))),
          focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF333333))),
        ),
      ),
    ],
  );
}

// This function creates a button with the given label and onPressed callback.
Widget buildTextButton(String label, VoidCallback onPressed) {
  return SizedBox(
    width: double.infinity,
    child: TextButton(style: ButtonStyle(backgroundColor: WidgetStateProperty.all(AppColors.createButtonColor),
      foregroundColor: WidgetStateProperty.all(Colors.black)), onPressed: onPressed, child: Text(label)),
  );
}