import 'package:NoteNest/screens/AddTask.dart';
import 'package:NoteNest/screens/CompletedTasks.dart';
import 'package:NoteNest/screens/EditTasks.dart';
import 'package:NoteNest/screens/HistoryPage.dart';
import 'package:NoteNest/screens/LoginPage.dart';
import 'package:NoteNest/screens/OngoingTasks.dart';
import 'package:NoteNest/screens/ProfilePAge.dart';
import 'package:NoteNest/screens/Settings.dart';
import 'package:NoteNest/screens/TodayTask.dart';
import 'package:NoteNest/utils/Constants.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardState();
}

class _DashboardState extends State<DashboardPage> {
  int _selectedIndex = 0;
  User? user;
  final GlobalKey<_DashboardStatsBarState> _statsBarKey = GlobalKey<_DashboardStatsBarState>();

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
  }

  void _refreshStats() {
    _statsBarKey.currentState?.fetchCounts();
  }

  signout() async {
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      drawer: _buildSideDrawer(),
      onDrawerChanged: (isOpened) {
        if (!isOpened) {
          _refreshStats();
        }
      },
      body: _buildHomeScreen(),
    );
  }

  Widget _buildSideDrawer() {
    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      backgroundColor: Colors.white,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [primary_color.withOpacity(0.05), Colors.white],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [primary_color, primary_color.withOpacity(0.8)],
                ),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 12),

                  // User Name (clickable)
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ProfilePage()),
                      );
                    },
                    child: Text(
                      user?.displayName ?? 'User',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ProfilePage()),
                      );
                    },
                    child: Text(
                      user?.email ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(
              icon: Icons.add_circle_outlined,
              title: 'Add Task',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddTaskPage()),
                );
              },
            ),
            _buildDrawerItem(
              icon: Icons.edit_note_rounded,
              title: 'Edit Tasks',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EditTaskPage()),
                );
              },
            ),
            _buildDrawerItem(
              icon: Icons.timelapse_rounded,
              title: 'Ongoing Tasks',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const OngoingTasksPage()),
                );
              },
            ),
            _buildDrawerItem(
              icon: Icons.done_outline_rounded,
              title: 'Completed Tasks',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CompletedTasksPage()),
                );
              },
            ),
            _buildDrawerItem(
              icon: Icons.history_rounded,
              title: 'History',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TaskHistoryPage()),
                );
              },
            ),
            _buildDrawerItem(
              icon: Icons.settings_rounded,
              title: 'Settings',
              onTap: () {
                // Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsPage()),
                );
              },
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Divider(color: Colors.grey, thickness: 0.5),
            ),
            _buildDrawerItem(
              icon: Icons.logout_rounded,
              title: 'Logout',
              isDestructive: true,
              onTap: () async {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text("Confirm Logout"),
                      content: const Text("Are you sure you want to logout?"),
                      actions: [
                        TextButton(
                          child: const Text("Cancel"),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: const Text("Yes"),
                          onPressed: () {
                            Navigator.of(context).pop();
                            signout();
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (context) => const LoginPage(),
                              ),
                              (Route<dynamic> route) => false,
                            );
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isDestructive ? Colors.red.withOpacity(0.1) : Colors.transparent,
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive ? Colors.red : primary_color,
          size: 22,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: isDestructive ? Colors.red : Colors.black87,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        minVerticalPadding: 0,
        dense: true,
      ),
    );
  }

  /// Home screen UI
  Widget _buildHomeScreen() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [primary_color.withOpacity(0.05), Colors.white],
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(24, 48, 24, 32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [primary_color, primary_color.withOpacity(0.8)],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
                boxShadow: [
                  BoxShadow(
                    color: primary_color.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Builder(
                        builder:
                            (context) => Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.menu,
                                  color: Colors.white,
                                  size: 28,
                                ),
                                onPressed: () {
                                  Scaffold.of(context).openDrawer();
                                },
                              ),
                            ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'NoteNest',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hello, ${user?.displayName ?? 'User'}! 👋',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Wishing you a productive day!',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _DashboardStatsBar(key: _statsBarKey),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: GestureDetector(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TodayTaskPage()),
                  );
                  _refreshStats();
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primary_color, primary_color.withOpacity(0.8)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: primary_color.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.remove_red_eye_rounded, color: Colors.white, size: 24),
                      SizedBox(width: 10),
                      Text(
                        "Today's Task",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: GestureDetector(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddTaskPage()),
                  );
                  _refreshStats();
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primary_color, primary_color.withOpacity(0.8)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: primary_color.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.add, color: Colors.white, size: 24),
                      SizedBox(width: 10),
                      Text(
                        'Add Task',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(children: [const SizedBox(height: 20)]),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class _DashboardStatsBar extends StatefulWidget {
  const _DashboardStatsBar({Key? key}) : super(key: key);
  @override
  State<_DashboardStatsBar> createState() => _DashboardStatsBarState();
}

class _DashboardStatsBarState extends State<_DashboardStatsBar> {
  int ongoingCount = 0;
  int completedCount = 0;
  int totalToday = 0;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchCounts();
  }

  Future<void> fetchCounts() async {
    final user = FirebaseAuth.instance.currentUser;
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);

    // Fetch all TaskCompleted docs for today
    final completedSnapshot = await FirebaseFirestore.instance
        .collection('TaskCompleted')
        .where('Id', isEqualTo: user?.uid)
        .get();
    final completedTodayDocs = completedSnapshot.docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      if (!data.containsKey('Date') || !data.containsKey('TaskId')) return false;
      final completedDate = (data['Date'] as Timestamp).toDate();
      return completedDate.year == today.year &&
          completedDate.month == today.month &&
          completedDate.day == today.day;
    }).toList();

    // Fetch all tasks
    final tasksSnapshot = await FirebaseFirestore.instance
        .collection('Tasks')
        .where('Id', isEqualTo: user?.uid)
        .get();
    final allTasks = tasksSnapshot.docs;
    final taskMap = {for (var t in allTasks) t.id: t};

    // Ongoing tasks logic
    var ongoingTasks = allTasks.where((task) {
      final data = task.data() as Map<String, dynamic>;
      final status = data['Status'];
      final startTimestamp = data['StartDate'] as Timestamp?;
      final endTimestamp = data['EndDate'] as Timestamp?;
      final taskId = task.id;

      // Check if this task is completed today via TaskCompleted collection
      final isTaskCompletedToday = completedTodayDocs.any(
            (doc) => (doc.data() as Map<String, dynamic>)['TaskId'] == taskId,
      );

      // One-time task: ongoing if Status == false
      if (endTimestamp == null) {
        return status == false;
      }

      // Daily task: ongoing if today's date is between StartDate and EndDate
      if (startTimestamp != null && endTimestamp != null) {
        final startDateOnly = DateTime(
          startTimestamp.toDate().year,
          startTimestamp.toDate().month,
          startTimestamp.toDate().day,
        );
        final endDateOnly = DateTime(
          endTimestamp.toDate().year,
          endTimestamp.toDate().month,
          endTimestamp.toDate().day,
        );
        final isInRange =
            (todayOnly.isAtSameMomentAs(startDateOnly) || todayOnly.isAfter(startDateOnly)) &&
                (todayOnly.isAtSameMomentAs(endDateOnly) || todayOnly.isBefore(endDateOnly.add(const Duration(days: 1))));
        return isInRange && !isTaskCompletedToday;
      }
      return false;
    }).toList();

    // Completed tasks logic: from TaskCompleted collection
    int completedTasksCount = 0;
    for (final doc in completedTodayDocs) {
      final data = doc.data() as Map<String, dynamic>;
      final taskId = data['TaskId'];
      final task = taskMap[taskId];
      if (task == null) continue;
      final tdata = task.data() as Map<String, dynamic>;
      final endDate = tdata['EndDate'];
      final startTimestamp = tdata['StartDate'] as Timestamp?;
      final endTimestamp = tdata['EndDate'] as Timestamp?;
      if (endDate == null) {
        completedTasksCount++;
        continue;
      }
      if (startTimestamp != null && endTimestamp != null) {
        final startDate = DateTime(
          startTimestamp.toDate().year,
          startTimestamp.toDate().month,
          startTimestamp.toDate().day,
        );
        final endDateOnly = DateTime(
          endTimestamp.toDate().year,
          endTimestamp.toDate().month,
          endTimestamp.toDate().day,
        );
        final isTodayInRange =
            (todayOnly.isAtSameMomentAs(startDate) || todayOnly.isAfter(startDate)) &&
                (todayOnly.isAtSameMomentAs(endDateOnly) || todayOnly.isBefore(endDateOnly.add(const Duration(days: 1))));
        if (isTodayInRange) {
          completedTasksCount++;
        }
      }
    }

    // ✅ NEW: count one-time tasks where Status == true and CompletedOn is today
    final completedOneTimeTasksToday = allTasks.where((task) {
      final data = task.data() as Map<String, dynamic>;
      final endDate = data['EndDate'];
      final status = data['Status'] == true;
      final completedOn = data['CompletedOn'] as Timestamp?;
      if (endDate != null) return false; // only one-time tasks
      if (!status || completedOn == null) return false;
      final compDate = completedOn.toDate();
      return compDate.year == today.year &&
          compDate.month == today.month &&
          compDate.day == today.day;
    }).length;

    // Add it to completed count
    completedTasksCount += completedOneTimeTasksToday;

    // Final setState
    setState(() {
      ongoingCount = ongoingTasks.length;
      completedCount = completedTasksCount;
      totalToday = ongoingTasks.length + completedTasksCount;
      loading = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    final percent = totalToday == 0 ? 0.0 : completedCount / totalToday;
    final percentText = (percent * 100).toStringAsFixed(0);
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const OngoingTasksPage()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        '$ongoingCount',
                        style: TextStyle(
                          color: primary_color,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Ongoing',
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CompletedTasksPage(),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        '$completedCount',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Completed',
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Today\'s Progress',
                    style: TextStyle(
                      color: primary_color,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '$percentText%',
                    style: TextStyle(
                      color: Colors.green[700],
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Stack(
                children: [
                  Container(
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: percent,
                    child: Container(
                      height: 16,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [primary_color, Colors.green[400]!],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                '$completedCount of $totalToday tasks completed today',
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
