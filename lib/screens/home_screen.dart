import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'my_tournaments_screen.dart';
import 'tournament_details_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('E-Tournament'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt),
            tooltip: 'My Tournaments',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const MyTournamentsScreen(),
                ),
              );
            },
          ),
        ],
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('tournaments')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text('No tournaments available'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              final int joined = data['joined'] ?? 0;
              final int slots = data['slots'] ?? 0;
              final List joinedUsers = data['joinedUsers'] ?? [];

              final bool isLoggedIn = currentUser != null;
              final bool alreadyJoined =
                  isLoggedIn && joinedUsers.contains(currentUser!.uid);
              final bool isFull = joined >= slots;
              final bool isCreator =
                  isLoggedIn && data['createdBy'] == currentUser!.uid;

              String buttonText;
              bool canJoin = false;

              if (!isLoggedIn) {
                buttonText = 'Login required';
              } else if (isFull) {
                buttonText = 'Full';
              } else if (alreadyJoined) {
                buttonText = 'Joined';
              } else {
                buttonText = 'Join';
                canJoin = true;
              }

              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TournamentDetailsScreen(
                        tournamentId: doc.id,
                      ),
                    ),
                  );
                },
                child: Card(
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['title'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('Game: ${data['game']}'),
                        Text('Entry Fee: ₹${data['entryFee']}'),
                        Text('Slots: $joined / $slots'),

                        const SizedBox(height: 12),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // JOIN BUTTON
                            ElevatedButton(
                              onPressed: canJoin
                                  ? () async {
                                      await FirebaseFirestore.instance
                                          .collection('tournaments')
                                          .doc(doc.id)
                                          .update({
                                        'joined':
                                            FieldValue.increment(1),
                                        'joinedUsers':
                                            FieldValue.arrayUnion(
                                                [currentUser!.uid]),
                                      });
                                    }
                                  : null,
                              child: Text(buttonText),
                            ),

                            // DELETE (CREATOR ONLY)
                            if (isCreator) ...[
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.red),
                                onPressed: () async {
                                  final confirm =
                                      await showDialog<bool>(
                                    context: context,
                                    builder: (context) =>
                                        AlertDialog(
                                      title: const Text(
                                          'Delete Tournament'),
                                      content: const Text(
                                          'Are you sure you want to delete this tournament?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(
                                                  context, false),
                                          child:
                                              const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(
                                                  context, true),
                                          child:
                                              const Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirm == true) {
                                    await FirebaseFirestore.instance
                                        .collection('tournaments')
                                        .doc(doc.id)
                                        .delete();
                                  }
                                },
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
