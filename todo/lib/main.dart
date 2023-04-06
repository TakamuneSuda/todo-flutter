import 'package:flutter/material.dart';
import 'constants.dart';
import 'model/database_helper.dart';
import 'screen/list_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dbHelper = TodoDatabase();
  await dbHelper.openTodoDatabase();
  runApp(MyTodoApp(database: dbHelper));
}

class MyTodoApp extends StatelessWidget {
  final TodoDatabase database;

  const MyTodoApp({
    Key? key,
    required this.database,
  }) :super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: APP_NAME,
      theme: ThemeData(
        primarySwatch: themeColor,
      ),
      home: TodoListPage(database: database),
    );
  }
}