import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:coaching_client/models/task.dart';

class TaskProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const int tasksPerPage = 12;

  Map<String, List<Task>> _tasksByDeadline = {};
  bool _isLoading = false;
  bool _isInitialized = false;
  DocumentSnapshot? _lastDocument; // To keep track of the last document fetched
  bool _hasMoreTasks = false; // To check if there are more tasks to load
  StreamSubscription<QuerySnapshot>?
      _subscription; // To handle the Firestore subscription

  Map<String, List<Task>> get tasksByDeadline => _tasksByDeadline;
  bool get isLoading => _isLoading;
  bool get hasMoreTasks => _hasMoreTasks;
  bool get isInitialized => _isInitialized;

  Stream<QuerySnapshot> listenToTasks(String userId) {
    DateTime today = DateTime.now();
    DateTime endDate = today.add(const Duration(days: 30));

    var stream = _firestore
        .collection('students')
        .doc(userId)
        .collection('tasks')
        .where('deadline', isGreaterThanOrEqualTo: today.toIso8601String())
        .where('deadline', isLessThanOrEqualTo: endDate.toIso8601String())
        .orderBy('deadline')
        .limit(tasksPerPage)
        .snapshots();

    _subscription = stream.listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        _lastDocument = snapshot.docs.last;
      }

      List<Task> tasks =
          snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList();
      _tasksByDeadline = _groupTasksByDeadline(tasks);
      _setLoading(false);
      setInitialized(true);
    });

    return stream;
  }

  Future<void> loadMoreTasks(String userId) async {
    if (_hasMoreTasks) {
      try {
        _setLoading(true);
        DateTime today = DateTime.now();
        DateTime endDate = today.add(const Duration(days: 30));

        Query query = _firestore
            .collection('students')
            .doc(userId)
            .collection('tasks')
            .where('deadline', isGreaterThanOrEqualTo: today.toIso8601String())
            .where('deadline', isLessThanOrEqualTo: endDate.toIso8601String())
            .orderBy('deadline')
            .limit(tasksPerPage);

        if (_lastDocument != null) {
          query = query.startAfterDocument(_lastDocument!);
        }

        QuerySnapshot snapshot = await query.get();

        if (snapshot.docs.isNotEmpty) {
          _lastDocument = snapshot.docs.last;
          List<Task> tasks =
              snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList();
          _appendTasks(tasks);
        } else {
          _hasMoreTasks = false; // No more tasks to load
        }
        _setLoading(false);
      } catch (e) {
        _setLoading(false);
        print('Error loading more tasks: $e');
      }
    }
  }

  Future<void> toggleTaskStatus(
      String userId, String taskId, bool currentStatus, String deadline) async {
    try {
      await _firestore
          .collection('students')
          .doc(userId)
          .collection('tasks')
          .doc(taskId)
          .update({'isDone': !currentStatus});
      _updateLocalTaskStatus(taskId, !currentStatus, deadline);
      notifyListeners();
    } catch (e) {
      print('Error toggling task status: $e');
    }
  }

  void _updateLocalTaskStatus(String taskId, bool newStatus, String deadline) {
    if (_tasksByDeadline.containsKey(deadline)) {
      for (var task in _tasksByDeadline[deadline]!) {
        if (task.id == taskId) {
          task.isDone = newStatus;
        }
      }
    }
  }

  Map<String, List<Task>> _groupTasksByDeadline(List<Task> tasks) {
    Map<String, List<Task>> groupedTasks = {};
    for (var task in tasks) {
      String dateString =
          DateTime.parse(task.deadline).toLocal().toString().split(' ')[0];
      if (groupedTasks.containsKey(dateString)) {
        groupedTasks[dateString]!.add(task);
      } else {
        groupedTasks[dateString] = [task];
      }
    }
    return groupedTasks;
  }

  void _appendTasks(List<Task> tasks) {
    for (var task in tasks) {
      String dateString =
          DateTime.parse(task.deadline).toLocal().toString().split(' ')[0];
      if (_tasksByDeadline.containsKey(dateString)) {
        _tasksByDeadline[dateString]!.add(task);
      } else {
        _tasksByDeadline[dateString] = [task];
      }
    }
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setInitialized(bool value) {
    _isInitialized = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
