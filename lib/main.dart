import 'package:flutter/cupertino.dart';

void main() {
  // Your code here. For example:
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      home: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text(''),
        ),
        child: Center(
          child: Text(''),
        ),
      ),
    );
  }
}