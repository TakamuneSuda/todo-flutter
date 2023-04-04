import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:todo/database_helper.dart';

int PRIORITY_VALUE_LOW = 0;
int PRIORITY_VALUE_MIDDLE = 1;
int PRIORITY_VALUE_HIGH = 2;

Color PRIORITY_COLOR_LOW = Color.fromARGB(255, 225, 237, 255);
Color PRIORITY_COLOR_MIDDLE = Color.fromARGB(255, 255, 252, 226);
Color PRIORITY_COLOR_HIGH = Color.fromARGB(255, 255, 221, 220);

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
                      color: Colors.red,
                      child: Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                    child: ListTile(
                      tileColor
                        : todo.priority == 0 ? PRIORITY_COLOR_LOW
                        : todo.priority == 1 ? PRIORITY_COLOR_MIDDLE
                        : todo.priority == 2 ? PRIORITY_COLOR_HIGH
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

class TodoAddEditPage extends StatefulWidget {
  final int? id;
  final String? title;
  final int? priority;

  TodoAddEditPage({this.id, this.title, this.priority});

  @override
  _TodoAddEditPageState createState() => _TodoAddEditPageState();
}

class _TodoAddEditPageState extends State<TodoAddEditPage>{
  late String _text = '';
  late TodoPriority? _selectedPriority = TodoPriority.low;
  bool _isEditMode = false;
  final _controller = TextEditingController();

  // 編集モードに切り替え
  @override
  void initState() {
    if(widget.title != null) {
      _isEditMode = true;
      _text = widget.title!;
      _controller.text = _text;
      _selectedPriority = TodoPriority.values[widget.priority!];
    }
  }

  void _onPriorityButtonPressed(TodoPriority priority) {
    setState(() {
      _selectedPriority = priority;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Todo編集' : 'Todo追加'),
      ),
      body: Container(
        padding: EdgeInsets.all(64),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(_text, style: TextStyle(color: Colors.blue)),
            const SizedBox(height: 8,),
            TextField(
              controller: _controller,
              onChanged: (String value){
                setState(() {
                  _text = value;
                });
              },
            ),
            const SizedBox(
              height: 8,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('優先度'),
                SizedBox(width: 10),
                PriorityButton(
                  label: '低',
                  isSelected: _selectedPriority == TodoPriority.low,
                  onTap: () => _onPriorityButtonPressed(TodoPriority.low),
                  value: 'low',
                ),
                SizedBox(width: 5),
                PriorityButton(
                  label: '中',
                  isSelected: _selectedPriority == TodoPriority.medium,
                  onTap: () => _onPriorityButtonPressed(TodoPriority.medium),
                  value: 'middle',
                ),
                SizedBox(width: 5),
                PriorityButton(
                  label: '高',
                  isSelected: _selectedPriority == TodoPriority.high,
                  onTap: () => _onPriorityButtonPressed(TodoPriority.high),
                  value: 'high',
                ),
              ],
            ),
            const SizedBox(
              height: 12,
            ),
            Container(
              width: double.infinity,
              child: ElevatedButton(
                // primary: Colors.blue,
                onPressed: () async {
                  final isExitTitle = ToDo().isExistTitle(widget.id, _text);
                  if (await isExitTitle) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('既に同じタイトルのToDoが存在します'),
                        duration: Duration(seconds: 3),
                      ),
                    );
                  } else {
                    int selectedPriorityValue = PRIORITY_VALUE_LOW;
                    if (_selectedPriority == TodoPriority.low) {
                      selectedPriorityValue = PRIORITY_VALUE_LOW;
                    } else if (_selectedPriority == TodoPriority.medium) {
                      selectedPriorityValue = PRIORITY_VALUE_MIDDLE;
                    } else if (_selectedPriority == TodoPriority.high) {
                      selectedPriorityValue = PRIORITY_VALUE_HIGH;
                    }
                    final newTodo = ToDo(
                      id: widget.id,
                      title: _text,
                      priority: selectedPriorityValue,
                    );
                    if (_isEditMode) {
                      ToDo().updateTodo(newTodo);
                    } else {
                      ToDo().insertTodo(newTodo);
                    }
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

enum TodoPriority {
  low,
  medium,
  high,
}

class PriorityButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final String value;

  PriorityButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    switch (value) {
      case 'low':
        backgroundColor = isSelected ? PRIORITY_COLOR_LOW : Colors.white;
        textColor = isSelected ? Colors.grey : Colors.black;
        break;
      case 'middle':
        backgroundColor = isSelected ? PRIORITY_COLOR_MIDDLE : Colors.white;
        textColor = isSelected ? Colors.grey : Colors.black;
        break;
      case 'high':
        backgroundColor = isSelected ? PRIORITY_COLOR_HIGH : Colors.white;
        textColor = isSelected ? Colors.grey : Colors.black;
        break;
      default:
        backgroundColor = Colors.white;
        textColor = Colors.black;
        break;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(
            color: Colors.grey,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(5),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        width: 70,
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
