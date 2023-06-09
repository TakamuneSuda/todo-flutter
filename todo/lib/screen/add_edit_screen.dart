import 'package:flutter/material.dart';

import '../constants.dart';
import '../model/database_helper.dart';

class TodoAddEditPage extends StatefulWidget {
  final int? id;
  final String? title;
  final int? priority;

  TodoAddEditPage({this.id, this.title, this.priority});

  @override
  _TodoAddEditPageState createState() => _TodoAddEditPageState();
}

class _TodoAddEditPageState extends State<TodoAddEditPage>{
  final _controller = TextEditingController(text: '');
  late String _text = '';
  TodoPriority? _selectedPriority = TodoPriority.low;
  bool _isEditMode = false;

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
              decoration: InputDecoration(
                hintText: 'タイトルを入力してください。'
              ),
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.SUBMIT_BUTTON_COLOR,
                ),
                onPressed
                  : _text.isEmpty ? null
                  : () async {
                    final isExitTitle = TodoDatabase().isExistTitle(widget.id, _text);
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
                      final newTodo = TodoDatabase(
                        id: widget.id,
                        title: _text,
                        priority: selectedPriorityValue,
                      );
                      if (_isEditMode) {
                        TodoDatabase().updateTodo(newTodo);
                      } else {
                        TodoDatabase().insertTodo(newTodo);
                      }
                      Navigator.of(context).pop();
                    }
                  },
                child: Text(
                  _isEditMode ? '更新' : '追加',
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
        backgroundColor = isSelected ? AppColors.PRIORITY_COLOR_LOW : Colors.white;
        textColor = isSelected ? Colors.grey : Colors.black;
        break;
      case 'middle':
        backgroundColor = isSelected ? AppColors.PRIORITY_COLOR_MIDDLE : Colors.white;
        textColor = isSelected ? Colors.grey : Colors.black;
        break;
      case 'high':
        backgroundColor = isSelected ? AppColors.PRIORITY_COLOR_HIGH : Colors.white;
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