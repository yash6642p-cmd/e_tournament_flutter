import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'edit_tournament_screen.dart';

class TournamentDetailsScreen extends StatelessWidget {
  final String tournamentId;

  const TournamentDetailsScreen({
    super.key,
    required this.tournamentId,
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tournament Details'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('tournaments')
            .doc(tournamentId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (!snapshot.hasData || snapshot.data!.data() == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          final int joined = data['joined'] ?? 0;
          final int slots = data['slots'] ?? 0;
          final List joinedUsers = data['joinedUsers'] ?? [];

          final bool isLoggedIn = user != null;
          final bool alreadyJoined =
              isLoggedIn && joinedUsers.contains(user!.uid);
          final bool isFull = joined >= slots;
          final bool isCreator =
              isLoggedIn && data['createdBy'] == user!.uid;

          // STATUS
          String statusText;
          Color statusColor;

          if (isFull) {
            statusText = 'FULL';
            statusColor = Colors.red;
          } else if (alreadyJoined) {
            statusText = 'JOINED';
            statusColor = Colors.green;
          } else {
            statusText = 'OPEN';
            statusColor = Colors.blue;
          }

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

          return Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                // TITLE + STATUS
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        data['title'],
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Chip(
                      label: Text(
                        statusText,
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: statusColor,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                _infoRow(Icons.sports_esports, 'Game', data['game']),
                _infoRow(
                    Icons.currency_rupee, 'Entry Fee', '₹${data['entryFee']}'),
                _infoRow(Icons.group, 'Slots', '$joined / $slots'),

                const Divider(height: 32),

                _infoRow(
                  Icons.schedule,
                  'Match Time',
                  data['matchTime'] ?? 'To be announced',
                ),
                _infoRow(
                  Icons.emoji_events,
                  'Prize Pool',
                  data['prize'] ?? 'To be announced',
                ),
                _infoRow(
                  Icons.meeting_room,
                  'Room ID',
                  data['roomId'] ?? 'Will be shared later',
                ),

                const SizedBox(height: 24),

                // EDIT (CREATOR)
                if (isCreator) ...[
                  ElevatedButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Tournament'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditTournamentScreen(
                            tournamentId: tournamentId,
                            data: data,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                ],

                // JOIN BUTTON
                ElevatedButton(
                  onPressed: canJoin
                      ? () async {
                          await FirebaseFirestore.instance
                              .collection('tournaments')
                              .doc(tournamentId)
                              .update({
                            'joined': FieldValue.increment(1),
                            'joinedUsers':
                                FieldValue.arrayUnion([user!.uid]),
                          });
                        }
                      : null,
                  child: Text(buttonText),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _infoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[700]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$title:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
