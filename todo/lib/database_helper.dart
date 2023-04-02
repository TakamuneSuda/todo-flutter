import 'dart:async';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class ToDo {
  final int? id;
  final String? title;
  final int? priority;

  ToDo({this.id, this.title, this.priority});

  Map<String, dynamic> toMap(){
    return {
      'id': id,
      'title': title,
      'priority': priority,
    };
  }

  Future<Database> openTodoDatabase() async {
    final String databasesPath = await getDatabasesPath();
    return openDatabase(
      join(databasesPath, 'todo_database.db'),
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE todo (
            id INTEGER PRIMARY KEY,
            title TEXT NOT NULL,
            priority INTEGER NOT NULL
          )
        ''');
      },
      version: 1,
    );
  }

  Future<List<ToDo>> getAllTodos() async {
    final Database db = await openTodoDatabase();
    final List<Map<String, dynamic>> maps = await db.query('todo');
    return List.generate(maps.length, (i) {
      return ToDo(
        id: maps[i]['id'],
        title: maps[i]['title'],
        priority: maps[i]['priority'],
      );
    });
  }

  Future<void> insertTodo(ToDo todo) async {
    final Database db = await openTodoDatabase();
    await db.insert(
      'todo',
      todo.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
      );
  }

  Future<void> deleteTodo(int id) async {
    final Database db = await openTodoDatabase();
    await db.delete(
      'todo',
      where: "id = ?",
      whereArgs: [id],
    );
  }
}
