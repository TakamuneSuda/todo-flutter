import 'dart:async';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class TodoDatabase{
  final int? id;
  final String? title;
  final int? priority;

  TodoDatabase({this.id, this.title, this.priority});

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

  // 一覧表示用
  Future<List<TodoDatabase>> getAllTodos() async {
    final Database db = await openTodoDatabase();
    final List<Map<String, dynamic>> maps = await db.query('todo');
    return List.generate(maps.length, (i) {
      return TodoDatabase(
        id: maps[i]['id'],
        title: maps[i]['title'],
        priority: maps[i]['priority'],
      );
    });
  }

  // 追加用
  Future<void> insertTodo(TodoDatabase todo) async {
    final Database db = await openTodoDatabase();
    await db.insert(
      'todo',
      todo.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
      );
  }

  // 編集用
  Future<void> updateTodo(TodoDatabase todo) async {
    final Database db = await openTodoDatabase();
    await db.update(
      'todo',
      todo.toMap(),
      where: "id = ?",
      whereArgs: [todo.id],
      );
  }

  // 削除用
  Future<void> deleteTodo(int id) async {
    final Database db = await openTodoDatabase();
    await db.delete(
      'todo',
      where: "id = ?",
      whereArgs: [id],
    );
  }

  // 同じTodoが既に存在するかチェック
  Future<bool> isExistTitle(int? id, String title) async {
    final Database db = await openTodoDatabase();
    final List<Map<String, dynamic>> result;
    // 新規作成
    if ( id == null) {
      result = await db.query(
        'todo',
        where: 'LOWER(REPLACE(title, " ", "")) = ?',
        whereArgs: [title.trim().toLowerCase().replaceAll(" ", "")],
      );
    // 編集
    } else {
      result = await db.query(
        'todo',
        where: 'LOWER(REPLACE(title, " ", "")) = ? AND id <> ?',
        whereArgs: [title.trim().toLowerCase().replaceAll(" ", ""), id],
      );
    }
    return result.isNotEmpty;
  }
}
