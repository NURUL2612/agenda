// Flutter program for Task Management and Delegation

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';


class TaskDashboard extends StatefulWidget {
  @override
  _TaskDashboardState createState() => _TaskDashboardState();
}

class _TaskDashboardState extends State<TaskDashboard> {
  List<Task> tasks = [];

  void _addTask(Task task) {
    setState(() {
      tasks.add(task);
    });
  }

  void _updateTaskProgress(int index, String progress) {
    setState(() {
      tasks[index].progress = progress;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manajemen Tugas dan Delegasi'),
      ),
      body: SingleChildScrollView(
        child: DataTable(
          columns: const [
            DataColumn(label: Text('No.')),
            DataColumn(label: Text('Judul')),
            DataColumn(label: Text('Delegasi')),
            DataColumn(label: Text('Kategori')),
            DataColumn(label: Text('Batas Waktu')),
            DataColumn(label: Text('Progres')),
            DataColumn(label: Text('Deskripsi')),
            DataColumn(label: Text('File')),
            DataColumn(label: Text('Aksi')),
          ],
          rows: List<DataRow>.generate(
            tasks.length,
            (index) {
              final task = tasks[index];
              return DataRow(cells: [
                DataCell(Text('${index + 1}')),
                DataCell(Text(task.title)),
                DataCell(Text(task.assignee)),
                DataCell(Text(task.category)),
                DataCell(Text(task.dueDate != null ? task.dueDate!.toLocal().toString().split(' ')[0] : '-')),
                DataCell(Text(task.progress)),
                DataCell(Text(task.description)),
                DataCell(Text(task.uploadedFile != null ? task.uploadedFile!.path.split('/').last : 'Tidak ada file')),
                DataCell(IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => _showUpdateProgressDialog(context, index),
                )),
              ]);
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _showAddTaskDialog(context),
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
  final _titleController = TextEditingController();
  final _assigneeController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? selectedDate;
  File? uploadedFile;
  String selectedCategory = 'Rendah'; // Replaced from categoryController to selectedCategory

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      setState(() {
        uploadedFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Tambah Tugas'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Judul Tugas'),
              ),
              TextField(
                controller: _assigneeController,
                decoration: InputDecoration(labelText: 'Delegasi Kepada'),
              ),
              // Use DropdownButtonFormField for category instead of a controller
              DropdownButtonFormField<String>(
                value: selectedCategory, // This is the priority selection
                items: ['Rendah', 'Sedang', 'Tinggi']
                    .map((priority) => DropdownMenuItem(
                          value: priority,
                          child: Text(priority),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value!;
                  });
                },
                decoration: InputDecoration(labelText: 'Kategori Kepentingan'),
              ),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Deskripsi atau Persoalan Tugas'),
                maxLines: 3,
              ),
              Row(
                children: [
                  Text(selectedDate != null
                      ? 'Batas Waktu: ${selectedDate!.toLocal().toString().split(' ')[0]}'
                      : 'Batas Waktu: -'),
                  IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: _pickFile,
                child: Text(uploadedFile == null ? 'Upload File' : 'File: ${uploadedFile!.path.split('/').last}'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_titleController.text.isNotEmpty && _assigneeController.text.isNotEmpty) {
                _addTask(Task(
                  title: _titleController.text,
                  assignee: _assigneeController.text,
                  category: selectedCategory, // Use selectedCategory here
                  dueDate: selectedDate,
                  description: _descriptionController.text,
                  uploadedFile: uploadedFile,
                  progress: 'Belum Dimulai',
                ));
                Navigator.of(context).pop();
              }
            },
            child: Text('Simpan'),
          ),
        ],
      );
    },
  );
}


  void _showUpdateProgressDialog(BuildContext context, int index) {
    final _progressController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Update Progres'),
          content: TextField(
            controller: _progressController,
            decoration: InputDecoration(labelText: 'Progres Baru'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_progressController.text.isNotEmpty) {
                  _updateTaskProgress(index, _progressController.text);
                  Navigator.of(context).pop();
                }
              },
              child: Text('Simpan'),
            ),
          ],
        );
      },
    );
  }
}

class Task {
  final String title;
  final String assignee;
  final String category;
  final DateTime? dueDate;
  String progress;
  final String description;
  final File? uploadedFile;

  Task({
    required this.title,
    required this.assignee,
    required this.category,
    this.dueDate,
    this.progress = 'Belum Dimulai',
    this.description = '',
    this.uploadedFile,
  });
}
