import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Task {
  String title;
  DateTime dueDate;
  bool isCompleted;

  Task({required this.title, required this.dueDate, this.isCompleted = false});
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Task> tasks = [];
  final TextEditingController _titleController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    try {
      final response = await http.get(
        Uri.parse('https://parseapi.back4app.com/classes/myTaskManager'),
        headers: {
          'X-Parse-Application-Id': '',
          'X-Parse-REST-API-Key': '',
          //'X-Parse-Master-Key': 'SMseVbPQKzsXgAlZ',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        print('Tasks loaded: ${jsonResponse['results']}'); // Log the tasks
        setState(() {
          tasks = List<Task>.from(jsonResponse['results'].map((model) => Task(
                title: model['Name'],
                dueDate: DateTime.parse(model['DueDate']),
              )));
        });
      } else {
        print(
            'Failed to load tasks: ${response.body}'); // Log the error response
      }
    } catch (e) {
      print('Error loading tasks: $e'); // Log any exceptions
    }
  }

  Future<void> _addTask() async {
    final response = await http.post(
      Uri.parse('https://parseapi.back4app.com/classes/myTaskManager'),
      headers: {
        'X-Parse-Application-Id': '',
        'X-Parse-REST-API-Key': '',
        //'X-Parse-Master-Key': '',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'Name': _titleController.text,
        'DueDate': _selectedDate.toIso8601String(),
      }),
    );
    if (response.statusCode == 201) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Task created successfully'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                          
      _loadTasks(); // Reload tasks after adding
      _titleController.clear();
    } else {
      // Handle error
    }
  }

  // void _addTask() {
  //   setState(() {
  //     tasks.add(Task(title: _titleController.text, dueDate: _selectedDate));
  //     _titleController.clear();
  //   });
  // }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Divyesh's Task Manager"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                var task = tasks[index];
                return ListTile(
                  title: Text(task.title),
                  subtitle: Text('Due date: ${task.dueDate}'),
                  trailing: IconButton(
                    icon: Icon(task.isCompleted
                        ? Icons.check_box
                        : Icons.check_box_outline_blank),
                    onPressed: () {
                      setState(() {
                        task.isCompleted = !task.isCompleted;
                      });
                    },
                  ),
                  onLongPress: () async {
                    final taskName = tasks[index].title;
                    // Fetch the object ID of the task with the given name
                    final objectIdResponse = await http.get(
                      Uri.parse(
                          'https://parseapi.back4app.com/classes/myTaskManager?where={"Name":"$taskName"}'),
                      headers: {
                        'X-Parse-Application-Id': '',
                        'X-Parse-REST-API-Key': '',
                        // 'X-Parse-Master-Key': '',
                        'Content-Type': 'application/json',
                      },
                    );

                    if (objectIdResponse.statusCode == 200) {
                      final objectId =
                          jsonDecode(objectIdResponse.body)['results'][0]
                              ['objectId'];
                      // Send an HTTP DELETE request to remove the task from Back4app
                      final deleteResponse = await http.delete(
                        Uri.parse(
                            'https://parseapi.back4app.com/classes/myTaskManager/$objectId'),
                        headers: {
                          'X-Parse-Application-Id': '',
                          'X-Parse-REST-API-Key': '',
                          // 'X-Parse-Master-Key': '',
                          'Content-Type': 'application/json',
                        },
                      );

                      if (deleteResponse.statusCode == 200) {
                        // Remove the task from the local list
                        setState(() {
                          tasks.removeAt(index);
                        });
                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Task deleted successfully'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                      } else {
                         print('deleteResponse. Failed delete task');
                         // ignore: use_build_context_synchronously
                         ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Failed to delete task'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        // Handle error
                      }
                    } else {
                      // Handle error
                      print("objectIdResponse. Failed to get delete ID.");
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Task not found'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                    }
                  },
                );
              },
            ),
          ),
          Card(
            elevation: 10.0, // This gives a shadow effect to make it look 3D
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  // Adding a gradient background
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.blue.shade200,
                    Colors.blue.shade500,
                  ],
                ),
              ),
              padding: EdgeInsets.all(16.0), // Padding inside the card
              child: Column(
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Task Title',
                      border:
                          OutlineInputBorder(), // Adds a border to the TextField
                      filled: true, // Needed for fillColor to take effect
                      fillColor: Colors.white
                          .withOpacity(0.7), // Slightly transparent white
                    ),
                  ),
                  SizedBox(height: 16.0), // Adds space between the components
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                          'Due Date: ${_selectedDate.toLocal()}'.split(' ')[0]),
                      ElevatedButton(
                        onPressed: () => _selectDate(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700, // Button color
                        ),
                        child: const Text('Select Date',
                        style: TextStyle(
                            color: Colors.white, // Text color
                            fontWeight: FontWeight.bold, // Text weight
                          ),
                          ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: _addTask,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, // Button color
                    ),
                    child: const Text('Add Task',
                    style: TextStyle(
                            color: Colors.white, // Text color
                            fontWeight: FontWeight.bold, // Text weight
                          ),
                          ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
