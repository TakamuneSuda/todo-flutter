import 'package:flutter/material.dart';
import 'constants.dart';
import 'model/database_helper.dart';
import 'screen/list_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dbHelper = ToDo();
  await dbHelper.openTodoDatabase();

  runApp(MyTodoApp());
}

class MyTodoApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Todo App',
      theme: ThemeData(
        primarySwatch: themeColor,
      ),
      home: TodoListPage(),
    );
  }
}