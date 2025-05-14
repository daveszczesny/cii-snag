import 'package:cii/controllers/single_project_controller.dart';
import 'package:cii/models/project.dart';
import 'package:cii/utils/colors/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

Widget buildTextDetail(String label, String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            fontFamily: 'Roboto',
          ),
        ),
        const SizedBox(height: 12.0),
        Text(
          text,
          style: const TextStyle(
            color: Color(0xFF333333),
            fontSize: 16,
            fontWeight: FontWeight.w300,
            fontFamily: 'Roboto',
          ),
        )
      ],
    );
}

Widget buildTextInput(
  String label,
  String hintText,
  TextEditingController controller,
  {bool optional = true}
) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                fontFamily: 'Roboto',
              ),
            ),
            if (!optional)
              const Text(
                ' *',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Roboto',
                ),
              ),
          ],
        ),
        const SizedBox(height: 12.0),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
              color: Color(0xFF333333),
              fontSize: 16,
              fontWeight: FontWeight.w300,
              fontFamily: 'Roboto',
            ),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF333333)),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF333333)),
            ),
          ),
        ),
      ],
    );
}

Widget buildLongTextInput(label, hintText, controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            fontFamily: 'Roboto',
          ),
        ),
        const SizedBox(height: 12.0),
        TextField(
          controller: controller,
          maxLines: null,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
              color: Color(0xFF333333),
              fontSize: 16,
              fontWeight: FontWeight.w300,
              fontFamily: 'Roboto',
            ),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF333333)),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF333333)),
            ),
          ),
        ),
      ],
    );
}

Widget buildDropdownInput(String label, List<String> options, TextEditingController controller) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize:20,
          fontWeight: FontWeight.w600,
          fontFamily: 'Roboto',
        ),
      ),
      const SizedBox(height: 12.0),
      // i want to show the dropdown with the options from the list
      DropdownButtonFormField<String>(
        value: controller.text.isEmpty ? null : controller.text,
        items: options.map((String option) {
          return DropdownMenuItem(
            value: option,
            child: Text(option),
          );
        }).toList(),
        onChanged: (String? value) {
          controller.text = value ?? '';
        },
        decoration: InputDecoration(
          hintText: 'Select $label',
          hintStyle: const TextStyle(
            color: Color(0xFF333333),
            fontSize: 16,
            fontWeight: FontWeight.w300,
            fontFamily: 'Roboto',
          ),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF333333)),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF333333)),
          ),
        ),
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
      Text(
        label,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: 'Roboto',
        ),
      ),
      const SizedBox(height: 12.0),
      DropdownButtonFormField<Project>(
        value: selectedProject,
        items: options.map((Project option) {
          return DropdownMenuItem<Project>(
            value: option,
            child: Text(option.name),
          );
        }).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Select $label',
          hintStyle: const TextStyle(
            color: Color(0xFF333333),
            fontSize: 16,
            fontWeight: FontWeight.w300,
            fontFamily: 'Roboto',
          ),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF333333)),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF333333)),
          ),
        ),
      ),
    ],
  );
}


// This function creates a button with the given label and onPressed callback.
Widget buildTextButton(
  String label,
  VoidCallback onPressed
) {
  return SizedBox(
    width: double.infinity,
    child: TextButton(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(AppColors.createButtonColor),
        foregroundColor: WidgetStateProperty.all(Colors.black),
      ),
      onPressed: onPressed,
      child: Text(label),
    ),
  );
}