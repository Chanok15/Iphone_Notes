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