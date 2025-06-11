import 'package:NoteNest/utils/Constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddDailyTaskPage extends StatefulWidget {
  const AddDailyTaskPage({super.key});

  @override
  State<AddDailyTaskPage> createState() => _AddDailyTaskPageState();
}

class _AddDailyTaskPageState extends State<AddDailyTaskPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  DateTime? selectedDate;
  String selectedCategory = 'Work';

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
    {'name': 'Miscellaneous', 'icon': Icons.more_horiz},
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
        return Theme(
          data: Theme.of(context),
          child: child!,
        );
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter task title')),
      );
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not logged in')),
        );
        return;
      }

      final taskData = {
        'Category': selectedCategory,
        'Date': Timestamp.fromDate(DateTime.now()),      // today's date
        'Id': user.uid,                                  // current user id
        'LastDate': Timestamp.fromDate(selectedDate!),   // selected due date
        'Note': noteController.text,
        'Status': false,                                  // default status
        'Title': titleController.text,                    // add title too
      };

      await FirebaseFirestore.instance.collection('DailyTask').add(taskData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task added successfully')),
      );

      Navigator.pop(context);
    } catch (e) {
      print('Error adding task: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add task')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      // backgroundColor: bg_color,
        appBar: AppBar(
          title: const Text(
            'Add Daily Task',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,// Title text in white
            ),
          ),
          backgroundColor: primaryColor,
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
              style: textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            // Category Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: categories.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
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
                      color: isSelected ? primaryColor : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? primaryColor : Colors.grey.withOpacity(0.4),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(1, 1),
                        )
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          category['icon'],
                          size: 28,
                          color: isSelected ? Colors.white : primaryColor,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          category['name'],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
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

            Text(
              'How long do you like to keep this as your daily task?',
              style: textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            GestureDetector(
              onTap: pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  border: Border.all(color: Colors.grey.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selectedDate != null
                          ? DateFormat('MMM d, yyyy').format(selectedDate!)
                          : 'Pick a date',
                      style: textTheme.bodyLarge,
                    ),
                    Icon(Icons.calendar_today, color: primaryColor, size: 22),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Save Button
            ElevatedButton(
              onPressed: saveTask,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Save Task',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            )
          ],
        ),
      ),
    );
  }
}
