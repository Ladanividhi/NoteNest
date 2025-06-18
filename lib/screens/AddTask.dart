import 'package:NoteNest/utils/Constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({super.key});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  bool isDailyTask = true;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  DateTime? selectedDate = null;
  String selectedCategory = 'None';

  final List<Map<String, dynamic>> categories = [
    {'name': 'Work', 'icon': Icons.work},
    {'name': 'Personal', 'icon': Icons.person},
    {'name': 'Study', 'icon': Icons.book},
    {'name': 'Health', 'icon': Icons.fitness_center},
    {'name': 'Finance', 'icon': Icons.account_balance_wallet},
    {'name': 'Shopping', 'icon': Icons.shopping_cart},
    {'name': 'Travel', 'icon': Icons.flight},
    {'name': 'Important', 'icon': Icons.star},
    {'name': 'Ideas', 'icon': Icons.lightbulb},
    {'name': 'Birthday', 'icon': Icons.cake},
    {'name': 'Project', 'icon': Icons.folder},
    {'name': 'Reading', 'icon': Icons.menu_book},
    {'name': 'Movies', 'icon': Icons.tv},
    {'name': 'Others', 'icon': Icons.more_horiz},
    {'name': 'None', 'icon': Icons.not_interested},
  ];

  Future<void> pickDate() async {
    final DateTime today = DateTime.now();
    final DateTime nextYear = DateTime(today.year + 1, today.month, today.day);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? today,
      firstDate: today,
      lastDate: nextYear,
      builder: (context, child) {
        return Theme(data: Theme.of(context), child: child!);
      },
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    print(user != null ? 'User logged in: ${user.uid}' : 'User not logged in');
  }

  void saveTask() async {
    if (titleController.text.isEmpty) {
      Fluttertoast.showToast(
        msg: "Please enter task title",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }

    if (isDailyTask && selectedDate == null) {
      Fluttertoast.showToast(
        msg: "Please select an end date",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        Fluttertoast.showToast(
          msg: "User not logged in",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
        return;
      }

      final taskData = {
        'Category': selectedCategory,
        'Id': user.uid,
        'Date': selectedDate != null ? Timestamp.fromDate(selectedDate!) : null,
        'Note': noteController.text.isEmpty ? null : noteController.text,
        'Title': titleController.text,
        'Status': false,
        'CompletedOn': null,
      };

      await FirebaseFirestore.instance.collection('Tasks').add(taskData);

      Fluttertoast.showToast(
        msg: "Task added successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );

      // Clear fields after saving
      setState(() {
        titleController.clear();
        noteController.clear();
        selectedCategory = 'None';
        selectedDate = null;
      });

    } catch (e) {
      print('Error adding task: $e');
      Fluttertoast.showToast(
        msg: "Failed to add task",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: bg_color,
      appBar: AppBar(
        title: const Text(
          'Add Task',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold, // Title text in white
          ),
        ),
        backgroundColor: primary_color,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white, // Back arrow in white
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const SizedBox(height: 12),
            TextField(
              controller: titleController,
              style: textTheme.bodyLarge,
              decoration: const InputDecoration(
                labelText: 'Task Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: noteController,
              maxLines: 3,
              style: textTheme.bodyLarge,
              decoration: const InputDecoration(
                alignLabelWithHint: true,
                labelText: 'Notes (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'Select Category',
              style: textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            // Category Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: categories.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 1,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = selectedCategory == category['name'];

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategory = category['name'];
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? primary_color : bg_color,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? primary_color : Colors.grey.withOpacity(0.3),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 3,
                          offset: const Offset(1, 1),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          category['icon'],
                          size: 22, // 👈 reduced from 28 to 22
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          category['name'],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12, // 👈 slightly smaller font size too
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            Container(
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
                  //Switch Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Set as Daily Task',
                              style: textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Repeat this task daily until the end date',
                              style: textTheme.bodyMedium!.copyWith(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: isDailyTask,
                        onChanged: (value) {
                          setState(() {
                            isDailyTask = value;
                          });
                        },
                        activeColor: primary_color,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // End Date Picker (visible when switch is on)
                  if (isDailyTask)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'End Date',
                          style: textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: pickDate,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  selectedDate != null
                                      ? DateFormat('MMM d, yyyy').format(selectedDate!)
                                      : 'Pick an end date',
                                  style: textTheme.bodyLarge,
                                ),
                                Icon(Icons.calendar_today, color: primary_color, size: 22),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),

            const SizedBox(height: 32),


            // Save Button
            ElevatedButton(
              onPressed: saveTask,
              style: ElevatedButton.styleFrom(
                backgroundColor: primary_color,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Save Task',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
