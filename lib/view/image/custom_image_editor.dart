import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

class CustomImageEditor extends StatefulWidget {
  final String imagePath;
  final Function(String) onSave;

  const CustomImageEditor({super.key, required this.imagePath, required this.onSave});

  @override
  State<CustomImageEditor> createState() => _CustomImageEditorState();
}

enum DrawingTool { draw, text, line, arrow, circle, rectangle }

enum TextEditMode { none, moving, scaling, editing }

class Shape {
  final Offset start;
  final Offset end;
  final Color color;
  final double strokeWidth;
  final DrawingTool type;
  
  Shape(this.start, this.end, this.color, this.strokeWidth, this.type);
}

class EditorState {
  final List<DrawingPoint> points;
  final List<TextAnnotation> textAnnotations;
  final List<Shape> shapes;
  
  EditorState(this.points, this.textAnnotations, this.shapes);
  
  EditorState copy() {
    return EditorState(
      List<DrawingPoint>.from(points.map((p) => DrawingPoint(p.offset, p.color, p.strokeWidth))),
      List<TextAnnotation>.from(textAnnotations.map((t) => TextAnnotation(
        t.position, t.text, t.color, 
        fontSize: t.fontSize, 
        fontWeight: t.fontWeight,
        fontStyle: t.fontStyle,
      ))),
      List<Shape>.from(shapes.map((s) => Shape(s.start, s.end, s.color, s.strokeWidth, s.type))),
    );
  }
}

class _CustomImageEditorState extends State<CustomImageEditor> {
  final GlobalKey _repaintKey = GlobalKey();
  final List<DrawingPoint> _points = [];
  final List<TextAnnotation> _textAnnotations = [];
  final List<Shape> _shapes = [];
  Color _selectedColor = Colors.red;
  double _strokeWidth = 3.0;
  DrawingTool _currentTool = DrawingTool.draw;
  
  // Text editing state
  int? _selectedTextIndex;
  TextEditMode _textEditMode = TextEditMode.none;
  Offset? _dragStartOffset;
  Offset? _initialTextPosition;
  double _initialFontSize = 16.0;
  Offset? _scaleStartPosition;
  double _scaleSensitivity = 0.5;
  
  // Shape drawing state
  Offset? _shapeStartPoint;
  Offset? _currentShapeEnd;
  
  // Undo/Redo functionality
  final List<EditorState> _history = [];
  int _historyIndex = -1;
  final int _maxHistorySize = 50;

  // Image bounds tracking
  Rect? _imageBounds;
  ui.Image? _loadedImage;

  @override
  void initState() {
    super.initState();
    _saveState();
    _loadImageAndCalculateBounds();
  }

  Future<void> _loadImageAndCalculateBounds() async {
    try {
      _loadedImage = await _loadOriginalImage();
      // Trigger a rebuild to calculate bounds after the widget is built
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _calculateImageBounds();
      });
      setState(() {}); // Trigger rebuild after image is loaded
    } catch (e) {
      print('Error loading image: $e');
    }
  }

  void _calculateImageBounds() {
    if (_loadedImage == null) return;
    
    final RenderBox? renderBox = _repaintKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      // If render box is not ready, try again after next frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _calculateImageBounds();
      });
      return;
    }
    
    final containerSize = renderBox.size;
    final imageWidth = _loadedImage!.width.toDouble();
    final imageHeight = _loadedImage!.height.toDouble();
    
    // Calculate the actual displayed image bounds with BoxFit.contain
    // This ensures the entire image is visible within the container
    final containerAspect = containerSize.width / containerSize.height;
    final imageAspect = imageWidth / imageHeight;
    
    double displayWidth, displayHeight;
    double offsetX, offsetY;
    
    if (containerAspect > imageAspect) {
      // Container is wider than image aspect ratio
      // Image will be constrained by height, centered horizontally
      displayHeight = containerSize.height;
      displayWidth = displayHeight * imageAspect;
      offsetX = (containerSize.width - displayWidth) / 2;
      offsetY = 0;
    } else {
      // Container is taller than image aspect ratio  
      // Image will be constrained by width, centered vertically
      displayWidth = containerSize.width;
      displayHeight = displayWidth / imageAspect;
      offsetX = 0;
      offsetY = (containerSize.height - displayHeight) / 2;
    }
    
    final newBounds = Rect.fromLTWH(offsetX, offsetY, displayWidth, displayHeight);
    
    // Only update if bounds actually changed to avoid unnecessary rebuilds
    if (_imageBounds != newBounds) {
      setState(() {
        _imageBounds = newBounds;
      });
    }
  }

  bool _isPointInImageBounds(Offset point) {
    return _imageBounds?.contains(point) ?? false;
  }

  Offset? _constrainPointToImageBounds(Offset point) {
    if (_imageBounds == null) return point;
    
    if (_imageBounds!.contains(point)) {
      return point;
    }
    
    // Constrain point to image bounds
    return Offset(
      point.dx.clamp(_imageBounds!.left, _imageBounds!.right),
      point.dy.clamp(_imageBounds!.top, _imageBounds!.bottom),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top action buttons
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: Icon(Icons.undo, color: _canUndo() ? Colors.blue : Colors.grey),
                onPressed: _canUndo() ? _undo : null,
                tooltip: 'Undo',
              ),
              IconButton(
                icon: Icon(Icons.redo, color: _canRedo() ? Colors.blue : Colors.grey),
                onPressed: _canRedo() ? _redo : null,
                tooltip: 'Redo',
              ),
              IconButton(
                icon: const Icon(Icons.clear_all, color: Colors.red),
                onPressed: _clearAll,
                tooltip: 'Clear All',
              ),
              IconButton(
                icon: const Icon(Icons.save, color: Colors.green),
                onPressed: _saveImage,
                tooltip: 'Save Image',
              ),
            ],
          ),
        ),
        Expanded(
            child: Container(
              width: double.infinity,
              color: Colors.grey[100],
              padding: const EdgeInsets.all(8),
              child: RepaintBoundary(
                key: _repaintKey,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Recalculate bounds when layout changes
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _calculateImageBounds();
                    });
                    
                    return Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          height: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Image.file(
                            File(widget.imagePath), 
                            fit: BoxFit.contain,
                            alignment: Alignment.center,
                          ),
                        ),
                        Positioned.fill(
                          child: GestureDetector(
                            onPanStart: _onPanStart,
                            onPanUpdate: _onPanUpdate,
                            onPanEnd: _onPanEnd,
                            onTapUp: _onTapUp,
                            child: CustomPaint(
                              painter: DrawingPainter(
                                _points, 
                                _textAnnotations, 
                                _shapes, 
                                _selectedTextIndex,
                                shapeStart: _shapeStartPoint, 
                                currentShapeEnd: _currentShapeEnd, 
                                currentTool: _currentTool, 
                                selectedColor: _selectedColor, 
                                strokeWidth: _strokeWidth,
                                textEditMode: _textEditMode,
                                imageBounds: _imageBounds,
                              ),
                              size: Size.infinite,
                            ),
                          ),
                        ),
                        // Floating text controls overlay
                        if (_selectedTextIndex != null && _currentTool == DrawingTool.text)
                          _buildTextControlsOverlay(),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
          _buildToolbar(),
        ],
    );
  }

  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tool selection row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildToolButton(DrawingTool.draw, Icons.edit, 'Draw'),
              _buildToolButton(DrawingTool.text, Icons.text_fields, 'Text'),
              _buildToolButton(DrawingTool.line, Icons.remove, 'Line'),
              _buildToolButton(DrawingTool.arrow, Icons.arrow_forward, 'Arrow'),
              _buildToolButton(DrawingTool.circle, Icons.circle_outlined, 'Circle'),
              _buildToolButton(DrawingTool.rectangle, Icons.rectangle_outlined, 'Rect'),
            ],
          ),
          const SizedBox(height: 16),
          
          // Color selection
          Row(
            children: [
              const Text('Color: ', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(width: 8),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Black and white first
                      ...[Colors.black, Colors.white].map((color) => 
                        GestureDetector(
                          onTap: () => setState(() => _selectedColor = color),
                          child: Container(
                            width: 36,
                            height: 36,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: _selectedColor == color 
                                ? Border.all(width: 3, color: Colors.blue) 
                                : Border.all(width: 1, color: Colors.grey[300]!),
                            ),
                          ),
                        ),
                      ),
                      // Then primary colors
                      ...Colors.primaries.map((color) => 
                        GestureDetector(
                          onTap: () => setState(() => _selectedColor = color),
                          child: Container(
                            width: 36,
                            height: 36,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: _selectedColor == color 
                                ? Border.all(width: 3, color: Colors.black87) 
                                : Border.all(width: 1, color: Colors.grey[300]!),
                              boxShadow: _selectedColor == color ? [
                                BoxShadow(
                                  color: color.withOpacity(0.3),
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                ),
                              ] : null,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Stroke width slider
          Row(
            children: [
              const Text('Size: ', style: TextStyle(fontWeight: FontWeight.w500)),
              Expanded(
                child: Slider(
                  value: _strokeWidth,
                  min: 1,
                  max: 15,
                  divisions: 14,
                  label: _strokeWidth.round().toString(),
                  activeColor: _selectedColor,
                  onChanged: (value) => setState(() => _strokeWidth = value),
                ),
              ),
              Container(
                width: 40,
                alignment: Alignment.center,
                child: Text(
                  _strokeWidth.round().toString(),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          

        ],
      ),
    );
  }

  Widget _buildTextControlsOverlay() {
    return Positioned(
      bottom: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildCompactButton(
              icon: Icons.edit,
              color: Colors.blue,
              onPressed: _editSelectedText,
            ),
            const SizedBox(height: 4),
            _buildCompactButton(
              icon: Icons.copy,
              color: Colors.green,
              onPressed: _duplicateSelectedText,
            ),
            const SizedBox(height: 4),
            _buildCompactButton(
              icon: Icons.delete,
              color: Colors.red,
              onPressed: _deleteSelectedText,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 40,
      height: 40,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          elevation: 2,
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }

  Widget _buildToolButton(DrawingTool tool, IconData icon, String label) {
    final isSelected = _currentTool == tool;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: isSelected ? _selectedColor.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isSelected ? Border.all(color: _selectedColor, width: 2) : null,
          ),
          child: IconButton(
            onPressed: () => setState(() {
              _currentTool = tool;
              if (tool != DrawingTool.text) {
                _selectedTextIndex = null;
                _textEditMode = TextEditMode.none;
              }
            }),
            icon: Icon(icon, size: 24),
            style: IconButton.styleFrom(
              backgroundColor: isSelected ? _selectedColor.withOpacity(0.1) : Colors.transparent,
              foregroundColor: isSelected ? _selectedColor : Colors.grey[700],
              padding: const EdgeInsets.all(12),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label, 
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? _selectedColor : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  void _onPanStart(DragStartDetails details) {
    final localPosition = details.localPosition;
    
    // Only allow interactions within image bounds
    if (!_isPointInImageBounds(localPosition)) {
      return;
    }
    
    if (_currentTool == DrawingTool.text) {
      _handleTextPanStart(localPosition);
    } else if (_currentTool != DrawingTool.draw) {
      // Shape drawing
      _shapeStartPoint = localPosition;
      _currentShapeEnd = localPosition;
    } else {
      // Free drawing
      _clearTextSelection();
      _points.add(DrawingPoint(localPosition, _selectedColor, _strokeWidth));
    }
  }

  void _handleTextPanStart(Offset position) {
    // Check if we're interacting with the selected text
    if (_selectedTextIndex != null) {
      final textAnnotation = _textAnnotations[_selectedTextIndex!];
      final textBounds = _getTextBounds(textAnnotation);
      
      // Check for scale handles
      final scaleHandles = _getScaleHandles(textBounds);
      for (int i = 0; i < scaleHandles.length; i++) {
        if ((position - scaleHandles[i]).distance < 20) {
          _textEditMode = TextEditMode.scaling;
          _scaleStartPosition = position;
          _initialFontSize = textAnnotation.fontSize;
          return;
        }
      }
      
      // Check if clicking within text bounds for moving
      if (textBounds.contains(position)) {
        _textEditMode = TextEditMode.moving;
        _dragStartOffset = position - textAnnotation.position;
        _initialTextPosition = textAnnotation.position;
        return;
      }
    }
    
    // Check if clicking on any text to select it
    for (int i = 0; i < _textAnnotations.length; i++) {
      final textAnnotation = _textAnnotations[i];
      final textBounds = _getTextBounds(textAnnotation);
      
      if (textBounds.contains(position)) {
        setState(() {
          _selectedTextIndex = i;
          _textEditMode = TextEditMode.moving;
          _dragStartOffset = position - textAnnotation.position;
          _initialTextPosition = textAnnotation.position;
        });
        return;
      }
    }
    
    // Clear selection if clicking elsewhere
    _clearTextSelection();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final localPosition = details.localPosition;
    
    setState(() {
      if (_currentTool == DrawingTool.text && _selectedTextIndex != null) {
        _handleTextPanUpdate(localPosition);
      } else if (_currentTool == DrawingTool.draw) {
        // Only add points within image bounds
        if (_isPointInImageBounds(localPosition)) {
          _points.add(DrawingPoint(localPosition, _selectedColor, _strokeWidth));
        }
      } else if (_shapeStartPoint != null) {
        // Constrain shape end point to image bounds
        _currentShapeEnd = _constrainPointToImageBounds(localPosition);
      }
    });
  }

  void _handleTextPanUpdate(Offset position) {
    if (_selectedTextIndex == null) return;
    
    final textAnnotation = _textAnnotations[_selectedTextIndex!];
    
    if (_textEditMode == TextEditMode.moving && _dragStartOffset != null) {
      // Constrain text position to stay within image bounds
      final newPosition = _constrainPointToImageBounds(position - _dragStartOffset!);
      if (newPosition != null) {
        _textAnnotations[_selectedTextIndex!] = TextAnnotation(
          newPosition,
          textAnnotation.text,
          textAnnotation.color,
          fontSize: textAnnotation.fontSize,
          fontWeight: textAnnotation.fontWeight,
          fontStyle: textAnnotation.fontStyle,
        );
      }
    } else if (_textEditMode == TextEditMode.scaling && _scaleStartPosition != null) {
      final distance = (position - _scaleStartPosition!).distance;
      final scaleFactor = math.max(0.5, math.min(3.0, distance / 100));
      final newFontSize = math.max(8.0, math.min(72.0, _initialFontSize * scaleFactor));
      
      _textAnnotations[_selectedTextIndex!] = TextAnnotation(
        textAnnotation.position,
        textAnnotation.text,
        textAnnotation.color,
        fontSize: newFontSize,
        fontWeight: textAnnotation.fontWeight,
        fontStyle: textAnnotation.fontStyle,
      );
    }
  }

  void _onPanEnd(DragEndDetails details) {
    bool shouldSaveState = false;
    
    if (_shapeStartPoint != null && _currentShapeEnd != null && 
        _currentTool != DrawingTool.draw && _currentTool != DrawingTool.text) {
      setState(() {
        _shapes.add(Shape(_shapeStartPoint!, _currentShapeEnd!, _selectedColor, _strokeWidth, _currentTool));
        _shapeStartPoint = null;
        _currentShapeEnd = null;
      });
      shouldSaveState = true;
    }
    
    if (_textEditMode != TextEditMode.none) {
      shouldSaveState = true;
      _textEditMode = TextEditMode.none;
      _dragStartOffset = null;
      _initialTextPosition = null;
      _scaleStartPosition = null;
    }
    
    if (_currentTool == DrawingTool.draw && _points.isNotEmpty) {
      _points.add(DrawingPoint(Offset.infinite, Colors.transparent, 0));
      shouldSaveState = true;
    }
    
    if (shouldSaveState) {
      _saveState();
    }
  }

  void _onTapUp(TapUpDetails details) {
    final localPosition = details.localPosition;
    
    // Only allow interactions within image bounds
    if (!_isPointInImageBounds(localPosition)) {
      _clearTextSelection();
      return;
    }
    
    if (_currentTool == DrawingTool.text) {
      _handleTextTap(localPosition);
    } else {
      _clearTextSelection();
    }
  }

  void _handleTextTap(Offset position) {
    // Only allow text placement within image bounds
    if (!_isPointInImageBounds(position)) {
      return;
    }
    
    // Check if tapping on existing text
    for (int i = 0; i < _textAnnotations.length; i++) {
      final textAnnotation = _textAnnotations[i];
      final textBounds = _getTextBounds(textAnnotation);
      
      if (textBounds.contains(position)) {
        setState(() => _selectedTextIndex = i);
        return;
      }
    }
    
    // Add new text if tapping empty space within image bounds
    _clearTextSelection();
    _showTextDialog(position);
  }

  // Helper methods
  void _clearTextSelection() {
    setState(() {
      _selectedTextIndex = null;
      _textEditMode = TextEditMode.none;
    });
  }

  void _clearAll() {
    _saveState();
    setState(() {
      _points.clear();
      _textAnnotations.clear();
      _shapes.clear();
      _selectedTextIndex = null;
      _textEditMode = TextEditMode.none;
    });
  }

  Rect _getTextBounds(TextAnnotation textAnnotation) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: textAnnotation.text,
        style: TextStyle(
          fontSize: textAnnotation.fontSize,
          fontWeight: textAnnotation.fontWeight,
          fontStyle: textAnnotation.fontStyle,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    
    return Rect.fromLTWH(
      textAnnotation.position.dx - 8,
      textAnnotation.position.dy - 8,
      textPainter.width + 16,
      textPainter.height + 16,
    );
  }

  List<Offset> _getScaleHandles(Rect bounds) {
    return [
      bounds.topLeft,
      bounds.topRight,
      bounds.bottomLeft,
      bounds.bottomRight,
    ];
  }

  void _editSelectedText() {
    if (_selectedTextIndex == null) return;
    
    final textAnnotation = _textAnnotations[_selectedTextIndex!];
    final controller = TextEditingController(text: textAnnotation.text);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Text'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              autofocus: true,
              maxLines: null,
              decoration: const InputDecoration(
                hintText: 'Enter text...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                _saveState();
                setState(() {
                  _textAnnotations[_selectedTextIndex!] = TextAnnotation(
                    textAnnotation.position,
                    controller.text,
                    textAnnotation.color,
                    fontSize: textAnnotation.fontSize,
                    fontWeight: textAnnotation.fontWeight,
                    fontStyle: textAnnotation.fontStyle,
                  );
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _duplicateSelectedText() {
    if (_selectedTextIndex == null) return;
    
    final textAnnotation = _textAnnotations[_selectedTextIndex!];
    _saveState();
    setState(() {
      _textAnnotations.add(TextAnnotation(
        textAnnotation.position + const Offset(20, 20),
        textAnnotation.text,
        textAnnotation.color,
        fontSize: textAnnotation.fontSize,
        fontWeight: textAnnotation.fontWeight,
        fontStyle: textAnnotation.fontStyle,
      ));
      _selectedTextIndex = _textAnnotations.length - 1;
    });
  }

  void _deleteSelectedText() {
    if (_selectedTextIndex == null) return;
    
    _saveState();
    setState(() {
      _textAnnotations.removeAt(_selectedTextIndex!);
      _selectedTextIndex = null;
      _textEditMode = TextEditMode.none;
    });
  }

  void _showTextDialog(Offset position) {
    final controller = TextEditingController();
    bool isBold = false;
    bool isItalic = false;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Text'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                autofocus: true,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: 'Enter text...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Style: '),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Bold'),
                    selected: isBold,
                    onSelected: (selected) => setDialogState(() => isBold = selected),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Italic'),
                    selected: isItalic,
                    onSelected: (selected) => setDialogState(() => isItalic = selected),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  _saveState();
                  setState(() {
                    _textAnnotations.add(TextAnnotation(
                      position,
                      controller.text,
                      _selectedColor,
                      fontSize: 16,
                      fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                      fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
                    ));
                    _selectedTextIndex = _textAnnotations.length - 1;
                  });
                }
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _saveState() {
    // Remove any states after current index (when undoing then making new changes)
    if (_historyIndex < _history.length - 1) {
      _history.removeRange(_historyIndex + 1, _history.length);
    }
    
    // Add current state
    _history.add(EditorState(_points, _textAnnotations, _shapes).copy());
    _historyIndex = _history.length - 1;
    
    // Limit history size
    if (_history.length > _maxHistorySize) {
      _history.removeAt(0);
      _historyIndex--;
    }
  }
  
  bool _canUndo() => _historyIndex > 0;
  bool _canRedo() => _historyIndex < _history.length - 1;
  
  void _undo() {
    if (_canUndo()) {
      _historyIndex--;
      final state = _history[_historyIndex];
      setState(() {
        _points.clear();
        _points.addAll(List<DrawingPoint>.from(state.points.map((p) => 
          DrawingPoint(p.offset, p.color, p.strokeWidth))));
        _textAnnotations.clear();
        _textAnnotations.addAll(List<TextAnnotation>.from(state.textAnnotations.map((t) => 
          TextAnnotation(t.position, t.text, t.color, 
            fontSize: t.fontSize, 
            fontWeight: t.fontWeight,
            fontStyle: t.fontStyle,
            ))));
        _shapes.clear();
        _shapes.addAll(List<Shape>.from(state.shapes.map((s) => 
          Shape(s.start, s.end, s.color, s.strokeWidth, s.type))));
        _selectedTextIndex = null;
        _textEditMode = TextEditMode.none;
      });
      
      // Provide haptic feedback
      HapticFeedback.lightImpact();
    }
  }
  
  void _redo() {
    if (_canRedo()) {
      _historyIndex++;
      final state = _history[_historyIndex];
      setState(() {
        _points.clear();
        _points.addAll(List<DrawingPoint>.from(state.points.map((p) => 
          DrawingPoint(p.offset, p.color, p.strokeWidth))));
        _textAnnotations.clear();
        _textAnnotations.addAll(List<TextAnnotation>.from(state.textAnnotations.map((t) => 
          TextAnnotation(t.position, t.text, t.color, 
            fontSize: t.fontSize, 
            fontWeight: t.fontWeight,
            fontStyle: t.fontStyle,
            ))));
        _shapes.clear();
        _shapes.addAll(List<Shape>.from(state.shapes.map((s) => 
          Shape(s.start, s.end, s.color, s.strokeWidth, s.type))));
        _selectedTextIndex = null;
        _textEditMode = TextEditMode.none;
      });
      
      // Provide haptic feedback
      HapticFeedback.lightImpact();
    }
  }

  void _saveImage() async {
    try {
      // Clear text selection before saving
      setState(() {
        _selectedTextIndex = null;
        _textEditMode = TextEditMode.none;
      });
      
      // Wait for UI to update
      await Future.delayed(const Duration(milliseconds: 100));
      
      RenderRepaintBoundary boundary = _repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData != null) {
        final directory = Directory.systemTemp;
        final file = File('${directory.path}/${DateTime.now().millisecondsSinceEpoch}.png');
        await file.writeAsBytes(byteData.buffer.asUint8List());
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Image saved!'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        
        widget.onSave(file.path);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<ui.Image> _loadOriginalImage() async {
    final file = File(widget.imagePath);
    final bytes = await file.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return frame.image;
  }
}

class DrawingPoint {
  final Offset offset;
  final Color color;
  final double strokeWidth;
  
  DrawingPoint(this.offset, this.color, this.strokeWidth);
}

class TextAnnotation {
  final Offset position;
  final String text;
  final Color color;
  final double fontSize;
  final FontWeight fontWeight;
  final FontStyle fontStyle;
  
  TextAnnotation(
    this.position, 
    this.text, 
    this.color, {
    this.fontSize = 16,
    this.fontWeight = FontWeight.normal,
    this.fontStyle = FontStyle.normal,
  });
}

class DrawingPainter extends CustomPainter {
  final List<DrawingPoint> points;
  final List<TextAnnotation> textAnnotations;
  final List<Shape> shapes;
  final int? selectedTextIndex;
  final Offset? shapeStart;
  final Offset? currentShapeEnd;
  final DrawingTool currentTool;
  final Color selectedColor;
  final double strokeWidth;
  final TextEditMode textEditMode;
  final Rect? imageBounds;
  
  DrawingPainter(
    this.points, 
    this.textAnnotations, 
    this.shapes, 
    this.selectedTextIndex, {
    this.shapeStart, 
    this.currentShapeEnd, 
    required this.currentTool, 
    required this.selectedColor, 
    required this.strokeWidth,
    required this.textEditMode,
    this.imageBounds,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true
      ..filterQuality = FilterQuality.high;
    
    // Draw image bounds indicator (subtle border)
    if (imageBounds != null) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(imageBounds!, const Radius.circular(2)),
        Paint()
          ..color = Colors.grey.withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }
    
    // Save canvas state before clipping
    canvas.save();
    
    // Clip all drawing operations to image bounds
    if (imageBounds != null) {
      canvas.clipRect(imageBounds!);
    }
    
    // Draw existing shapes
    for (final shape in shapes) {
      paint.color = shape.color;
      paint.strokeWidth = shape.strokeWidth;
      _drawShape(canvas, shape, paint);
    }
    
    // Draw current shape being drawn (preview)
    if (shapeStart != null && currentShapeEnd != null && 
        currentTool != DrawingTool.draw && currentTool != DrawingTool.text) {
      paint.color = selectedColor.withOpacity(0.7);
      paint.strokeWidth = strokeWidth;
      paint.style = PaintingStyle.stroke;
      final previewShape = Shape(shapeStart!, currentShapeEnd!, selectedColor, strokeWidth, currentTool);
      _drawShape(canvas, previewShape, paint);
    }
    
    // Draw free drawing points
    _drawFreeDrawing(canvas, paint);
    
    // Restore canvas state (remove clipping for text annotations)
    canvas.restore();
    
    // Draw text annotations (without clipping so selection handles can show outside bounds)
    _drawTextAnnotations(canvas);
  }

  void _drawFreeDrawing(Canvas canvas, Paint paint) {
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i].offset != Offset.infinite && points[i + 1].offset != Offset.infinite) {
        paint.color = points[i].color;
        paint.strokeWidth = points[i].strokeWidth;
        paint.style = PaintingStyle.stroke;
        canvas.drawLine(points[i].offset, points[i + 1].offset, paint);
      }
    }
  }

  void _drawTextAnnotations(Canvas canvas) {
    for (int i = 0; i < textAnnotations.length; i++) {
      final textAnnotation = textAnnotations[i];
      final isSelected = selectedTextIndex == i;
      
      // Create text painter
      final textPainter = TextPainter(
        text: TextSpan(
          text: textAnnotation.text,
          style: TextStyle(
            color: textAnnotation.color,
            fontSize: textAnnotation.fontSize,
            fontWeight: textAnnotation.fontWeight,
            fontStyle: textAnnotation.fontStyle,
            shadows: [
              Shadow(
                offset: const Offset(1, 1),
                blurRadius: 2,
                color: Colors.black.withOpacity(0.3),
              ),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      

      
      // Draw selection indicators
      if (isSelected) {
        _drawTextSelection(canvas, textAnnotation, textPainter);
      }
      
      // Draw the text
      textPainter.paint(canvas, textAnnotation.position);
    }
  }

  void _drawTextSelection(Canvas canvas, TextAnnotation textAnnotation, TextPainter textPainter) {
    final padding = 12.0;
    final rect = Rect.fromLTWH(
      textAnnotation.position.dx - padding,
      textAnnotation.position.dy - padding,
      textPainter.width + padding * 2,
      textPainter.height + padding * 2,
    );
    
    // Selection background
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(8)),
      Paint()
        ..color = Colors.blue.withOpacity(0.1)
        ..style = PaintingStyle.fill,
    );
    
    // Selection border
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(8)),
      Paint()
        ..color = Colors.blue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    
    // Corner handles for scaling
    final handleSize = 16.0;
    final handles = [
      Rect.fromCenter(center: rect.topLeft, width: handleSize, height: handleSize),
      Rect.fromCenter(center: rect.topRight, width: handleSize, height: handleSize),
      Rect.fromCenter(center: rect.bottomLeft, width: handleSize, height: handleSize),
      Rect.fromCenter(center: rect.bottomRight, width: handleSize, height: handleSize),
    ];
    
    for (final handle in handles) {
      // Handle background
      canvas.drawRRect(
        RRect.fromRectAndRadius(handle, const Radius.circular(4)),
        Paint()..color = Colors.white,
      );
      // Handle border
      canvas.drawRRect(
        RRect.fromRectAndRadius(handle, const Radius.circular(4)),
        Paint()
          ..color = Colors.blue
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      // Handle icon
      final iconPainter = TextPainter(
        text: const TextSpan(
          text: '⋮⋮',
          style: TextStyle(color: Colors.blue, fontSize: 8),
        ),
        textDirection: TextDirection.ltr,
      );
      iconPainter.layout();
      iconPainter.paint(canvas, Offset(handle.center.dx - 4, handle.center.dy - 4));
    }
    

  }

  void _drawShape(Canvas canvas, Shape shape, Paint paint) {
    paint.style = PaintingStyle.stroke;
    
    switch (shape.type) {
      case DrawingTool.line:
        canvas.drawLine(shape.start, shape.end, paint);
        break;
      case DrawingTool.arrow:
        _drawArrow(canvas, shape.start, shape.end, paint);
        break;
      case DrawingTool.circle:
        final radius = (shape.end - shape.start).distance / 2;
        final center = Offset(
          (shape.start.dx + shape.end.dx) / 2,
          (shape.start.dy + shape.end.dy) / 2,
        );
        canvas.drawCircle(center, radius, paint);
        break;
      case DrawingTool.rectangle:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromPoints(shape.start, shape.end),
            const Radius.circular(4),
          ),
          paint,
        );
        break;
      default:
        break;
    }
  }
  
  void _drawArrow(Canvas canvas, Offset start, Offset end, Paint paint) {
    // Draw main line
    canvas.drawLine(start, end, paint);
    
    // Calculate arrowhead
    final angle = (end - start).direction;
    final arrowLength = math.min(20.0, (end - start).distance * 0.3);
    final arrowAngle = 0.6;
    
    final arrowPoint1 = end + Offset(
      arrowLength * math.cos(angle + math.pi - arrowAngle),
      arrowLength * math.sin(angle + math.pi - arrowAngle),
    );
    final arrowPoint2 = end + Offset(
      arrowLength * math.cos(angle + math.pi + arrowAngle),
      arrowLength * math.sin(angle + math.pi + arrowAngle),
    );
    
    // Draw arrowhead
    canvas.drawLine(end, arrowPoint1, paint);
    canvas.drawLine(end, arrowPoint2, paint);
    
    // Fill arrowhead
    final arrowPath = Path()
      ..moveTo(end.dx, end.dy)
      ..lineTo(arrowPoint1.dx, arrowPoint1.dy)
      ..lineTo(arrowPoint2.dx, arrowPoint2.dy)
      ..close();
    
    canvas.drawPath(arrowPath, Paint()
      ..color = paint.color
      ..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}