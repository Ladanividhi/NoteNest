import 'package:NoteNest/utils/Constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class EditTaskPage extends StatefulWidget {
  const EditTaskPage({super.key});

  @override
  State<EditTaskPage> createState() => _EditTaskPageState();
}

class _EditTaskPageState extends State<EditTaskPage> {
  final user = FirebaseAuth.instance.currentUser;
  final List<String> categories = ['Work', 'Personal', 'Study', 'Health', 'Finance', 'Shopping', 'Travel', 'Important', 'Ideas', 'Birthday', 'Project', 'Reading', 'Movies', 'Others', 'None'];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: bg_color,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text(
          'Edit Tasks',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primary_color,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Tasks')
              .where('Id', isEqualTo: user?.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('Error loading tasks.'));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final tasks = snapshot.data!.docs;

            final today = DateTime.now();
            final todayStart = DateTime(today.year, today.month, today.day);
            final todayEnd = todayStart.add(const Duration(days: 1));

            return FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance
                  .collection('TaskCompleted')
                  .where('Id', isEqualTo: user?.uid)
                  .get(),
              builder: (context, completedSnapshot) {
                if (completedSnapshot.hasError) {
                  return const Center(child: Text('Error loading completed tasks.'));
                }
                if (!completedSnapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final completedTaskIdsToday = completedSnapshot.data!.docs
                    .where((doc) {
                  final date = doc.data().toString().contains('EndDate') ? doc['EndDate'] : null;
                  if (date == null) return false;
                  final completedDate = date.toDate();
                  return completedDate.year == today.year &&
                      completedDate.month == today.month &&
                      completedDate.day == today.day;
                })
                    .map((doc) => doc['TaskId'])
                    .toSet();

                final ongoingTasks = tasks.where((task) {
                  final data = task.data() as Map<String, dynamic>;
                  final status = data['Status'];
                  final start = data['StartDate'] as Timestamp?;
                  final end = data['EndDate'] as Timestamp?;
                  final taskId = task.id;

                  // One-time task: ongoing if Status == false
                  if (end == null) {
                    return status == false;
                  }

                  // Daily task: ongoing if today's date lies between StartDate and EndDate (inclusive)
                  if (start != null && end != null) {
                    final startDate = DateTime(
                      start.toDate().year,
                      start.toDate().month,
                      start.toDate().day,
                    );
                    final endDate = DateTime(
                      end.toDate().year,
                      end.toDate().month,
                      end.toDate().day,
                    );

                    final todayOnly = DateTime(today.year, today.month, today.day);

                    final isInRange = (todayOnly.isAtSameMomentAs(startDate) || todayOnly.isAfter(startDate)) &&
                        (todayOnly.isAtSameMomentAs(endDate) || todayOnly.isBefore(endDate.add(const Duration(days: 1))));

                    return isInRange;
                  }

                  return false;
                }).toList();


                if (ongoingTasks.isEmpty) {
                  return const Center(child: Text('No ongoing tasks found.'));
                }

                // Separate into daily and one-time for display labels
                final dailyTasks = ongoingTasks
                    .where((task) => (task.data() as Map<String, dynamic>)['EndDate'] != null)
                    .toList();
                final oneTimeTasks = ongoingTasks
                    .where((task) => (task.data() as Map<String, dynamic>)['EndDate'] == null)
                    .toList();

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (dailyTasks.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          'Daily Tasks',
                          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ...dailyTasks.map((task) => _buildTaskCard(task, Theme.of(context).textTheme)),

                    if (oneTimeTasks.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 20, bottom: 10),
                        child: Text(
                          'One Time Tasks',
                          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ...oneTimeTasks.map((task) => _buildTaskCard(task, Theme.of(context).textTheme)),
                  ],
                );
              },
            );
          },
        )


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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  task['Title'],
                  style: textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: primary_color,
                  ),
                ),
              ),
              // Edit Icon
              IconButton(
                icon: const Icon(Icons.edit, color: primary_color),
                onPressed: () => _showEditDialog(task),
              ),
              // Delete Icon
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _confirmDeleteTask(task.id),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Category: ${task['Category']}', style: textTheme.bodyMedium),
          const SizedBox(height: 8),
          Text(
            'Notes: ${task['Note'] ?? '---'}',
            style: textTheme.bodyMedium!.copyWith(color: Colors.grey[700]),
          ),
          if (task['EndDate'] != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'End Date: ${DateFormat('MMM d, yyyy').format(task['EndDate'].toDate())}',
                style: textTheme.bodyMedium!.copyWith(color: Colors.grey[600]),
              ),
            ),
        ],
      ),
    );
  }

  void _confirmDeleteTask(String taskId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Task'),
          content: const Text('Are you sure you want to delete this task?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      // Delete task from 'Tasks' collection
      await FirebaseFirestore.instance.collection('Tasks').doc(taskId).delete();

      // Delete related entries from 'TaskCompleted'
      final completedDocs = await FirebaseFirestore.instance
          .collection('TaskCompleted')
          .where('TaskId', isEqualTo: taskId)
          .get();

      for (var doc in completedDocs.docs) {
        await doc.reference.delete();
      }

      if (mounted) {
        Fluttertoast.showToast(
          msg: 'Task deleted successfully!',
        );
        setState(() {}); // Refresh UI
      }
    }
  }


  void _showEditDialog(DocumentSnapshot task) async {
    final titleController = TextEditingController(text: task['Title']);
    final noteController = TextEditingController(text: task['Note'] ?? '');
    String selectedCategory = task['Category'];
    DateTime? selectedDate = task['EndDate']?.toDate();
    bool isDailyTask = task['EndDate'] != null;

    // First ask about conversion
    bool wantsToConvert = await _askConfirmation(
      'Change Task Type?',
      isDailyTask
          ? 'Do you want to convert this Daily Task to a One-Time Task?'
          : 'Do you want to convert this One-Time Task to a Daily Task?',
    );

    if (wantsToConvert) {
      final now = Timestamp.now();

      if (isDailyTask) {
        // Convert Daily → One-Time Task
        await FirebaseFirestore.instance.collection('Tasks').doc(task.id).update({
          'StartDate': now,
          'EndDate': null,
          'Status': false,
        });

        // Delete from TaskCompleted where TaskId matches this task.id
        final completedDocs = await FirebaseFirestore.instance
            .collection('TaskCompleted')
            .where('TaskId', isEqualTo: task.id)
            .get();

        for (var doc in completedDocs.docs) {
          await doc.reference.delete();
        }

        selectedDate = null;
        isDailyTask = false;

      } else {
        // Convert One-Time → Daily Task
        DateTime? newDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now().add(const Duration(days: 1)),
          firstDate: DateTime.now().add(const Duration(days: 1)),
          lastDate: DateTime(2100),
        );

        if (newDate != null) {
          await FirebaseFirestore.instance.collection('Tasks').doc(task.id).update({
            'StartDate': now,
            'EndDate': Timestamp.fromDate(newDate),
            'Status': null,
          });

          selectedDate = newDate;
          isDailyTask = true;
        }
      }
    }

    // Show the Edit Alert Box
    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          final textTheme = Theme.of(context).textTheme;

          return StatefulBuilder(
            builder: (context, setState) => Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
              backgroundColor: Colors.transparent,
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                ),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: primary_color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.edit_rounded,
                              color: primary_color,
                              size: 15,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              'Edit Task',
                              style: textTheme.headlineSmall!.copyWith(
                                fontWeight: FontWeight.bold,
                                color: primary_color,
                                fontSize: 22,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close, color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      // Title Field
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: TextField(
                          controller: titleController,
                          decoration: InputDecoration(
                            labelText: 'Task Title',
                            labelStyle: TextStyle(color: Colors.grey[600]),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            prefixIcon: Icon(Icons.task_alt, color: primary_color, size: 20),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Notes Field
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: TextField(
                          controller: noteController,
                          maxLines: 2,
                          decoration: InputDecoration(
                            labelText: 'Notes (Optional)',
                            labelStyle: TextStyle(color: Colors.grey[600]),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            prefixIcon: Icon(Icons.note, color: primary_color, size: 20),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Category Dropdown
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: DropdownButtonFormField<String>(
                          value: selectedCategory,
                          items: categories.map((cat) {
                            return DropdownMenuItem(
                              value: cat,
                              child: Text(cat),
                            );
                          }).toList(),
                          onChanged: (val) => setState(() => selectedCategory = val!),
                          decoration: InputDecoration(
                            labelText: 'Category',
                            labelStyle: TextStyle(color: Colors.grey[600]),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            prefixIcon: Icon(Icons.category, color: primary_color, size: 20),
                          ),
                          dropdownColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Date Picker (for daily tasks)
                      if (isDailyTask)
                        GestureDetector(
                          onTap: () async {
                            DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate ?? DateTime.now().add(const Duration(days: 1)),
                              firstDate: DateTime.now().add(const Duration(days: 1)),
                              lastDate: DateTime(2100),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: ColorScheme.light(
                                      primary: primary_color,
                                      onPrimary: Colors.white,
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (picked != null) {
                              setState(() => selectedDate = picked);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.calendar_today, color: primary_color, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    selectedDate != null
                                        ? DateFormat('MMM d, yyyy').format(selectedDate!)
                                        : 'Pick end date',
                                    style: textTheme.bodyMedium!.copyWith(color: Colors.grey[700]),
                                  ),
                                ),
                                Icon(Icons.arrow_drop_down, color: primary_color),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),
                      
                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(color: Colors.grey[300]!),
                                ),
                              ),
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                try {
                                  await FirebaseFirestore.instance
                                      .collection('Tasks')
                                      .doc(task.id)
                                      .update({
                                    'Title': titleController.text,
                                    'Note': noteController.text.isEmpty ? null : noteController.text,
                                    'Category': selectedCategory,
                                    'EndDate': isDailyTask
                                        ? Timestamp.fromDate(selectedDate ?? DateTime.now().add(const Duration(days: 1)))
                                        : null,
                                  });
                                  
                                  if (context.mounted) {
                                    Navigator.of(context).pop();
                                    Fluttertoast.showToast(
                                      msg: 'Task updated successfully!',
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    Navigator.of(context).pop();
                                    Fluttertoast.showToast(
                                      msg: 'Error updating task',
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                    );
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primary_color,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Save Changes',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    }
  }

  Future<bool> _askConfirmation(String title, String message) async {
    bool confirmed = false;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: primary_color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.help_outline_rounded,
                  color: primary_color,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              
              // Title
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              
              // Message
              Text(
                message,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        confirmed = false;
                        Navigator.of(context).pop();
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                      child: Text(
                        'No',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        confirmed = true;
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary_color,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Yes',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    return confirmed;
  }
}
