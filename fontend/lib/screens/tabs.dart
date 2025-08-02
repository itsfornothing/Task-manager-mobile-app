import 'package:flutter/material.dart';
import 'package:task_manager/screens/new_project.dart';
import 'package:task_manager/screens/profile.dart';
import 'package:task_manager/screens/project_list.dart';

class TabsScreen extends StatefulWidget {
  const TabsScreen({super.key});

  @override
  State<TabsScreen> createState() {
    return _TabsScreenState();
  }
}

class _TabsScreenState extends State<TabsScreen> {
  int _selectedPageIndex = 0;
  var activePageTitle = 'Tasks';
  Function? _refreshProjectsCallback;

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  void addProjectOverlay() {
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (ctx) => NewProject(
        onProjectAdded: () {
          _refreshProjectsCallback
              ?.call(); 
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget activePage = ProjectListScreen(
      onProjectAdded: () {
        setState(() {}); 
        _refreshProjectsCallback
            ?.call(); 
      },
      setRefreshCallback: (Function callback) {
        _refreshProjectsCallback = callback; 
      },
    );

    if (_selectedPageIndex == 1) {
      activePageTitle = 'Profile';
      activePage = ProfileScreen();
    } else {
      activePageTitle = 'Tasks';
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          activePageTitle,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: _selectedPageIndex == 0
            ? [IconButton(onPressed: addProjectOverlay, icon: Icon(Icons.add))]
            : null,
      ),
      body: activePage,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedPageIndex,
        onTap: _selectPage,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.list_rounded),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_sharp),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
