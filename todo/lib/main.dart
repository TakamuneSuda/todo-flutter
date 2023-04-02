import 'package:flutter/material.dart';
import 'package:todo/database_helper.dart';

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
        primarySwatch: Colors.blue,
      ),
      home: TodoListPage(),
    );
  }
}

class TodoListPage extends StatefulWidget {
  @override
  _TodoListPageState createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  @override

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('リスト一覧'),
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
                  return ListTile(
                    title: Text(todo.title ?? ''),
                    subtitle: Text('Priority: ${todo.priority ?? ''}'),
                    trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        ToDo().deleteTodo(todo.id!);
                      });
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newListText = await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) {
              return TodoAddPage();
            })
          );
          setState(() {});
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class TodoAddPage extends StatefulWidget {
  @override
  _TodoAddPageState createState() => _TodoAddPageState();
}

class _TodoAddPageState extends State<TodoAddPage>{
  String _text = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('リスト追加'),
      ),
      body: Container(
        padding: EdgeInsets.all(64),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(_text, style: TextStyle(color: Colors.blue)),
            const SizedBox(height: 8,),
            TextField(
              onChanged: (String value){
                setState(() {
                  _text = value;
                });
              },
            ),
            const SizedBox(
              height: 8,
            ),
            Container(
              width: double.infinity,
              child: ElevatedButton(
                // primary: Colors.blue,
                onPressed: () async {
                  final isExitTitle = ToDo().isExistTitle(_text);
                  if (await isExitTitle) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('既に同じタイトルのToDoが存在します'),
                        duration: Duration(seconds: 3),
                      ),
                    );
                  } else {
                    final newTodo = ToDo(
                      title: _text,
                      priority: 1,
                    );
                    ToDo().insertTodo(newTodo);
                    Navigator.of(context).pop();
                  }
                },
                child: Text(
                  '追加',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              child: TextButton(
                onPressed: (){
                  Navigator.of(context).pop();
                },
                child: Text('キャンセル'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}