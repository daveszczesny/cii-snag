import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class SimpleImageEditor extends StatefulWidget {
  final String imagePath;
  final Function(String) onSave;

  const SimpleImageEditor({super.key, required this.imagePath, required this.onSave});

  @override
  State<SimpleImageEditor> createState() => _SimpleImageEditorState();
}

class _SimpleImageEditorState extends State<SimpleImageEditor> {
  final GlobalKey _repaintKey = GlobalKey();
  final List<Offset> _points = [];
  Color _selectedColor = Colors.red;
  double _strokeWidth = 3.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Toolbar
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.save, color: Colors.green),
                onPressed: _saveImage,
              ),
              const SizedBox(width: 16),
              ...Colors.primaries.take(5).map((color) => 
                GestureDetector(
                  onTap: () => setState(() => _selectedColor = color),
                  child: Container(
                    width: 30,
                    height: 30,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: _selectedColor == color 
                        ? Border.all(width: 3, color: Colors.black) 
                        : null,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Canvas
        Expanded(
          child: Container(
            color: Colors.white,
            child: RepaintBoundary(
              key: _repaintKey,
              child: Stack(
                children: [
                  Image.file(
                    File(widget.imagePath),
                    fit: BoxFit.contain,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                  GestureDetector(
                    onPanUpdate: (details) {
                      setState(() {
                        _points.add(details.localPosition);
                      });
                    },
                    onPanEnd: (details) {
                      _points.add(Offset.infinite);
                    },
                    child: CustomPaint(
                      painter: SimplePainter(_points, _selectedColor, _strokeWidth),
                      size: Size.infinite,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _saveImage() async {
    try {
      RenderRepaintBoundary boundary = _repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 1.0);
      
      // Convert to PNG manually to avoid compression artifacts
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      canvas.drawImage(image, Offset.zero, Paint());
      final picture = recorder.endRecording();
      final finalImage = await picture.toImage(image.width, image.height);
      
      ByteData? byteData = await finalImage.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData != null) {
        final directory = Directory.systemTemp;
        final file = File('${directory.path}/${DateTime.now().millisecondsSinceEpoch}.png');
        await file.writeAsBytes(byteData.buffer.asUint8List());
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image saved!')),
        );
        
        widget.onSave(file.path);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}

class SimplePainter extends CustomPainter {
  final List<Offset> points;
  final Color color;
  final double strokeWidth;

  SimplePainter(this.points, this.color, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth
      ..isAntiAlias = true;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != Offset.infinite && points[i + 1] != Offset.infinite) {
        canvas.drawLine(points[i], points[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}