import 'package:flutter/material.dart';
import 'package:todo/constants.dart';
import 'package:todo/model/database_helper.dart';
import 'package:todo/screen/list_screen.dart';

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