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
          stream:
              FirebaseFirestore.instance
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

            final tasks = snapshot.data!.docs;

            final dailyTasks =
                tasks.where((task) => task['Date'] != null).toList();
            final otherTasks =
                tasks.where((task) => task['Date'] == null).toList();

            if (tasks.isEmpty) {
              return const Center(child: Text('No tasks found.'));
            }

            return ListView(
              children: [
                if (dailyTasks.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      'Daily Tasks',
                      style: textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ...dailyTasks.map((task) => _buildTaskCard(task, textTheme)),

                if (otherTasks.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 10),
                    child: Text(
                      'One Time Tasks',
                      style: textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ...otherTasks.map((task) => _buildTaskCard(task, textTheme)),
              ],
            );
          },
        ),
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
              IconButton(
                icon: const Icon(Icons.edit, color: primary_color),
                onPressed: () => _showEditDialog(task),
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
          if (task['Date'] != null)
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

  void _showEditDialog(DocumentSnapshot task) async {
    final titleController = TextEditingController(text: task['Title']);
    final noteController = TextEditingController(text: task['Note'] ?? '');
    String selectedCategory = task['Category'];
    DateTime? selectedDate = task['Date']?.toDate();
    bool isDailyTask = task['Date'] != null;

    // First ask about conversion
    bool wantsToConvert = await _askConfirmation(
      'Change Task Type?',
      isDailyTask
          ? 'Do you want to convert this Daily Task to a One-Time Task?'
          : 'Do you want to convert this One-Time Task to a Daily Task?',
    );

    if (wantsToConvert) {
      if (isDailyTask) {
        // convert to one-time task by nullifying date
        await FirebaseFirestore.instance
            .collection('Tasks')
            .doc(task.id)
            .update({'Date': null});
        selectedDate = null;
        isDailyTask = false;
      } else {
        // convert to daily task by picking new date
        DateTime? newDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now().add(const Duration(days: 1)),
          firstDate: DateTime.now().add(const Duration(days: 1)),
          lastDate: DateTime(2100),
        );
        if (newDate != null) {
          await FirebaseFirestore.instance
              .collection('Tasks')
              .doc(task.id)
              .update({'Date': Timestamp.fromDate(newDate)});
          selectedDate = newDate;
          isDailyTask = true;
        }
      }
    } else {
      // Directly open edit alert box without type conversion
      showDialog(
        context: context,
        builder: (context) {
          final textTheme = Theme.of(context).textTheme;

          return StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: const Text('Edit Task'),
                  content: SingleChildScrollView(
                    child: Column(
                      children: [
                        TextField(
                          controller: titleController,
                          decoration: const InputDecoration(labelText: 'Title'),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: noteController,
                          maxLines: 2,
                          decoration: const InputDecoration(labelText: 'Notes'),
                        ),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<String>(
                          value: selectedCategory,
                          items:
                              categories.map((cat) {
                                return DropdownMenuItem(
                                  value: cat,
                                  child: Text(cat),
                                );
                              }).toList(),
                          onChanged:
                              (val) => setState(() => selectedCategory = val!),
                          decoration: const InputDecoration(
                            labelText: 'Category',
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (isDailyTask)
                          GestureDetector(
                            onTap: () async {
                              DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate:
                                    selectedDate ??
                                    DateTime.now().add(const Duration(days: 1)),
                                firstDate: DateTime.now().add(
                                  const Duration(days: 1),
                                ),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) {
                                setState(() => selectedDate = picked);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    selectedDate != null
                                        ? DateFormat(
                                          'MMM d, yyyy',
                                        ).format(selectedDate!)
                                        : 'Pick end date',
                                    style: textTheme.bodyMedium,
                                  ),
                                  const Icon(
                                    Icons.calendar_today,
                                    size: 18,
                                    color: primary_color,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        const SizedBox(height: 14),
                        ElevatedButton(
                          onPressed: () async {
                            await FirebaseFirestore.instance
                                .collection('Tasks')
                                .doc(task.id)
                                .update({
                                  'Title': titleController.text,
                                  'Note':
                                      noteController.text.isEmpty
                                          ? null
                                          : noteController.text,
                                  'Category': selectedCategory,
                                  'Date':
                                      isDailyTask
                                          ? Timestamp.fromDate(
                                            selectedDate ??
                                                DateTime.now().add(
                                                  const Duration(days: 1),
                                                ),
                                          )
                                          : null,
                                });
                            Navigator.pop(context);
                            Fluttertoast.showToast(
                              msg: 'Task updated successfully',
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary_color,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Save',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          );
        },
      );
    }

    // Now show the Edit Alert Box
    showDialog(
      context: context,
      builder: (context) {
        final textTheme = Theme.of(context).textTheme;

        return StatefulBuilder(
          builder:
              (context, setState) => AlertDialog(
                title: const Text('Edit Task'),
                content: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(labelText: 'Title'),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: noteController,
                        maxLines: 2,
                        decoration: const InputDecoration(labelText: 'Notes'),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: selectedCategory,
                        items:
                            categories.map((cat) {
                              return DropdownMenuItem(
                                value: cat,
                                child: Text(cat),
                              );
                            }).toList(),
                        onChanged:
                            (val) => setState(() => selectedCategory = val!),
                        decoration: const InputDecoration(
                          labelText: 'Category',
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (isDailyTask)
                        GestureDetector(
                          onTap: () async {
                            DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate:
                                  selectedDate ??
                                  DateTime.now().add(const Duration(days: 1)),
                              firstDate: DateTime.now().add(
                                const Duration(days: 1),
                              ),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setState(() => selectedDate = picked);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  selectedDate != null
                                      ? DateFormat(
                                        'MMM d, yyyy',
                                      ).format(selectedDate!)
                                      : 'Pick end date',
                                  style: textTheme.bodyMedium,
                                ),
                                const Icon(
                                  Icons.calendar_today,
                                  size: 18,
                                  color: primary_color,
                                ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 14),
                      ElevatedButton(
                        onPressed: () async {
                          await FirebaseFirestore.instance
                              .collection('Tasks')
                              .doc(task.id)
                              .update({
                                'Title': titleController.text,
                                'Note':
                                    noteController.text.isEmpty
                                        ? null
                                        : noteController.text,
                                'Category': selectedCategory,
                                'Date':
                                    isDailyTask
                                        ? Timestamp.fromDate(
                                          selectedDate ??
                                              DateTime.now().add(
                                                const Duration(days: 1),
                                              ),
                                        )
                                        : null,
                              });

                          Fluttertoast.showToast(
                            msg: 'Task updated successfully',
                          );
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary_color,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                ),
              ),
        );
      },
    );
  }

  Future<bool> _askConfirmation(String title, String message) async {
    bool confirmed = false;
    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () {
                  confirmed = true;
                  Navigator.pop(context);
                },
                child: const Text('Yes'),
              ),
            ],
          ),
    );
    return confirmed;
  }
}
