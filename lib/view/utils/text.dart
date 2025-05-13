import 'package:flutter/material.dart';

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

Widget buildTextInput(label, hintText, controller) {
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