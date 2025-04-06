import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:intl/intl.dart';
import 'edit_note_page.dart'; // Import the new page

void main() async {
  await Hive.initFlutter();
  await Hive.openBox('notesBox');

  runApp(CupertinoApp(
    debugShowCheckedModeBanner: false,
    home: NotesApp(),
  ));
}

class NotesApp extends StatefulWidget {
  const NotesApp({super.key});

  @override
  State<NotesApp> createState() => _NotesAppState();
}

class _NotesAppState extends State<NotesApp> {
  List<Map<String, dynamic>> notesList = [];
  TextEditingController _addNoteTitle = TextEditingController();
  TextEditingController _addNoteContent = TextEditingController();
  TextEditingController _searchController = TextEditingController();
  var notesBox = Hive.box('notesBox');
  bool _showPinned = true;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  void _loadNotes() {
    try {
      var storedNotes = notesBox.get('notes', defaultValue: []);

      if (storedNotes is List) {
        notesList = storedNotes.map((item) {
          if (item is Map) {
            return item.cast<String, dynamic>();
          } else {
            return <String, dynamic>{};
          }
        }).toList();
      } else {
        notesList = [];
      }
    } catch (e) {
      notesList = [];
      print('Error loading notes: $e');
    }
  }

  void _saveNotes() {
    List<Map<String, dynamic>> typedNotes = notesList.map((note) {
      return note.cast<String, dynamic>();
    }).toList();

    notesBox.put('notes', typedNotes);
  }

  List<Map<String, dynamic>> _getFilteredNotes() {
    final searchQuery = _searchController.text.toLowerCase();
    if (searchQuery.isEmpty) {
      return notesList;
    } else {
      return notesList.where((note) {
        final title = note['title']?.toLowerCase() ?? '';
        final content = note['content']?.toLowerCase() ?? '';
        return title.contains(searchQuery) || content.contains(searchQuery);
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Notes', style: TextStyle(color: CupertinoColors.black)),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Text('Folders', style: TextStyle(color: CupertinoColors.activeBlue)),
          onPressed: () {},
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            CupertinoSearchTextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {});
              },
              placeholder: 'Search Notes',
              prefixIcon: Icon(CupertinoIcons.search),
              suffixIcon: Icon(CupertinoIcons.xmark),
            ),
            Expanded(
              child: ListView(
                children: [
                  _buildSection('Pinned', _getPinnedNotes(_getFilteredNotes())),
                  _buildSection('Today', _getTodayNotes(_getFilteredNotes())),
                  _buildSection('Yesterday', _getYesterdayNotes(_getFilteredNotes())),
                  _buildSection('Previous 7 Days', _getPrevious7DaysNotes(_getFilteredNotes())),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Center(child: Text('${_getFilteredNotes().length} Notes')),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Icon(CupertinoIcons.square_pencil, color: CupertinoColors.activeBlue),
                    onPressed: () {
                      _showAddNoteDialog(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Map<String, dynamic>> notes) {
    if (notes.isEmpty) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
              if (title == 'Pinned')
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  minSize: 0,
                  onPressed: () {
                    setState(() {
                      _showPinned = !_showPinned;
                    });
                  },
                  child: Icon(CupertinoIcons.chevron_down),
                ),
            ],
          ),
        ),
        if (title != 'Pinned' || _showPinned)
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: notes.length,
            itemBuilder: (context, index) {
              return Dismissible(
                key: Key(notes[index]['date'].toString()),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: CupertinoColors.destructiveRed,
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.only(right: 20),
                  child: Icon(CupertinoIcons.delete, color: CupertinoColors.white),
                ),
                onDismissed: (direction) {
                  setState(() {
                    notesList.removeAt(notesList.indexOf(notes[index]));
                    _saveNotes();
                    _loadNotes();
                  });
                },
                child: _buildNotePreview(notes[index], index),
              );
            },
          ),
      ],
    );
  }

  Widget _buildNotePreview(Map<String, dynamic> note, int index) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => EditNotePage(
              note: note,
              index: index,
              onNoteUpdated: (updatedNote) {
                setState(() {
                  notesList[index] = updatedNote;
                  _saveNotes();
                  _loadNotes();
                });
              },
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: CupertinoColors.lightBackgroundGray),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      if (note['isPinned'] == true)
                        Icon(CupertinoIcons.lock_fill, color: CupertinoColors.black, size: 16),
                      SizedBox(width: 4),
                      Text(note['title'] ?? 'Untitled', style: TextStyle(color: CupertinoColors.black)),
                    ],
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  minSize: 0,
                  onPressed: () {
                    setState(() {
                      note['isPinned'] = !note['isPinned'];
                      _saveNotes();
                    });
                  },
                  child: Icon(
                    note['isPinned'] == true ? CupertinoIcons.pin_fill : CupertinoIcons.pin,
                    color: CupertinoColors.black,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Text(DateFormat('MMM d, HH:mm').format(note['date']), style: TextStyle(color: CupertinoColors.black)),
                if (note['isPinned'] == true) Text(' Locked', style: TextStyle(color: CupertinoColors.secondaryLabel)),
              ],
            ),
            SizedBox(height: 8),
            Text(note['content'] ?? '', style: TextStyle(color: CupertinoColors.black)),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(CupertinoIcons.doc_text, size: 16, color: CupertinoColors.secondaryLabel),
                SizedBox(width: 4),
                Text('Notes', style: TextStyle(color: CupertinoColors.secondaryLabel)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getPinnedNotes(List<Map<String, dynamic>> allNotes) {
    return allNotes.where((note) => note['isPinned'] == true).toList();
  }

  List<Map<String, dynamic>> _getTodayNotes(List<Map<String, dynamic>> allNotes) {
    DateTime now = DateTime.now();
    return allNotes
        .where((note) => DateFormat('yyyy-MM-dd').format(note['date']) == DateFormat('yyyy-MM-dd').format(now) && note['isPinned'] == false)
        .toList();
  }

  List<Map<String, dynamic>> _getYesterdayNotes(List<Map<String, dynamic>> allNotes) {
    DateTime yesterday = DateTime.now().subtract(Duration(days: 1));
    return allNotes
        .where((note) => DateFormat('yyyy-MM-dd').format(note['date']) == DateFormat('yyyy-MM-dd').format(yesterday) && note['isPinned'] == false)
        .toList();
  }

  List<Map<String, dynamic>> _getPrevious7DaysNotes(List<Map<String, dynamic>> allNotes) {
    DateTime sevenDaysAgo = DateTime.now().subtract(Duration(days: 7));
    return allNotes
        .where((note) =>
    note['date'].isAfter(sevenDaysAgo) &&
        !DateFormat('yyyy-MM-dd').format(note['date']).startsWith(DateFormat('yyyy-MM-dd').format(DateTime.now())) && note['isPinned'] == false)
        .toList();
  }

  void _showAddNoteDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text('Add New Note'),
          content: Column(
            children: [
              CupertinoTextField(
                placeholder: 'Title',
                controller: _addNoteTitle,
              ),
              SizedBox(height: 8),
              CupertinoTextField(
                placeholder: 'Content',
                controller: _addNoteContent,
                maxLines: 5,
              ),
            ],
          ),
          actions: [
            CupertinoButton(
              child: Text('Cancel'),
              onPressed: () {
                _addNoteTitle.clear();
                _addNoteContent.clear();
                Navigator.pop(context);
              },
            ),
            CupertinoButton(
              child: Text('Save'),
              onPressed: () {
                setState(() {
                  notesList.add({
                    'title': _addNoteTitle.text,
                    'content': _addNoteContent.text,
                    'date': DateTime.now(),
                    'isPinned': false,
                    'isLocked': false,
                  });
                  _saveNotes();
                  _loadNotes();
                });
                _addNoteTitle.clear();
                _addNoteContent.clear();
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}