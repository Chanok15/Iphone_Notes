import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:intl/intl.dart';


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
          onPressed: () {
          },
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
                                onPressed: () {
                                  setState(() {
                                    item.removeAt(index);
                                    box.put('todo', item);
                                  });
                                  Navigator.pop(context);
                                },
                              ),
                              CupertinoButton(
                                child: Text('No'),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                    onTap: () {
                      setState(() {
                        item[index]['status'] = !item[index]['status'];
                        box.put('todo', item);
                      });
                    },
                    child: Container(
                      child: CupertinoListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item[index]['task'],
                              style: TextStyle(
                                  decoration: item[index]['status']
                                      ? TextDecoration.lineThrough
                                      : null),
                            ),
                            Icon(
                              CupertinoIcons.circle_fill,
                              size: 15,
                              color: item[index]['status']
                                  ? CupertinoColors.activeGreen
                                  : CupertinoColors.destructiveRed,
                            )
                          ],
                        ),
                        subtitle: Divider(
                            color: CupertinoColors.systemFill.withOpacity(0.5)),
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              color: CupertinoColors.systemFill.withOpacity(0.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('               '),
                  Text(box.get('todo') != null
                      ? '${box.get('todo').length}ToDo'
                      : '0 ToDo'),
                  CupertinoButton(
                    child: Icon(
                      CupertinoIcons.square_pencil,
                      color: CupertinoColors.systemYellow,
                    ),
                    onPressed: () {
                      showCupertinoDialog(
                        context: context,
                        builder: (context) {
                          return CupertinoAlertDialog(
                            title: Text('Add Task'),
                            content: CupertinoTextField(
                              placeholder: 'Add To-Do',
                              controller: _addTask,
                            ),
                            actions: [
                              CupertinoButton(
                                child: Text('Close',
                                    style: TextStyle(
                                        color: CupertinoColors.destructiveRed)),
                                onPressed: () {
                                  _addTask.text = "";
                                  Navigator.pop(context);
                                },
                              ),
                              CupertinoButton(
                                child: Text('Save'),
                                onPressed: () {
                                  setState(() {
                                    todoList.add({
                                      "task": _addTask.text,
                                      "status": false,
                                    });
                                    box.put('todo', todoList);
                                    _loadTodoList(); // Reload the list after adding
                                  });
                                  _addTask.text = "";
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          );
                        },
                      );
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
}