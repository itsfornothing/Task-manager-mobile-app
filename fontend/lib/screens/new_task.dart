import 'package:flutter/material.dart';
import 'package:task_manager/functions/supportive_functions.dart';
import 'package:intl/intl.dart';
import 'package:task_manager/api_service.dart';

class NewTask extends StatefulWidget {
  const NewTask({super.key, required this.projectId, this.onTaskAdded});

  final int projectId;
  final VoidCallback? onTaskAdded; 

  @override
  State<NewTask> createState() => _NewTaskState();
}

class _NewTaskState extends State<NewTask> {
  final _formKey = GlobalKey<FormState>();
  final _formater = DateFormat.yMd();
  final _titleController = TextEditingController();
  final _isCompleted = false;
  final ApiService apiService = ApiService();
  DateTime? _selectedDate;

  void datePicker() async {
    final firstDate = DateTime.now();
    final lastDate = DateTime(
      firstDate.year + 1,
      firstDate.month,
      firstDate.day,
    );
    final pickedDate = await showDatePicker(
      context: context,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  void _saveTask() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a due date')),
        );
        return;
      }
      _formKey.currentState!.save();
      try {
        await apiService.createTask(
          widget.projectId,
          _titleController.text.trim(),
          _selectedDate!,
          _isCompleted,
        );
        widget.onTaskAdded?.call(); 
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task created successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to create task: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_outlined),
        ),
        title: const Text('New Task',),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                maxLength: 50,
                decoration: InputDecoration(label: Text('Task Title')),
                validator: (value) => validateFullName(value),
              ),

              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Deadline',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedDate == null
                        ? 'No Selected Date'
                        : _formater.format(_selectedDate!),
                    style: TextStyle(fontSize: 16),
                  ),
                  IconButton(
                    onPressed: datePicker,
                    icon: Icon(Icons.calendar_month),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Status',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('New', style: TextStyle(fontSize: 16)),
              ),
              SizedBox(height: 16),
              Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveTask,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.secondaryFixed,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    
                  ),
                  child: Text(
                    'Create Task',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
