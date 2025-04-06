import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EditNotePage extends StatefulWidget {
  final Map<String, dynamic> note;
  final int index;
  final Function(Map<String, dynamic>) onNoteUpdated;

  EditNotePage({
    required this.note,
    required this.index,
    required this.onNoteUpdated,
  });

  @override
  _EditNotePageState createState() => _EditNotePageState();
}

class _EditNotePageState extends State<EditNotePage> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note['title'] ?? '');
    _contentController = TextEditingController(text: widget.note['content'] ?? '');
  }

   @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Edit Note'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Text('Save'),
          onPressed: () {
            final updatedNote = {
              'title': _titleController.text,
              'content': _contentController.text,
              'date': DateTime.now(),
              'isPinned': widget.note['isPinned'],
              'isLocked': widget.note['isLocked'],
            };
            widget.onNoteUpdated(updatedNote);
            Navigator.pop(context);
          },
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Make the column take only necessary space
            children: [
              CupertinoTextField(
                controller: _titleController,
                placeholder: 'Title',
              ),
              SizedBox(height: 8),
              Container(
                constraints: BoxConstraints(maxHeight: 100.0), // Reduced height
                child: CupertinoTextField(
                  controller: _contentController,
                  placeholder: 'Content',
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                ),
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(DateFormat('MMM d, HH:mm').format(widget.note['date'])),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Text('Cancel'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}