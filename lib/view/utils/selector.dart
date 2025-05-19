import 'package:flutter/material.dart';

typedef ObjectCreator<T> = void Function(String name);

class ObjectSelector<T> extends StatefulWidget {
  final String label;
  final String pluralLabel;
  final String hint;
  final List<T> options;
  final String Function(T) getName;
  final Color Function(T) getColor;
  final void Function(String name, Color color) onCreate;
  final void Function(T)? onSelect;
  final bool allowMultiple;

  const ObjectSelector({
    super.key,
    required this.label,
    required this.pluralLabel,
    required this.hint,
    required this.options,
    required this.getName,
    required this.getColor,
    required this.onCreate,
    this.onSelect,
    this.allowMultiple = false,
  });

  @override
  State<ObjectSelector<T>> createState() => _ObjectSelectorState<T>();
}

class _ObjectSelectorState<T> extends State<ObjectSelector<T>> {
  final TextEditingController _controller = TextEditingController();
  Color _selectedColor = Colors.blue;
  T? _selectedObj;
  Set<T> _selectedObjs = {};

  @override
  void initState() {
    super.initState();
  }

  void _handleTap(T obj) {
    if (widget.onSelect == null) return; // no onSelect function
    setState(() {
      if (widget.allowMultiple) {
        if (_selectedObjs.contains(obj)) {
          _selectedObjs.remove(obj);
          widget.onSelect!(obj);
        } else {
          _selectedObjs.add(obj);
        }
        widget.onSelect!(obj);
      } else {
        if (_selectedObj == obj) {
          _selectedObj = null;
          widget.onSelect!(obj); // deselect the obj
        } else {
          _selectedObj = obj;
          widget.onSelect!(obj);
        }
      }
    });
  }

  void _pickColor() async {
    final colors = [
      Colors.amber,
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.purple,
      Colors.orange,
      Colors.teal,
    ];
    Color? picked = await showDialog<Color>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select a color'),
        content: Wrap(
          spacing: 8,
          children: colors.map((color) {
            return GestureDetector(
              onTap: () => Navigator.of(context).pop(color),
              child: Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _selectedColor == color ? Colors.black : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
    if (picked != null) {
      setState(() {
        _selectedColor = picked;
      });
    }
  }

  void _onAdd() {
    final input = _controller.text.trim();
    if (input.isEmpty) return;
    final exists = widget.options.any(
      (option) => widget.getName(option).toLowerCase() == input.toLowerCase()
    );
    if (exists) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('${widget.label} already exists'),
          content: Text('${widget.label} with the name "$input" already exists.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        )
      );
    } else {
      widget.onCreate(input, _selectedColor);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              widget.label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w300, fontFamily: 'Roboto')),
            const SizedBox(width: 8.0),
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    content: Text(widget.hint),
                    actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK'))]
                  )
                ); // ontap
              },
              child: const Icon(Icons.help_outline, size:20, color:Colors.grey),
            )
          ],
        ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(hintText: 'Create new ${widget.label}'),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, fontFamily: 'Roboto'),
              ),
            ),
            GestureDetector(
              onTap: _pickColor,
              child: Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  color: _selectedColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black26)
                )
              )
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _onAdd,
              tooltip: 'Add new ${widget.label}',
            ),
          ],
        ),
        const SizedBox(height: 12.0),
        Text(
          'Project ${widget.pluralLabel}',
          style: TextStyle(
            fontSize: 10.0,
            fontWeight: FontWeight.w300,
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontFamily: 'Roboto',
          )
        ),
        const SizedBox(height: 8.0),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: widget.options.map((obj) {
            final name = widget.getName(obj);
            final color = widget.getColor(obj);
            final isSelected = widget.allowMultiple
              ? _selectedObjs.contains(obj)
              : _selectedObj == obj;
            return GestureDetector(
              onTap: () => widget.onSelect == null ? null : _handleTap(obj),
              child: Container(
                constraints: const BoxConstraints(
                  minWidth: 110,
                  maxWidth: 150,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(color: isSelected ? Colors.black : Colors.transparent, width: 2),
                ),
                alignment: Alignment.center,
                child:Text(
                  name,
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontFamily: 'Roboto',
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            );
          }).toList()
        )

      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}