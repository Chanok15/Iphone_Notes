import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AddNotePage extends StatefulWidget {
  final Function(Map<String, dynamic>) onNoteAdded;

  AddNotePage({required this.onNoteAdded});

  @override
  _AddNotePageState createState() => _AddNotePageState();
}

class _AddNotePageState extends State<AddNotePage> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Edit Note'), // Changed title to "Edit Note"
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Text('Save'),
          onPressed: () {
            final newNote = {
              'title': _titleController.text,
              'content': _contentController.text,
              'date': DateTime.now(),
              'isPinned': false,
              'isLocked': false,
            };
            widget.onNoteAdded(newNote);
            Navigator.pop(context);
          },
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              CupertinoTextField(
                controller: _titleController,
                style: TextStyle(fontSize: 18, color: CupertinoColors.white), // Adjusted font and color
                decoration: BoxDecoration(
                  border: Border.all(color: CupertinoColors.lightBackgroundGray), // Added border
                  borderRadius: BorderRadius.circular(8), // Rounded corners
                ),
              ),
              SizedBox(height: 8),
              CupertinoTextField(
                controller: _contentController,
                maxLines: null,
                expands: true,
                style: TextStyle(fontSize: 18, color: CupertinoColors.white), // Adjusted font and color
                decoration: BoxDecoration(
                  border: Border.all(color: CupertinoColors.lightBackgroundGray), // Added border
                  borderRadius: BorderRadius.circular(8), // Rounded corners
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}