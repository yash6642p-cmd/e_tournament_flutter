import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateTournamentScreen extends StatelessWidget {
  const CreateTournamentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final titleController = TextEditingController();
    final gameController = TextEditingController();
    final feeController = TextEditingController();
    final slotsController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Tournament'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const Text(
              'Tournament Details',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 24),

            // Tournament name
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Tournament Name',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // Game name
            TextField(
              controller: gameController,
              decoration: const InputDecoration(
                labelText: 'Game Name',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // Entry fee
            TextField(
              controller: feeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Entry Fee (₹)',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // Total slots
            TextField(
              controller: slotsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Total Slots',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: () async {
                // 🔐 login check
                final user = FirebaseAuth.instance.currentUser;
                if (user == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please login to create tournament'),
                    ),
                  );
                  return;
                }

                // 🧪 validation
                if (titleController.text.trim().isEmpty ||
                    gameController.text.trim().isEmpty ||
                    feeController.text.trim().isEmpty ||
                    slotsController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill all fields'),
                    ),
                  );
                  return;
                }

                final int? entryFee =
                    int.tryParse(feeController.text.trim());
                final int? slots =
                    int.tryParse(slotsController.text.trim());

                if (entryFee == null || slots == null || slots <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Enter valid numbers'),
                    ),
                  );
                  return;
                }

                // 🔥 SAVE TO FIRESTORE
                await FirebaseFirestore.instance
                    .collection('tournaments')
                    .add({
                  'title': titleController.text.trim(),
                  'game': gameController.text.trim(),
                  'entryFee': entryFee,
                  'slots': slots,
                  'joined': 0,
                  'joinedUsers': [],
                  'createdBy': user.uid,
                  'createdAt': FieldValue.serverTimestamp(),
                });

                // ✅ success message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tournament created successfully'),
                  ),
                );

                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                'Create Tournament',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
