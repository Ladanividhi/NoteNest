import 'package:NoteNest/utils/Constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class OngoingTasksPage extends StatefulWidget {
  const OngoingTasksPage({super.key});

  @override
  State<OngoingTasksPage> createState() => _OngoingTasksPageState();
}

class _OngoingTasksPageState extends State<OngoingTasksPage> {
  final user = FirebaseAuth.instance.currentUser;
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: bg_color,
      appBar: AppBar(
        title: const Text(
          'Ongoing Tasks',
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
                hintText: 'Search by title or category',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
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
                  .where('Status', isEqualTo: false)
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

                // Sort daily tasks first
                tasks.sort((a, b) {
                  final aDate = a['Date'];
                  final bDate = b['Date'];
                  if (aDate == null && bDate == null) return 0;
                  if (aDate == null) return 1;
                  if (bDate == null) return -1;
                  return bDate.toDate().compareTo(aDate.toDate());
                });

                if (tasks.isEmpty) {
                  return const Center(child: Text('No ongoing tasks found.'));
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
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(DocumentSnapshot task, TextTheme textTheme) {
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Checkbox
          Checkbox(
            value: false,
            onChanged: (value) {
              _showCompleteConfirmation(task);
            },
            activeColor: primary_color,
          ),

          const SizedBox(width: 8),

          // Task content
          Expanded(
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
                const SizedBox(height: 6),
                Text(
                  'Category: ${task['Category']}',
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  'Notes: ${task['Note'] ?? '---'}',
                  style: textTheme.bodyMedium!.copyWith(color: Colors.grey[700]),
                ),
                const SizedBox(height: 6),
                Text(
                  'Type: ${task['Date'] != null ? 'Daily Task' : 'One Time Task'}',
                  style: textTheme.bodyMedium!.copyWith(color: Colors.grey[600]),
                ),
                if (task['Date'] != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      'End Date: ${DateFormat('MMM d, yyyy').format(task['Date'].toDate())}',
                      style: textTheme.bodyMedium!.copyWith(color: Colors.grey[600]),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Confirmation Alert to mark completed
  void _showCompleteConfirmation(DocumentSnapshot task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Mark as Completed'),
        content: const Text('Are you sure you want to mark this task as completed?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await FirebaseFirestore.instance.collection('Tasks').doc(task.id).update({
                'Status': true,
                'CompletedOn': Timestamp.now(),
              });
              Fluttertoast.showToast(msg: 'Task marked as completed');
              setState(() {}); // Refresh screen
            },
            child: Text(
              'Yes',
              style: TextStyle(color: primary_color, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
