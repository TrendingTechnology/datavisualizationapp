import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:data_visualization_app/models/activity_goal.dart';
import 'package:data_visualization_app/models/recorded_activity.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseManager {
  DatabaseManager._();

  static final DatabaseManager db = DatabaseManager._();
  static Database _database;

  DatabaseManager();

  Future<Database> get database async {
    //_database.isOpen ? print("database is open") : print("database is NOT open");

    if (_database != null) {
      return _database;
    }

    // if _database is null, instantiate it
    _database = await initDB();

    return _database;
  }

  initDB() async {
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, "asset_activity_database.db");

// Check if the database exists
    var exists = await databaseExists(path);

    if (!exists) {
      // Should happen only the first time you launch your application
      print("Creating new copy from asset");

      // Make sure the parent directory exists
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}

      // Copy from asset
      ByteData data = await rootBundle.load(join("assets", "activity_database.db"));
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      // Write and flush the bytes written
      await File(path).writeAsBytes(bytes, flush: true);
    } else {
      print("Opening existing database");
    }
    // open the database
    return await openDatabase(path, onUpgrade: _onUpgrade, version: 2);
  }

  /// Create new table for goals on database upgrade
  Future<void> _onUpgrade(Database db, int ancientVersion, int newVersion) async {
    if(newVersion == 2){
      db.execute(
        "CREATE TABLE goals(id INTEGER, number INTEGER, title TEXT, type INTEGER, activity INTEGER, span INTEGER)",
      );
    }
  }

  /// Method to get all activities
  Future<List<RecordedActivity>> getActivities() async {
    var dbClient = await database;
    List<Map> list = await dbClient.rawQuery('SELECT * FROM activities');
    List<RecordedActivity> activities = new List();
    for (int i = 0; i < list.length; i++) {
      activities.add(new RecordedActivity(list[i]["id"], list[i]["type"], list[i]["date"],
          list[i]["duration"], list[i]["distance"]));
    }
    return activities;
  }

  /// Save activity
  Future<int> saveActivity(RecordedActivity activity) async {
    Database dbClient = await this.database;

    var result = await dbClient.insert("activities", activity.toMap());
    return result;
  }

  /// Delete activity
  Future<void> deleteActivity(RecordedActivity activity) async {
    Database dbClient = await this.database;

    var result = await dbClient.delete(
      'activities',
      where: "id = ?",
      whereArgs: [activity.id],
    );
  }

  /// Update Activity
  Future<void> updateActivity(RecordedActivity activity) async {
    // Get a reference to the database.
    Database dbClient = await this.database;

    // Update the given Activity.
    await dbClient.update(
      'activities',
      activity.toMap(),
      // Ensure that the Dog has a matching id.
      where: "id = ?",
      // Pass the Dog's id as a whereArg to prevent SQL injection.
      whereArgs: [activity.id],
    );
  }

  /// Save Goal
  Future<int> saveGoal(ActivityGoal goal) async {
    Database dbClient = await this.database;

    var result = await dbClient.insert("goals", goal.toMap());
    return result;
  }

  /// Update Goal
  Future<void> updateGoal(ActivityGoal goal) async {
    // Get a reference to the database.
    Database dbClient = await this.database;

    // Update the given Activity.
    await dbClient.update(
      'goals',
      goal.toMap(),
      // Ensure that the Dog has a matching id.
      where: "id = ?",
      // Pass the Dog's id as a whereArg to prevent SQL injection.
      whereArgs: [goal.id],
    );
  }

  /// Delete goal
  Future<void> deleteGoal(ActivityGoal goal) async {
    Database dbClient = await this.database;

    var result = await dbClient.delete(
      'goals',
      where: "id = ?",
      whereArgs: [goal.id],
    );
  }

  /// Method to get all activities
  Future<List<ActivityGoal>> getGoals() async {
    var dbClient = await database;
    List<Map> list = await dbClient.rawQuery('SELECT * FROM goals');
    List<ActivityGoal> goals = new List();
    for (int i = 0; i < list.length; i++) {
      goals.add(
          new ActivityGoal(list[i]["id"], list[i]["number"], list[i]["title"],
              list[i]["type"], list[i]["activity"], list[i]["span"]));
    }
    return goals;
  }
}
