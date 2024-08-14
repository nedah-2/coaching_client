import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coaching_client/models/task.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class OldTaskProvider {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String studentId;

  OldTaskProvider(this.studentId);

  DocumentSnapshot? lastDocument;
  bool hasMore = true;
  int documentLimit = 12; // Set the number of documents per page
  final Duration cacheDuration =
      const Duration(days: 1); // Cache validity duration
  final int maxCachePages = 5; // Max number of pages to keep in cache
  Future<void> _saveTasksToCache(int page, List<Task> tasks) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String tasksJson =
          jsonEncode(tasks.map((task) => task.toFirestore()).toList());

      String cacheTimestampString = DateTime.now().toIso8601String();
      await prefs.setString('cached_tasks_${studentId}_page_$page', tasksJson);
      await prefs.setString(
          'cache_timestamp_${studentId}_page_$page', cacheTimestampString);
    } catch (e) {
      // Handle error, e.g., log it or notify the user
      print('Error saving tasks to cache: $e');
    }
  }

  Future<List<Task>> _loadCachedTasks(int page) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? cachedTasksJson =
          prefs.getString('cached_tasks_${studentId}_page_$page');
      String? cacheTimestampString =
          prefs.getString('cache_timestamp_${studentId}_page_$page');

      if (cachedTasksJson != null && cacheTimestampString != null) {
        DateTime cacheTimestamp = DateTime.parse(cacheTimestampString);
        if (DateTime.now().difference(cacheTimestamp) <= cacheDuration) {
          List<dynamic> decodedTasks = jsonDecode(cachedTasksJson);
          return decodedTasks
              .map((task) => Task.fromJson(task as Map<String, dynamic>))
              .toList();
        } else {
          await prefs.remove('cached_tasks_${studentId}_page_$page');
          await prefs.remove('cache_timestamp_${studentId}_page_$page');
        }
      }
      return [];
    } catch (e) {
      // Handle error, e.g., log it or notify the user
      print('Error loading cached tasks: $e');
      return [];
    }
  }

  Future<List<Task>> getTasks({int page = 0, bool isInitial = false}) async {
    if (isInitial) {
      lastDocument = null;
      hasMore = true;
    }

    if (!hasMore) {
      return [];
    }

    List<Task> cachedTasks = await _loadCachedTasks(page);
    if (cachedTasks.isNotEmpty) {
      return cachedTasks;
    }

    Query query = _firestore
        .collection('students')
        .doc(studentId)
        .collection('tasks')
        .where('deadline', isLessThan: DateTime.now().toUtc().toString())
        .orderBy('deadline')
        .limit(documentLimit);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument!);
    }

    QuerySnapshot querySnapshot;
    try {
      querySnapshot = await query.get();
    } catch (e) {
      print('Error fetching tasks from Firestore: $e');
      return [];
    }

    if (querySnapshot.docs.isEmpty) {
      hasMore = false;
      return [];
    }

    lastDocument = querySnapshot.docs.last;

    List<Task> tasks =
        querySnapshot.docs.map((doc) => Task.fromFirestore(doc)).toList();

    // Save the current page tasks to cache
    await _saveTasksToCache(page, tasks);

    // Cleanup old cache entries
    await _cleanupCache();
    print('Load from the internet');
    return tasks;
  }

  Future<void> _cleanupCache() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> keys = prefs.getKeys().toList();

    // Identify cache keys that belong to tasks
    List<String> taskCacheKeys = keys
        .where((key) => key.startsWith('cached_tasks_${studentId}_page_'))
        .toList();

    // Sort keys based on page number to keep only the most recent pages
    taskCacheKeys.sort((a, b) {
      int pageA = int.parse(a.split('_').last);
      int pageB = int.parse(b.split('_').last);
      return pageA.compareTo(pageB);
    });

    // Remove old cache entries if more than maxCachePages are present
    while (taskCacheKeys.length > maxCachePages) {
      String oldKey = taskCacheKeys.removeAt(0); // Remove the oldest key
      await prefs.remove(oldKey);
      await prefs
          .remove(oldKey.replaceFirst('cached_tasks_', 'cache_timestamp_'));
    }
  }
}
