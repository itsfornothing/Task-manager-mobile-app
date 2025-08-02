import 'package:flutter/material.dart';
import 'package:task_manager/screens/new_task.dart';
import 'package:task_manager/api_service.dart';
import 'package:intl/intl.dart';

class ProjectDetailScreen extends StatefulWidget {
  const ProjectDetailScreen({
    super.key,
    required this.projectId,
    required this.projectTitle,
    this.onTaskAdded,
  });

  final int projectId;
  final String projectTitle;
  final VoidCallback? onTaskAdded;
  @override
  State<ProjectDetailScreen> createState() {
    return _ProjectDetailScreenState();
  }
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  final ApiService apiService = ApiService();
  late Future<List<dynamic>> _tasksFuture;

  @override
  void initState() {
    super.initState();
    _tasksFuture = apiService.fetchTasks(widget.projectId);
  }

  void _addNewTask() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => NewTask(
          projectId: widget.projectId,
          onTaskAdded: () {
            setState(() {
              _tasksFuture = apiService.fetchTasks(widget.projectId);
            });
            widget.onTaskAdded?.call();
          },
        ),
      ),
    );
  }

  void _deleteTask(int taskId) async {
    try {
      await apiService.deleteTask(widget.projectId, taskId);
      setState(() {
        _tasksFuture = apiService.fetchTasks(widget.projectId);
      });
      widget.onTaskAdded?.call(); 
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to delete task: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Project Details",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Project: ${widget.projectTitle}',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: _tasksFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No tasks found.'));
                  }
                  final tasks = snapshot.data!;
                  return ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      final dueDate = DateTime.parse(task['deadline']);
                      return Dismissible(
                        onDismissed: (direction) {
                          _deleteTask(task['id']);
                        },
                        key: ValueKey(task),
                        background: Container(
                          color: Theme.of(context).colorScheme.error,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                        ),
                        child: Card(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Due: ${DateFormat.yMd().format(dueDate)}',
                                  style: Theme.of(context).textTheme.bodySmall!
                                      .copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.secondary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                Text(
                                  task['title'],
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Status: ${task['is_completed'] ? 'Completed' : 'Pending'}',
                                  style: Theme.of(context).textTheme.bodySmall!
                                      .copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.secondary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Theme.of(context).colorScheme.secondaryFixed,
        foregroundColor: Colors.black,
        onPressed: _addNewTask,
        icon: Icon(Icons.add),
        label: Text(""),
      ),
    );
  }
}
