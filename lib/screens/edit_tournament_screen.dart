import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditTournamentScreen extends StatelessWidget {
  final String tournamentId;
  final Map<String, dynamic> data;

  const EditTournamentScreen({
    super.key,
    required this.tournamentId,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final matchTimeController =
        TextEditingController(text: data['matchTime'] ?? '');
    final roomIdController =
        TextEditingController(text: data['roomId'] ?? '');
    final prizeController =
        TextEditingController(text: data['prize'] ?? '');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Tournament'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const Text(
              'Update Match Details',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 24),

            TextField(
              controller: matchTimeController,
              decoration: const InputDecoration(
                labelText: 'Match Time',
                hintText: '10 Jan 2026, 6 PM',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: roomIdController,
              decoration: const InputDecoration(
                labelText: 'Room ID',
                hintText: 'ABCD-1234',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: prizeController,
              decoration: const InputDecoration(
                labelText: 'Prize',
                hintText: '₹5000',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('tournaments')
                    .doc(tournamentId)
                    .update({
                  'matchTime': matchTimeController.text.trim(),
                  'roomId': roomIdController.text.trim(),
                  'prize': prizeController.text.trim(),
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tournament updated'),
                  ),
                );

                Navigator.pop(context);
              },
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
