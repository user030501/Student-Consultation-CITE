import 'package:flutter/material.dart';

class Consultation {
  String studentName;
  String date;
  String time;
  String purpose;
  String status;

  Consultation({
    required this.studentName,
    required this.date,
    required this.time,
    required this.purpose,
    required this.status,
  });
}

class AdviserConsultationPage extends StatefulWidget {
  const AdviserConsultationPage({super.key});

  @override
  State<AdviserConsultationPage> createState() =>
      _AdviserConsultationPageState();
}

class _AdviserConsultationPageState extends State<AdviserConsultationPage> {
  List<Consultation> consultations = [
    Consultation(
        studentName: "Juan Dela Cruz",
        date: "Feb 10, 2026",
        time: "10:00 AM",
        purpose: "Subject advising",
        status: "Pending"),
    Consultation(
        studentName: "Maria Santos",
        date: "Feb 12, 2026",
        time: "1:00 PM",
        purpose: "Grade concern",
        status: "Approved"),
  ];

  Color getStatusColor(String status) {
    switch (status) {
      case "Pending":
        return Colors.orange;
      case "Approved":
        return Colors.blue;
      case "Completed":
        return Colors.green;
      case "Rejected":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void updateStatus(int index, String newStatus) {
    setState(() {
      consultations[index].status = newStatus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Consultation Requests")),
      body: ListView.builder(
        itemCount: consultations.length,
        itemBuilder: (context, index) {
          final consult = consultations[index];

          return Card(
            margin: const EdgeInsets.all(10),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Student: ${consult.studentName}",
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text("Date: ${consult.date}"),
                  Text("Time: ${consult.time}"),
                  Text("Purpose: ${consult.purpose}"),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: getStatusColor(consult.status),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(consult.status,
                            style: const TextStyle(color: Colors.white)),
                      ),
                      if (consult.status == "Pending") ...[
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.check, color: Colors.green),
                              onPressed: () =>
                                  updateStatus(index, "Approved"),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () =>
                                  updateStatus(index, "Rejected"),
                            ),
                          ],
                        )
                      ] else if (consult.status == "Approved") ...[
                        ElevatedButton(
                          onPressed: () =>
                              updateStatus(index, "Completed"),
                          child: const Text("Mark Completed"),
                        )
                      ]
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
