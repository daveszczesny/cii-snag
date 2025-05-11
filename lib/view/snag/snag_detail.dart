import 'package:cii/controllers/snag_controller.dart';
import 'package:flutter/material.dart';

class SnagDetail extends StatefulWidget {
  final SnagController snag;

  const SnagDetail({super.key, required this.snag});

  @override
  State<SnagDetail> createState() => _SnagDetailState();
}

class _SnagDetailState extends State<SnagDetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}