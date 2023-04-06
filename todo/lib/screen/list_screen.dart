import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

import '../constants.dart';
import '../model/database_helper.dart';
import 'add_edit_screen.dart';
import '../widget/priority_color.dart';

class TodoListPage extends StatefulWidget {
  final TodoDatabase database;

  TodoListPage({required this.database});

  @override
  _TodoListPageState createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  late Future<List<TodoDatabase>> _todos;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todoリスト'),
      ),
      body: Center(
        child: FutureBuilder<List<TodoDatabase>>(
          future: widget.database.getAllTodos(),
          builder: (BuildContext context, AsyncSnapshot<List<TodoDatabase>> snapshot) {
            if (snapshot.hasData) {
              final todos = snapshot.data!;
              return ListView.builder(
                itemCount: todos.length,
                itemBuilder: (BuildContext context, int index) {
                  final todo = todos[index];
                  return _buildTodoListItem(context, todo);
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
          setState(() {
            _todos = widget.database.getAllTodos();
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildTodoListItem(BuildContext context, TodoDatabase todo) {
    return Dismissible(
      key: UniqueKey(),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) async {  
        await widget.database.deleteTodo(todo.id!);
        setState(() {
          _todos = widget.database.getAllTodos();
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
        tileColor: PriorityColor.getPriorityColor(todo.priority!),
        title: Text(todo.title ?? ''),
        onTap: () async {
          final newListText = await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) {
              return TodoAddEditPage(
                id: todo.id,
                title: todo.title,
                priority: todo.priority
              );
            })
          );
          setState(() {
            _todos = widget.database.getAllTodos();
          });
        },
      ),
    );
  }
}