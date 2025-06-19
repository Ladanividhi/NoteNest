import 'package:NoteNest/utils/Constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TaskHistoryPage extends StatefulWidget {
  const TaskHistoryPage({super.key});

  @override
  State<TaskHistoryPage> createState() => _TaskHistoryPageState();
}

class _TaskHistoryPageState extends State<TaskHistoryPage> {
  final user = FirebaseAuth.instance.currentUser;

  PopupMenuItem<String> _buildPopupItem(
    String text,
    String value,
    IconData icon,
  ) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: primary_color, size: 20),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

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

  void _fetchTodayTasks(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => Scaffold(
              backgroundColor: bg_color,
              appBar: AppBar(
                title: const Text(
                  "Today's Tasks",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: primary_color,
                elevation: 0,
                iconTheme: const IconThemeData(color: Colors.white),
              ),
              body: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('Tasks')
                        .where(
                          'Id',
                          isEqualTo: FirebaseAuth.instance.currentUser?.uid,
                        )
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text('Error loading tasks.'));
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final allTasks = snapshot.data!.docs;
                  final today = DateTime.now();
                  final todayDateOnly = DateTime(
                    today.year,
                    today.month,
                    today.day,
                  );

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

                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: allTasks.length,
                        itemBuilder: (context, index) {
                          final task = allTasks[index];
                          final data = task.data() as Map<String, dynamic>;
                          final status = data['Status'];
                          final startTimestamp =
                              data['StartDate'] as Timestamp?;
                          final endTimestamp = data['EndDate'] as Timestamp?;
                          final completedOn = data['CompletedOn'] as Timestamp?;
                          final taskId = task.id;

                          final isDailyTask = endTimestamp != null;

                          final isOneTimeTaskToday =
                              !isDailyTask &&
                              (completedOn == null ||
                                  (completedOn.toDate().year == today.year &&
                                      completedOn.toDate().month ==
                                          today.month &&
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
                            return const SizedBox.shrink();
                          }

                          // Find if daily task is completed today
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
                                        isDailyTask
                                            ? Colors.teal
                                            : Colors.orange,
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
                        },
                      );
                    },
                  );
                },
              ),
            ),
      ),
    );
  }

  void _fetchYesterdaysTasks(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final yesterdayDateOnly = DateTime(
      yesterday.year,
      yesterday.month,
      yesterday.day,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => Scaffold(
              backgroundColor: bg_color,
              appBar: AppBar(
                title: const Text(
                  "Yesterday's Tasks",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: primary_color,
                elevation: 0,
                iconTheme: const IconThemeData(color: Colors.white),
              ),
              body: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('Tasks')
                        .where('Id', isEqualTo: user?.uid)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError)
                    return const Center(child: Text('Error loading tasks.'));
                  if (!snapshot.hasData)
                    return const Center(child: CircularProgressIndicator());

                  final allTasks = snapshot.data!.docs;

                  return FutureBuilder<QuerySnapshot>(
                    future:
                        FirebaseFirestore.instance
                            .collection('TaskCompleted')
                            .where('Id', isEqualTo: user?.uid)
                            .get(),
                    builder: (context, completedSnapshot) {
                      if (completedSnapshot.hasError)
                        return const Center(
                          child: Text('Error loading completed tasks.'),
                        );
                      if (!completedSnapshot.hasData)
                        return const Center(child: CircularProgressIndicator());

                      final completedDocs = completedSnapshot.data!.docs;

                      // Collect tasks falling under yesterday's filter
                      final yesterdaysTasks =
                          allTasks.where((task) {
                            final data = task.data() as Map<String, dynamic>;
                            final status = data['Status'];
                            final startTimestamp =
                                data['StartDate'] as Timestamp?;
                            final endTimestamp = data['EndDate'] as Timestamp?;
                            final completedOn =
                                data['CompletedOn'] as Timestamp?;
                            final taskId = task.id;

                            final isDailyTask = endTimestamp != null;

                            final isOneTimeTaskYesterday =
                                !isDailyTask &&
                                completedOn != null &&
                                completedOn.toDate().year == yesterday.year &&
                                completedOn.toDate().month == yesterday.month &&
                                completedOn.toDate().day == yesterday.day;

                            final isDailyTaskYesterday =
                                isDailyTask &&
                                startTimestamp != null &&
                                endTimestamp != null &&
                                (yesterdayDateOnly.isAtSameMomentAs(
                                      DateTime(
                                        startTimestamp.toDate().year,
                                        startTimestamp.toDate().month,
                                        startTimestamp.toDate().day,
                                      ),
                                    ) ||
                                    yesterdayDateOnly.isAfter(
                                      startTimestamp.toDate(),
                                    )) &&
                                (yesterdayDateOnly.isBefore(
                                  DateTime(
                                    endTimestamp.toDate().year,
                                    endTimestamp.toDate().month,
                                    endTimestamp.toDate().day,
                                  ).add(const Duration(days: 1)),
                                ));

                            return isOneTimeTaskYesterday ||
                                isDailyTaskYesterday;
                          }).toList();

                      if (yesterdaysTasks.isEmpty) {
                        return const Center(
                          child: Text(
                            'No tasks found.',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: yesterdaysTasks.length,
                        itemBuilder: (context, index) {
                          final task = yesterdaysTasks[index];
                          final data = task.data() as Map<String, dynamic>;
                          final status = data['Status'];
                          final startTimestamp =
                              data['StartDate'] as Timestamp?;
                          final endTimestamp = data['EndDate'] as Timestamp?;
                          final completedOn = data['CompletedOn'] as Timestamp?;
                          final taskId = task.id;

                          final isDailyTask = endTimestamp != null;

                          // Check if daily task was completed yesterday
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
                                      yesterday.year &&
                                  (doc.data() as Map<String, dynamic>)['Date']
                                          .toDate()
                                          .month ==
                                      yesterday.month &&
                                  (doc.data() as Map<String, dynamic>)['Date']
                                          .toDate()
                                          .day ==
                                      yesterday.day,
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
                                        isDailyTask
                                            ? Colors.teal
                                            : Colors.orange,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (!isDailyTask)
                                  Text(
                                    '✔ Completed at ${DateFormat('HH:mm').format(completedOn!.toDate())}',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium!.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.green,
                                    ),
                                  ),
                                if (isDailyTask)
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
                                      : Text(
                                        '❌ Not Completed',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium!.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.red,
                                        ),
                                      ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
      ),
    );
  }

  void _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020), // or any suitable project start date
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      _fetchTasksForDate(context, pickedDate);
    }
  }

  void _fetchTasksForDate(BuildContext context, DateTime selectedDate) {
    final user = FirebaseAuth.instance.currentUser;
    final dateOnly = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => Scaffold(
              backgroundColor: bg_color,
              appBar: AppBar(
                title: Text(
                  "${DateFormat('MMM d, yyyy').format(selectedDate)} Tasks",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: primary_color,
                elevation: 0,
                iconTheme: const IconThemeData(color: Colors.white),
              ),
              body: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('Tasks')
                        .where('Id', isEqualTo: user?.uid)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError)
                    return const Center(child: Text('Error loading tasks.'));
                  if (!snapshot.hasData)
                    return const Center(child: CircularProgressIndicator());

                  final allTasks = snapshot.data!.docs;

                  return FutureBuilder<QuerySnapshot>(
                    future:
                        FirebaseFirestore.instance
                            .collection('TaskCompleted')
                            .where('Id', isEqualTo: user?.uid)
                            .get(),
                    builder: (context, completedSnapshot) {
                      if (completedSnapshot.hasError)
                        return const Center(
                          child: Text('Error loading completed tasks.'),
                        );
                      if (!completedSnapshot.hasData)
                        return const Center(child: CircularProgressIndicator());

                      final completedDocs = completedSnapshot.data!.docs;

                      // Filter tasks for selected date
                      final selectedDateTasks =
                          allTasks.where((task) {
                            final data = task.data() as Map<String, dynamic>;
                            final status = data['Status'];
                            final startTimestamp =
                                data['StartDate'] as Timestamp?;
                            final endTimestamp = data['EndDate'] as Timestamp?;
                            final completedOn =
                                data['CompletedOn'] as Timestamp?;
                            final taskId = task.id;

                            final isDailyTask = endTimestamp != null;

                            final isOneTimeTaskOnDate =
                                !isDailyTask &&
                                completedOn != null &&
                                completedOn.toDate().year ==
                                    selectedDate.year &&
                                completedOn.toDate().month ==
                                    selectedDate.month &&
                                completedOn.toDate().day == selectedDate.day;

                            final isDailyTaskOnDate =
                                isDailyTask &&
                                startTimestamp != null &&
                                endTimestamp != null &&
                                (dateOnly.isAtSameMomentAs(
                                      DateTime(
                                        startTimestamp.toDate().year,
                                        startTimestamp.toDate().month,
                                        startTimestamp.toDate().day,
                                      ),
                                    ) ||
                                    dateOnly.isAfter(
                                      startTimestamp.toDate(),
                                    )) &&
                                (dateOnly.isBefore(
                                  DateTime(
                                    endTimestamp.toDate().year,
                                    endTimestamp.toDate().month,
                                    endTimestamp.toDate().day,
                                  ).add(const Duration(days: 1)),
                                ));

                            return isOneTimeTaskOnDate || isDailyTaskOnDate;
                          }).toList();

                      if (selectedDateTasks.isEmpty) {
                        return const Center(
                          child: Text(
                            'No tasks found.',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: selectedDateTasks.length,
                        itemBuilder: (context, index) {
                          final task = selectedDateTasks[index];
                          final data = task.data() as Map<String, dynamic>;
                          final startTimestamp =
                              data['StartDate'] as Timestamp?;
                          final endTimestamp = data['EndDate'] as Timestamp?;
                          final completedOn = data['CompletedOn'] as Timestamp?;
                          final taskId = task.id;

                          final isDailyTask = endTimestamp != null;

                          // Check if daily task was completed on selected date
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
                                      selectedDate.year &&
                                  (doc.data() as Map<String, dynamic>)['Date']
                                          .toDate()
                                          .month ==
                                      selectedDate.month &&
                                  (doc.data() as Map<String, dynamic>)['Date']
                                          .toDate()
                                          .day ==
                                      selectedDate.day,
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
                                  data['Title'],
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium!.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: primary_color,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text('Category: ${data['Category']}'),
                                const SizedBox(height: 6),
                                Text('Notes: ${data['Note'] ?? '---'}'),
                                const SizedBox(height: 8),
                                Text(
                                  'Task Type: ${isDailyTask ? 'Daily Task' : 'One Time'}',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium!.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color:
                                        isDailyTask
                                            ? Colors.teal
                                            : Colors.orange,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (!isDailyTask)
                                  Text(
                                    '✔ Completed at ${DateFormat('HH:mm').format(completedOn!.toDate())}',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium!.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.green,
                                    ),
                                  ),
                                if (isDailyTask)
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
                                      : Text(
                                        '❌ Not Completed',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium!.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.red,
                                        ),
                                      ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
      ),
    );
  }

  Widget buildTillNowTasksPage(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: bg_color,
      appBar: AppBar(
        title: const Text(
          "Task History (Till Now)",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: primary_color,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Tasks')
            .where('Id', isEqualTo: user?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError)
            return const Center(child: Text('Error loading tasks.'));
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          final allTasks = snapshot.data!.docs;

          return FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance
                .collection('TaskCompleted')
                .where('Id', isEqualTo: user?.uid)
                .get(),
            builder: (context, completedSnapshot) {
              if (completedSnapshot.hasError)
                return const Center(
                  child: Text('Error loading completion logs.'),
                );
              if (!completedSnapshot.hasData)
                return const Center(child: CircularProgressIndicator());

              final completedDocs = completedSnapshot.data!.docs;

              final sortedTasks = List.from(allTasks)..sort((a, b) {
                final aData = a.data() as Map<String, dynamic>;
                final bData = b.data() as Map<String, dynamic>;
                final aEnd = aData['EndDate'];
                final bEnd = bData['EndDate'];
                final aComp = aData['CompletedOn'];
                final bComp = bData['CompletedOn'];

                if (aEnd == null && bEnd == null) {
                  if (aComp == null && bComp == null) return 0;
                  if (aComp == null) return 1;
                  if (bComp == null) return -1;
                  return bComp.toDate().compareTo(aComp.toDate());
                }

                if (aEnd == null) return 1;
                if (bEnd == null) return -1;
                return bEnd.toDate().compareTo(aEnd.toDate());
              });

              if (sortedTasks.isEmpty) {
                return const Center(
                  child: Text(
                    'No tasks found.',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: sortedTasks.length,
                itemBuilder: (context, index) {
                  final task = sortedTasks[index];
                  final data = task.data() as Map<String, dynamic>;
                  final startTimestamp = data['StartDate'] as Timestamp?;
                  final endTimestamp = data['EndDate'] as Timestamp?;
                  final completedOn = data['CompletedOn'] as Timestamp?;
                  final taskId = task.id;
                  final isDailyTask = endTimestamp != null;
                  String dateLabel;

                  if (isDailyTask) {
                    dateLabel =
                    'Till ${DateFormat('MMM d, yyyy').format(endTimestamp!.toDate())}';
                  } else {
                    dateLabel = completedOn != null
                        ? DateFormat('MMM d, yyyy').format(completedOn.toDate())
                        : 'Not Completed';
                  }

                  final dailyCompletions = completedDocs.where(
                        (doc) =>
                    (doc.data() as Map<String, dynamic>)['TaskId'] == taskId,
                  );

                  final statusText = isDailyTask
                      ? '✔ Completed ${dailyCompletions.length} times'
                      : (data['Status'] == true
                      ? '✔ Completed at ${completedOn != null ? DateFormat('HH:mm, MMM d').format(completedOn.toDate()) : 'Time Unknown'}'
                      : '❌ Incomplete');

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
                          data['Title'],
                          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            fontWeight: FontWeight.bold,
                            color: primary_color,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('Category: ${data['Category']}'),
                        const SizedBox(height: 6),
                        Text('Notes: ${data['Note'] ?? '---'}'),
                        const SizedBox(height: 8),
                        Text(
                          'Task Type: ${isDailyTask ? 'Daily Task' : 'One Time'}',
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isDailyTask ? Colors.teal : Colors.orange,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Date: $dateLabel',
                          style: Theme.of(context).textTheme.bodyMedium!
                              .copyWith(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          statusText,
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            fontWeight: FontWeight.w600,
                            color: statusText.contains('Incomplete')
                                ? Colors.red
                                : Colors.green,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: bg_color,
      appBar: AppBar(
        title: const Text(
          'Task History',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primary_color,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              switch (value) {
                case 'today':
                  _fetchTodayTasks(context);
                  break;
                case 'yesterday':
                  _fetchYesterdaysTasks(context);
                  break;
                case 'select_date':
                  _selectDate(context);
                  break;
              }
            },
            itemBuilder:
                (context) => [
                  _buildPopupItem('Today', 'today', Icons.today),
                  _buildPopupItem(
                    'Yesterday',
                    'yesterday',
                    Icons.calendar_today,
                  ),
                  _buildPopupItem(
                    'Select Date',
                    'select_date',
                    Icons.date_range,
                  ),
                ],
          ),
        ],
      ),
      body: buildTillNowTasksPage(context),

    );
  }
}
