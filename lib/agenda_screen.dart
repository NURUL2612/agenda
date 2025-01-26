import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';

class AgendaDashboard extends StatefulWidget {
  @override
  _AgendaDashboardState createState() => _AgendaDashboardState();
}

class _AgendaDashboardState extends State<AgendaDashboard> {
  List<Agenda> agendas = [];
  final List<String> anggota = ["Anggota 1", "Anggota 2", "Anggota 3", "Anggota 4"]; // List of members
  
  void _addAgenda(Agenda agenda) {
    setState(() {
      agendas.add(agenda);
      _sortAgenda(); // Sorting after adding a new agenda
    });
  }

  void _updateAgendaPriority(int index, String priority) {
    setState(() {
      agendas[index].priority = priority;
    });
  }

  void _editAgenda(int index, Agenda updatedAgenda) {
    setState(() {
      agendas[index] = updatedAgenda;
    });
  }

  void _sortAgenda() {
    // Sorting agenda based on category first, then by time (from earliest to latest)
    agendas.sort((a, b) {
      if (a.category == "Penting" && b.category != "Penting") return -1;
      if (a.category != "Penting" && b.category == "Penting") return 1;
      return a.time.compareTo(b.time);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Jadwal Kegiatan dan Rapat'),
        actions: [
          IconButton(
            icon: Icon(Icons.group),
            onPressed: _groupAgendasByCategory,
            tooltip: 'Kelompokkan Agenda Berdasarkan Kategori',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: DataTable(
          columns: const [
            DataColumn(label: Text('No.')),
            DataColumn(label: Text('Agenda')),
            DataColumn(label: Text('Waktu')),
            DataColumn(label: Text('Prioritas')),
            DataColumn(label: Text('Kategori')),
            DataColumn(label: Text('Tempat')),
            DataColumn(label: Text('Deskripsi')),
            DataColumn(label: Text('File')),
            DataColumn(label: Text('Kehadiran')),  // New column for attendance count
            DataColumn(label: Text('Aksi')),
          ],
          rows: List<DataRow>.generate(
            agendas.length,
            (index) {
              final agenda = agendas[index];
              return DataRow(cells: [
                DataCell(Text('${index + 1}')),
                DataCell(Text(agenda.title)),
                DataCell(Text(agenda.formattedTime)),
                DataCell(Text(agenda.priority)),
                DataCell(Text(agenda.category)),
                DataCell(Text(agenda.location)),
                DataCell(Text(agenda.description)),
                DataCell(Text(agenda.fileName ?? 'No File')),
                DataCell(Text('${agenda.attendees.length}')), // Display the number of attendees
                DataCell(IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => _showEditAgendaDialog(context, index, agenda),
                )),
              ]);
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _showAddAgendaDialog(context),
      ),
    );
  }

  void _showAddAgendaDialog(BuildContext context) {
    final _titleController = TextEditingController();
    final _descriptionController = TextEditingController();
    final _locationController = TextEditingController();
    DateTime? selectedDate;
    TimeOfDay? selectedTime;
    String selectedPriority = 'Sangat Penting';
    String selectedCategory = 'pertemuan';
    String? selectedFile;

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

    Future<void> _selectTime(BuildContext context) async {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
        setState(() {
          selectedTime = pickedTime;
        });
      }
    }

    Future<void> _pickFile() async {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null) {
        setState(() {
          selectedFile = result.files.single.name; // Get the file name
        });
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Tambah Agenda'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: 'Judul Agenda'),
                ),
                DropdownButtonFormField<String>(
                  value: selectedPriority,
                  items: ['Sangat Penting', 'Penting', 'Reguler']
                      .map((priority) => DropdownMenuItem(
                            value: priority,
                            child: Text(priority),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedPriority = value!;
                    });
                  },
                  decoration: InputDecoration(labelText: 'Prioritas'),
                ),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  items: ['pertemuan', 'kunjungan kerja', 'Rapat internal', 'rapat external']
                      .map((category) => DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value!;
                    });
                  },
                  decoration: InputDecoration(labelText: 'Kategori'),
                ),
                TextField(
                  controller: _locationController,
                  decoration: InputDecoration(labelText: 'Tempat Kegiatan'),
                ),
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: 'Deskripsi Agenda'),
                  maxLines: 3,
                ),
                Row(
                  children: [
                    Text(selectedDate != null
                        ? 'Tanggal: ${DateFormat('yyyy-MM-dd').format(selectedDate!)}'
                        : 'Tanggal: -'),
                    IconButton(
                      icon: Icon(Icons.calendar_today),
                      onPressed: () => _selectDate(context),
                    ),
                    Text(selectedTime != null
                        ? 'Waktu: ${selectedTime!.format(context)}'
                        : 'Waktu: -'),
                    IconButton(
                      icon: Icon(Icons.access_time),
                      onPressed: () => _selectTime(context),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(selectedFile != null
                        ? 'File: $selectedFile'
                        : 'No file selected'),
                    IconButton(
                      icon: Icon(Icons.attach_file),
                      onPressed: _pickFile,
                    ),
                  ],
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
                if (_titleController.text.isNotEmpty && selectedDate != null && selectedTime != null) {
                  final agendaTime = DateTime(
                    selectedDate!.year,
                    selectedDate!.month,
                    selectedDate!.day,
                    selectedTime!.hour,
                    selectedTime!.minute,
                  );
                  _addAgenda(Agenda(
                    title: _titleController.text,
                    time: agendaTime,
                    priority: selectedPriority,
                    category: selectedCategory,
                    location: _locationController.text,
                    description: _descriptionController.text,
                    fileName: selectedFile,
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

  void _showEditAgendaDialog(BuildContext context, int index, Agenda agenda) {
    final _titleController = TextEditingController(text: agenda.title);
    final _descriptionController = TextEditingController(text: agenda.description);
    final _locationController = TextEditingController(text: agenda.location);
    DateTime? selectedDate = agenda.time;
    TimeOfDay? selectedTime = TimeOfDay.fromDateTime(agenda.time);
    String selectedPriority = agenda.priority;
    String selectedCategory = agenda.category;
    String? selectedFile = agenda.fileName;

    Future<void> _selectDate(BuildContext context) async {
      final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: selectedDate!,
        firstDate: DateTime.now(),
        lastDate: DateTime(2100),
      );
      if (pickedDate != null) {
        setState(() {
          selectedDate = pickedDate;
        });
      }
    }

    Future<void> _selectTime(BuildContext context) async {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: selectedTime!,
      );
      if (pickedTime != null) {
        setState(() {
          selectedTime = pickedTime;
        });
      }
    }

    Future<void> _pickFile() async {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null) {
        setState(() {
          selectedFile = result.files.single.name;
        });
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Agenda'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: 'Judul Agenda'),
                ),
                DropdownButtonFormField<String>(
                  value: selectedPriority,
                  items: ['Sangat Penting', 'Penting', 'Reguler']
                      .map((priority) => DropdownMenuItem(
                            value: priority,
                            child: Text(priority),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedPriority = value!;
                    });
                  },
                  decoration: InputDecoration(labelText: 'Prioritas'),
                ),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  items: ['pertemuan', 'kunjungan kerja', 'Rapat internal', 'rapat external']
                      .map((category) => DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value!;
                    });
                  },
                  decoration: InputDecoration(labelText: 'Kategori'),
                ),
                TextField(
                  controller: _locationController,
                  decoration: InputDecoration(labelText: 'Tempat Kegiatan'),
                ),
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: 'Deskripsi Agenda'),
                  maxLines: 3,
                ),
                Row(
                  children: [
                    Text(selectedDate != null
                        ? 'Tanggal: ${DateFormat('yyyy-MM-dd').format(selectedDate!)}'
                        : 'Tanggal: -'),
                    IconButton(
                      icon: Icon(Icons.calendar_today),
                      onPressed: () => _selectDate(context),
                    ),
                    Text(selectedTime != null
                        ? 'Waktu: ${selectedTime!.format(context)}'
                        : 'Waktu: -'),
                    IconButton(
                      icon: Icon(Icons.access_time),
                      onPressed: () => _selectTime(context),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(selectedFile != null
                        ? 'File: $selectedFile'
                        : 'No file selected'),
                    IconButton(
                      icon: Icon(Icons.attach_file),
                      onPressed: _pickFile,
                    ),
                  ],
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
                if (_titleController.text.isNotEmpty && selectedDate != null && selectedTime != null) {
                  final agendaTime = DateTime(
                    selectedDate!.year,
                    selectedDate!.month,
                    selectedDate!.day,
                    selectedTime!.hour,
                    selectedTime!.minute,
                  );
                  final updatedAgenda = Agenda(
                    title: _titleController.text,
                    time: agendaTime,
                    priority: selectedPriority,
                    category: selectedCategory,
                    location: _locationController.text,
                    description: _descriptionController.text,
                    fileName: selectedFile,
                  );
                  _editAgenda(index, updatedAgenda);
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

  void _groupAgendasByCategory() {
    setState(() {
      _sortAgenda();
    });
  }
}

class Agenda {
  final String title;
  final DateTime time;
  String priority;
  final String category;
  final String location;
  final String description;
  final String? fileName;
  final List<String> attendees; // List of attendees

  Agenda({
    required this.title,
    required this.time,
    required this.priority,
    required this.category,
    required this.location,
    required this.description,
    this.fileName,
    this.attendees = const [], // Default to an empty list if no attendees are provided
  });

  String get formattedTime {
    return DateFormat('yyyy-MM-dd HH:mm').format(time);
  }
}
