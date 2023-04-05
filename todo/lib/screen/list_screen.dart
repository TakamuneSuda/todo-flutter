import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

import '../constants.dart';
import '../model/database_helper.dart';
import 'add_edit_screen.dart';

class TodoListPage extends StatefulWidget {
  @override
  _TodoListPageState createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  @override

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todoリスト'),
      ),
      body: Center(
        child: FutureBuilder<List<ToDo>>(
          future: ToDo().getAllTodos(),
          builder: (BuildContext context, AsyncSnapshot<List<ToDo>> snapshot) {
            if (snapshot.hasData) {
              final todos = snapshot.data!;
              return ListView.builder(
                itemCount: todos.length,
                itemBuilder: (BuildContext context, int index) {
                  final todo = todos[index];
                  return Dismissible(
                    key: UniqueKey(),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      setState(() {
                        ToDo().deleteTodo(todo.id!);
                      });
                    },
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(right: 20.0),
                      color: HexColor("#ff2222"),
                      child: Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                    child: ListTile(
                      tileColor
                        : todo.priority == 0 ? AppColors.PRIORITY_COLOR_LOW
                        : todo.priority == 1 ? AppColors.PRIORITY_COLOR_MIDDLE
                        : todo.priority == 2 ? AppColors.PRIORITY_COLOR_HIGH
                        : null,
                      title: Text(todo.title ?? ''),
                      onTap: () async {
                        final newListText = await Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) {
                            return TodoAddEditPage(id: todo.id, title:todo.title, priority: todo.priority);
                          })
                        );
                        setState(() {});
                      },
                    ),
                  );
                },
              );
            } else {
              return CircularProgressIndicator();
            }
          },
        ),
      ),
      // 新規追加ボタン
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newListText = await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) {
              return TodoAddEditPage();
            })
          );
          setState(() {});
        },
        child: Icon(Icons.add),
      ),
    );
  }
}