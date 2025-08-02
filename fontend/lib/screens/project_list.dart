import 'package:flutter/material.dart';
import 'package:task_manager/screens/project_detail.dart';
import 'package:task_manager/api_service.dart';
import 'package:intl/intl.dart';

class ProjectListScreen extends StatefulWidget {
  const ProjectListScreen({
    super.key,
    this.onProjectAdded,
    this.setRefreshCallback,
  });

  final VoidCallback? onProjectAdded;
  final Function(Function)?
  setRefreshCallback;

  @override
  State<ProjectListScreen> createState() {
    return _ProjectListScreenState();
  }
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  final ApiService apiService = ApiService();
  late Future<List<dynamic>> _projectsFuture;

  @override
  void initState() {
    super.initState();
    _projectsFuture = apiService.fetchProjects();
    widget.setRefreshCallback?.call(
      _refreshProjects,
    ); 
  }

  void _deleteProject(int projectId) async {
    try {
      await apiService.deleteProject(projectId);
      setState(() {
        _projectsFuture = apiService.fetchProjects();
      });
      widget.onProjectAdded?.call(); 
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Project deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to delete task: $e')));
    }
  }

  void _refreshProjects() {
    setState(() {
      _projectsFuture = apiService.fetchProjects();
    });
  }

  void _selectProject(BuildContext context, projectId, projectTitle) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => ProjectDetailScreen(
          projectId: projectId,
          projectTitle: projectTitle,
          onTaskAdded: _refreshProjects,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My Projects',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),

          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _projectsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No project found.'));
                }
                final projects = snapshot.data!;
                return ListView.builder(
                  itemCount: projects.length,

                  itemBuilder: (context, index) {
                    final project = projects[index];
                    final dueDate = project['due_date'] != null
                        ? DateTime.parse(project['due_date'])
                        : null;
                    return InkWell(
                      onTap: () {
                        _selectProject(
                          context,
                          project['id'],
                          project['title'],
                        );
                      },
                      child: Dismissible(
                        onDismissed: (direction) {
                          _deleteProject(project['id']);
                        },
                        key: ValueKey(project),
                        background: Container(
                          color: Theme.of(context).colorScheme.error,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                        ),
                        child: Card(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.blueGrey[100],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  'P${index + 1}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  dueDate != null
                                      ? 'Due: ${DateFormat.yMd().format(dueDate)}'
                                      : 'no tasks',
                                  style: Theme.of(context).textTheme.bodySmall!
                                      .copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.secondary,
                                        fontWeight: FontWeight.bold
                                      ),
                                ),
                                Text(
                                  project['title'],
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${project['task_count'] ?? 0} tasks',
                                  style: Theme.of(context).textTheme.bodySmall!
                                      .copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.secondary,
                                        fontWeight: FontWeight.bold
                                      ),
                        
                                ),
                              ],
                            ),
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
    );
  }
}
