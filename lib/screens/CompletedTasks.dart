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
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Task list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Tasks')
                  .where('Id', isEqualTo: user?.uid)
                  .where('Status', isEqualTo: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading tasks.'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                var tasks = snapshot.data!.docs.where((task) {
                  final title = task['Title'].toString().toLowerCase();
                  final category = task['Category'].toString().toLowerCase();
                  return title.contains(searchQuery) || category.contains(searchQuery);
                }).toList();

                // Sort manually descending by Date (daily first, then one-time)
                tasks.sort((a, b) {
                  final aDate = a['Date'];
                  final bDate = b['Date'];
                  if (aDate == null && bDate == null) return 0;
                  if (aDate == null) return 1;  // b before a
                  if (bDate == null) return -1; // a before b
                  return bDate.toDate().compareTo(aDate.toDate());
                });

                if (tasks.isEmpty) {
                  return const Center(child: Text('No completed tasks found.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return _buildTaskCard(task, textTheme);
                  },
                );
              },
            ),
          )

        ],
      ),
    );
  }

  Widget _buildTaskCard(DocumentSnapshot task, TextTheme textTheme) {
    final isDailyTask = task['Date'] != null;

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
          // Title
          Text(
            task['Title'],
            style: textTheme.titleMedium!.copyWith(
              fontWeight: FontWeight.bold,
              color: primary_color,
            ),
          ),
          const SizedBox(height: 8),

          // Category
          Text(
            'Category: ${task['Category']}',
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),

          // Notes
          Text(
            'Notes: ${task['Note'] ?? '---'}',
            style: textTheme.bodyMedium!.copyWith(color: Colors.grey[700]),
          ),
          const SizedBox(height: 8),

          // Task Type
          Text(
            'Task Type: ${isDailyTask ? 'Daily Task' : 'One Time Task'}',
            style: textTheme.bodyMedium!.copyWith(
              fontWeight: FontWeight.w600,
              color: isDailyTask ? Colors.teal : Colors.orange,
            ),
          ),

          // End Date (if Daily Task)
          if (isDailyTask)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'End Date: ${DateFormat('MMM d, yyyy').format(task['Date'].toDate())}',
                style: textTheme.bodyMedium!.copyWith(color: Colors.grey[600]),
              ),
            ),
        ],
      ),
    );
  }
}
