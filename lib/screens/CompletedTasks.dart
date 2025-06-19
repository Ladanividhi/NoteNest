import 'package:NoteNest/utils/Constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CompletedTasksPage extends StatefulWidget {
  const CompletedTasksPage({super.key});

  @override
  State<CompletedTasksPage> createState() => _CompletedTasksPageState();
}

class _CompletedTasksPageState extends State<CompletedTasksPage> {
  final user = FirebaseAuth.instance.currentUser;
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: bg_color,
      appBar: AppBar(
        title: const Text(
          'Completed Tasks',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primary_color,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search tasks...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Task list
          Expanded(
            child: FutureBuilder<QuerySnapshot>(
              future:
                  FirebaseFirestore.instance
                      .collection('TaskCompleted')
                      .where('Id', isEqualTo: user?.uid)
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
                final today = DateTime.now();
                final todayOnly = DateTime(today.year, today.month, today.day);

                final completedTaskDocs = completedSnapshot.data!.docs;

                final completedTaskIdsToday =
                    completedTaskDocs
                        .where((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          if (!data.containsKey('Date')) return false;
                          final completedDate =
                              (data['Date'] as Timestamp).toDate();
                          return completedDate.year == today.year &&
                              completedDate.month == today.month &&
                              completedDate.day == today.day;
                        })
                        .map(
                          (doc) =>
                              (doc.data() as Map<String, dynamic>)['TaskId'],
                        )
                        .toSet();

                // Now fetch all Tasks
                return StreamBuilder<QuerySnapshot>(
                  stream:
                      FirebaseFirestore.instance
                          .collection('Tasks')
                          .where('Id', isEqualTo: user?.uid)
                          .snapshots(),
                  builder: (context, taskSnapshot) {
                    if (taskSnapshot.hasError) {
                      return const Center(child: Text('Error loading tasks.'));
                    }
                    if (!taskSnapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    var allTasks = taskSnapshot.data!.docs;

                    // Filter completed one-time tasks (Status == true)
                    var oneTimeCompletedTasks =
                        allTasks.where((task) {
                          final data = task.data() as Map<String, dynamic>;
                          final status = data['Status'];
                          final endDate = data['EndDate'];
                          return endDate == null && status == true;
                        }).toList();

                    // Filter completed daily tasks (StartDate ≤ today ≤ EndDate && completed today)
                    var dailyCompletedTasks =
                        allTasks.where((task) {
                          final data = task.data() as Map<String, dynamic>;
                          final startTimestamp =
                              data['StartDate'] as Timestamp?;
                          final endTimestamp = data['EndDate'] as Timestamp?;
                          final taskId = task.id;

                          if (startTimestamp == null || endTimestamp == null)
                            return false;

                          final startDate = DateTime(
                            startTimestamp.toDate().year,
                            startTimestamp.toDate().month,
                            startTimestamp.toDate().day,
                          );
                          final endDate = DateTime(
                            endTimestamp.toDate().year,
                            endTimestamp.toDate().month,
                            endTimestamp.toDate().day,
                          );

                          final isTodayInRange =
                              (todayOnly.isAtSameMomentAs(startDate) ||
                                  todayOnly.isAfter(startDate)) &&
                              (todayOnly.isAtSameMomentAs(endDate) ||
                                  todayOnly.isBefore(
                                    endDate.add(const Duration(days: 1)),
                                  ));

                          final isCompletedToday = completedTaskIdsToday
                              .contains(taskId);

                          return isTodayInRange && isCompletedToday;
                        }).toList();

                    // Combine both lists
                    var completedTasks = [
                      ...dailyCompletedTasks,
                      ...oneTimeCompletedTasks,
                    ];

                    // Apply search
                    completedTasks =
                        completedTasks.where((task) {
                          final title = task['Title'].toString().toLowerCase();
                          final category =
                              task['Category'].toString().toLowerCase();
                          return title.contains(searchQuery) ||
                              category.contains(searchQuery);
                        }).toList();

                    // Sort: daily first (by EndDate desc), then one-time
                    completedTasks.sort((a, b) {
                      final aDate = a['EndDate'];
                      final bDate = b['EndDate'];
                      if (aDate == null && bDate == null) return 0;
                      if (aDate == null) return 1;
                      if (bDate == null) return -1;
                      return bDate.toDate().compareTo(aDate.toDate());
                    });

                    if (completedTasks.isEmpty) {
                      return const Center(
                        child: Text('No completed tasks found.'),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: completedTasks.length,
                      itemBuilder: (context, index) {
                        final task = completedTasks[index];

                        DocumentSnapshot? completedDoc;
                        try {
                          completedDoc = completedTaskDocs.firstWhere(
                                (doc) => (doc.data() as Map<String, dynamic>)['TaskId'] == task.id,
                          );
                        } catch (e) {
                          completedDoc = null;
                        }


                        final completedOn = completedDoc != null
                            ? (completedDoc.data() as Map<String, dynamic>)['Date'] as Timestamp
                            : null;

                        // 🔻 Pass this into your task card builder
                        return _buildTaskCard(
                          task,
                          Theme.of(context).textTheme,
                          completedOn,
                        );
                      },
                    );

                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(
      DocumentSnapshot task,
      TextTheme textTheme,
      Timestamp? completedOn,
      ) {
    final isDailyTask = task['EndDate'] != null;

    // For one-time task, get CompletedOn from task doc itself
    final oneTimeCompletedOn = !isDailyTask ? task['CompletedOn'] as Timestamp? : null;

    return Container(
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
            task['Title'],
            style: textTheme.titleMedium!.copyWith(
              fontWeight: FontWeight.bold,
              color: primary_color,
            ),
          ),
          const SizedBox(height: 8),

          Text('Category: ${task['Category']}', style: textTheme.bodyMedium),
          const SizedBox(height: 8),

          Text(
            'Notes: ${task['Note'] ?? '---'}',
            style: textTheme.bodyMedium!.copyWith(color: Colors.grey[700]),
          ),
          const SizedBox(height: 8),

          Text(
            'Task Type: ${isDailyTask ? 'Daily Task' : 'One Time Task'}',
            style: textTheme.bodyMedium!.copyWith(
              fontWeight: FontWeight.w600,
              color: isDailyTask ? Colors.teal : Colors.orange,
            ),
          ),

          if (isDailyTask)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'End Date: ${DateFormat('MMM d, yyyy').format(task['EndDate'].toDate())}',
                style: textTheme.bodyMedium!.copyWith(color: Colors.grey[600]),
              ),
            ),

          // Daily Task Completed Time (from TaskCompleted table)
          if (isDailyTask && completedOn != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Completed On: ${DateFormat('HH:mm').format(completedOn.toDate())}',
                style: textTheme.bodyMedium!.copyWith(
                  color: Colors.green[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

          // One Time Task Completed Time (from Tasks table)
          if (!isDailyTask && oneTimeCompletedOn != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Completed At: ${DateFormat('HH:mm').format(oneTimeCompletedOn.toDate())}',
                style: textTheme.bodyMedium!.copyWith(
                  color: Colors.green[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }



}
