import 'dart:async';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class ToDo {
  final int id;
  final String title;
  final int priority;

  Map<String, dynamic> toMap(){
    return {
      'id': id,
      'title': title,
      'priority': priority,
    };
  }

  ToDo({required this.id, required this.title, required this.priority});

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
    ).then((db) async {
    await db.transaction((txn) async {
      await txn.rawInsert(
          'INSERT INTO todo (title, priority) VALUES (?, ?)',
          ['Task 1', 1]);
      await txn.rawInsert(
          'INSERT INTO todo (title, priority) VALUES (?, ?)',
          ['Task 2', 2]);
      await txn.rawInsert(
          'INSERT INTO todo (title, priority) VALUES (?, ?)',
          ['Task 3', 3]);
    });
    return db;
    });
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


}
