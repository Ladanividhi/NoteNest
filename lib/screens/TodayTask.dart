import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../utils/Constants.dart'; // your color definitions and _buildCountdownTimer()

class TodayTaskPage extends StatefulWidget {
  const TodayTaskPage({super.key});

  @override
  State<TodayTaskPage> createState() => _TodayTaskPageState();
}

class _TodayTaskPageState extends State<TodayTaskPage> {
  Widget _buildCountdownTimer(Timestamp endTimestamp) {
    return TweenAnimationBuilder<Duration>(
      duration: endTimestamp.toDate().difference(DateTime.now()),
      tween: Tween(
        begin: endTimestamp.toDate().difference(DateTime.now()),
        end: const Duration(seconds: 0),
      ),
      builder: (context, value, child) {
        final hours = value.inHours.remainder(24).toString().padLeft(2, '0');
        final minutes = value.inMinutes
            .remainder(60)
            .toString()
            .padLeft(2, '0');
        final seconds = value.inSeconds
            .remainder(60)
            .toString()
            .padLeft(2, '0');

        return Text(
          '⏳ $hours:$minutes:$seconds remaining',
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            color: Colors.red,
            fontWeight: FontWeight.w600,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todayDateOnly = DateTime(today.year, today.month, today.day);

    return Scaffold(
      backgroundColor: bg_color,
      appBar: AppBar(
        title: const Text(
          "Today's Tasks",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primary_color,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('Tasks')
                .where('Id', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading tasks.'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final allTasks = snapshot.data!.docs;

          return FutureBuilder<QuerySnapshot>(
            future:
                FirebaseFirestore.instance
                    .collection('TaskCompleted')
                    .where(
                      'Id',
                      isEqualTo: FirebaseAuth.instance.currentUser?.uid,
                    )
                    .get(),
            builder: (context, completedSnapshot) {
              if (completedSnapshot.hasError) {
                return const Center(
                  child: Text('Error loading completed tasks.'),
                );
              }
              if (!completedSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final completedDocs = completedSnapshot.data!.docs;

              final taskCardItems =
                  allTasks
                      .map((task) {
                        final data = task.data() as Map<String, dynamic>;
                        final status = data['Status'];
                        final startTimestamp = data['StartDate'] as Timestamp?;
                        final endTimestamp = data['EndDate'] as Timestamp?;
                        final completedOn = data['CompletedOn'] as Timestamp?;
                        final taskId = task.id;

                        final isDailyTask = endTimestamp != null;

                        final isOneTimeTaskToday =
                            !isDailyTask &&
                            (completedOn == null ||
                                (completedOn.toDate().year == today.year &&
                                    completedOn.toDate().month == today.month &&
                                    completedOn.toDate().day == today.day));

                        final isDailyTaskToday =
                            isDailyTask &&
                            startTimestamp != null &&
                            endTimestamp != null &&
                            (todayDateOnly.isAtSameMomentAs(
                                  DateTime(
                                    startTimestamp.toDate().year,
                                    startTimestamp.toDate().month,
                                    startTimestamp.toDate().day,
                                  ),
                                ) ||
                                todayDateOnly.isAfter(
                                  startTimestamp.toDate(),
                                )) &&
                            (todayDateOnly.isBefore(
                              DateTime(
                                endTimestamp.toDate().year,
                                endTimestamp.toDate().month,
                                endTimestamp.toDate().day,
                              ).add(const Duration(days: 1)),
                            ));

                        if (!isOneTimeTaskToday && !isDailyTaskToday) {
                          return null;
                        }

                        // check if daily task completed today
                        DocumentSnapshot? completedDoc;
                        try {
                          completedDoc = completedDocs.firstWhere(
                            (doc) =>
                                (doc.data()
                                        as Map<String, dynamic>)['TaskId'] ==
                                    taskId &&
                                (doc.data() as Map<String, dynamic>)['Date']
                                        .toDate()
                                        .year ==
                                    today.year &&
                                (doc.data() as Map<String, dynamic>)['Date']
                                        .toDate()
                                        .month ==
                                    today.month &&
                                (doc.data() as Map<String, dynamic>)['Date']
                                        .toDate()
                                        .day ==
                                    today.day,
                          );
                        } catch (e) {
                          completedDoc = null;
                        }

                        Timestamp? dailyCompletedOn;
                        if (completedDoc != null) {
                          dailyCompletedOn =
                              (completedDoc.data()
                                  as Map<String, dynamic>)['Date'];
                        }

                        final isCompleted =
                            isOneTimeTaskToday
                                ? (status == true)
                                : (dailyCompletedOn != null);

                        // build card widget (your existing container)
                        final card = Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.white, Colors.grey[100]!],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['Title'],
                                style: Theme.of(
                                  context,
                                ).textTheme.titleMedium!.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: primary_color,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Category: ${data['Category']}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Notes: ${data['Note'] ?? '---'}',
                                style: Theme.of(context).textTheme.bodyMedium!
                                    .copyWith(color: Colors.grey[700]),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Task Type: ${isDailyTask ? 'Daily Task' : 'One Time'}',
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyMedium!.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color:
                                      isDailyTask ? Colors.teal : Colors.orange,
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (isOneTimeTaskToday)
                                Text(
                                  status == true
                                      ? '✔ Completed at ${completedOn != null ? DateFormat('HH:mm').format(completedOn.toDate()) : 'Time Unknown'}'
                                      : '❌ Incomplete',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium!.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: status ? Colors.green : Colors.red,
                                  ),
                                ),
                              if (isDailyTaskToday)
                                dailyCompletedOn != null
                                    ? Text(
                                      '✔ Completed at ${DateFormat('HH:mm').format(dailyCompletedOn.toDate())}',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium!.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.green,
                                      ),
                                    )
                                    : _buildCountdownTimer(endTimestamp!),
                            ],
                          ),
                        );

                        return {'widget': card, 'isCompleted': isCompleted};
                      })
                      .where((item) => item != null)
                      .toList();

              // Sort: incomplete first, then completed
              taskCardItems.sort((a, b) {
                final aCompleted = a!['isCompleted'] == true;
                final bCompleted = b!['isCompleted'] == true;
                if (aCompleted == bCompleted) return 0;
                return aCompleted ? 1 : -1; // incomplete first
              });

              if (taskCardItems.isEmpty) {
                return const Center(
                  child: Text(
                    'No tasks found for today.',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                );
              }

              return ListView(
                padding: const EdgeInsets.all(16),
                children:
                    taskCardItems
                        .map((item) => item!['widget'] as Widget)
                        .toList(),
              );
            },
          );
        },
      ),
    );
  }
}
