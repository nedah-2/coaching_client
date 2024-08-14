import 'package:coaching_client/models/task.dart';
import 'package:coaching_client/providers/old_task_provider.dart';
import 'package:coaching_client/widgets/tasks/archieve_widget.dart';
import 'package:flutter/material.dart';

class OldTasksPage extends StatefulWidget {
  final String studentId;

  const OldTasksPage({super.key, required this.studentId});

  @override
  State<OldTasksPage> createState() => _OldTasksPageState();
}

class _OldTasksPageState extends State<OldTasksPage> {
  late OldTaskProvider _taskProvider;
  final ScrollController _scrollController = ScrollController();
  List<Task> _tasks = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _taskProvider = OldTaskProvider(widget.studentId);
    _loadInitialTasks();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !_isLoading &&
          _hasMore) {
        _loadMoreTasks();
      }
    });
  }

  Future<void> _loadInitialTasks() async {
    setState(() {
      _isLoading = true;
    });
    try {
      List<Task> tasks =
          await _taskProvider.getTasks(page: _currentPage, isInitial: true);
      setState(() {
        _tasks = tasks;
        _hasMore = tasks.length == _taskProvider.documentLimit;
        _currentPage = 1;
      });
    } catch (e) {
      // Handle the error (e.g., show a message to the user)
      print('Error loading initial tasks: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreTasks() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });
    try {
      List<Task> tasks = await _taskProvider.getTasks(page: _currentPage);
      setState(() {
        _tasks.addAll(tasks);
        _hasMore = tasks.length == _taskProvider.documentLimit;
        _currentPage++;
      });
    } catch (e) {
      // Handle the error (e.g., show a message to the user)
      print('Error loading more tasks: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Tasks Archive',
          style: TextStyle(fontSize: 18),
        ),
      ),
      body: _isLoading && _tasks.isEmpty
          ? const Center(child: Text('Loading...'))
          : _tasks.isEmpty
              ? const Center(child: Text('No Archive Yet'))
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 4, bottom: 16),
                  controller: _scrollController,
                  itemCount: _tasks.length + (_isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _tasks.length) {
                      return const Center(
                          child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 3),
                      ));
                    }
                    Task task = _tasks[index];
                    return ArchieveCard(task: task);
                  },
                ),
    );
  }
}
