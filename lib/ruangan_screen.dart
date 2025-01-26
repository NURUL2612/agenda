import 'package:flutter/material.dart';

class RoomBookingScreen extends StatefulWidget {
  @override
  _RoomBookingScreenState createState() => _RoomBookingScreenState();
}

class _RoomBookingScreenState extends State<RoomBookingScreen> {
  List<Map<String, dynamic>> rooms = [
    {
      'name': 'Ruangan A',
      'code': 'R001',
      'facilities': 'Proyektor, AC, Whiteboard',
      'capacity': 20,
      'bookings': [],
    },
    {
      'name': 'Ruangan B',
      'code': 'R002',
      'facilities': 'AC, Whiteboard',
      'capacity': 15,
      'bookings': [],
    },
  ];

  String searchQuery = "";

  void _addRoom() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (context) {
        final TextEditingController nameController = TextEditingController();
        final TextEditingController codeController = TextEditingController();
        final TextEditingController facilitiesController = TextEditingController();
        final TextEditingController capacityController = TextEditingController();

        return Padding(
          padding: EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            top: 16.0,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tambah Ruangan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Nama Ruangan'),
              ),
              TextFormField(
                controller: codeController,
                decoration: InputDecoration(labelText: 'Kode Ruangan'),
              ),
              TextFormField(
                controller: facilitiesController,
                decoration: InputDecoration(labelText: 'Fasilitas'),
              ),
              TextFormField(
                controller: capacityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Kapasitas'),
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    rooms.add({
                      'name': nameController.text,
                      'code': codeController.text,
                      'facilities': facilitiesController.text,
                      'capacity': int.tryParse(capacityController.text) ?? 0,
                      'bookings': [],
                    });
                  });
                  Navigator.pop(context);
                },
                child: Text('Simpan'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _bookRoom(int index) async {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController durationController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          top: 16.0,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Booking Ruangan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Nama Pemesan'),
            ),
            SizedBox(height: 8.0),
            ListTile(
              title: Text('Tanggal: ${selectedDate.toLocal()}'.split(' ')[0]),
              trailing: Icon(Icons.calendar_today),
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2101),
                );
                if (picked != null && picked != selectedDate)
                  setState(() {
                    selectedDate = picked;
                  });
              },
            ),
            ListTile(
              title: Text('Waktu Mulai: ${selectedTime.format(context)}'),
              trailing: Icon(Icons.access_time),
              onTap: () async {
                TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: selectedTime,
                );
                if (picked != null && picked != selectedTime)
                  setState(() {
                    selectedTime = picked;
                  });
              },
            ),
            TextFormField(
              controller: durationController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Durasi (jam)'),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                try {
                  // Menghitung waktu mulai dan selesai menggunakan objek DateTime
                  DateTime startTime = DateTime(
                    selectedDate.year,
                    selectedDate.month,
                    selectedDate.day,
                    selectedTime.hour,
                    selectedTime.minute,
                  );
                  int duration = int.tryParse(durationController.text) ?? 0;
                  DateTime endTime = startTime.add(Duration(hours: duration));

                  final newBooking = {
                    'name': nameController.text,
                    'date': selectedDate.toLocal().toString().split(' ')[0],
                    'time': selectedTime.format(context),
                    'duration': duration,
                    'endTime': endTime,
                  };

                  // Validasi konflik waktu booking
                  final existingBookings = rooms[index]['bookings'];
                  bool isConflict = existingBookings.any((booking) {
                    DateTime existingStart = booking['endTime'];
                    DateTime existingEnd = booking['endTime'];

                    return startTime.isBefore(existingEnd) && endTime.isAfter(existingStart);
                  });

                  if (isConflict) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Waktu booking bertabrakan!'),
                      ),
                    );
                  } else {
                    setState(() {
                      rooms[index]['bookings'].add(newBooking);
                    });
                    Navigator.pop(context);
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Format tanggal atau waktu tidak valid!'),
                    ),
                  );
                }
              },
              child: Text('Simpan'),
            ),
          ],
        ),
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Penyewaan Ruangan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Cari Ruangan (Nama/Kode)',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: rooms.length,
                itemBuilder: (context, index) {
                  final room = rooms[index];
                  if (searchQuery.isNotEmpty &&
                      !room['name'].toLowerCase().contains(searchQuery.toLowerCase()) &&
                      !room['code'].toLowerCase().contains(searchQuery.toLowerCase())) {
                    return Container();
                  }
                  return Card(
                    child: ExpansionTile(
                      title: Text('Nama: ${room['name']}'),
                      subtitle: Text('Kode: ${room['code']}\nFasilitas: ${room['facilities']}\nKapasitas: ${room['capacity']} orang'),
                      children: [
                        if (room['bookings'].isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('Belum ada booking.'),
                          )
                        else
                          ...room['bookings'].map((booking) {
                            return ListTile(
                              title: Text('${booking['date']} - ${booking['time']}'),
                              subtitle: Text('Durasi: ${booking['duration']} jam, Selesai: ${booking['endTime']}'),
                            );
                          }).toList(),
                        TextButton(
                          onPressed: () => _bookRoom(index),
                          child: Text('Tambah Booking'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: _addRoom,
              child: Text('Tambah Ruangan'),
            ),
          ],
        ),
      ),
    );
  }
}
