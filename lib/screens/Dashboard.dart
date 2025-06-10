import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:NoteNest/utils/Constants.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5FA), // A light grey-blue background color from the image
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                // Top Header Section
                Container(
                  height: 250, // Height based on image
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF64B5F6), Color(0xFF42A5F5)], // Blue gradient from image
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 60, left: 25, right: 25, bottom: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const CircleAvatar(
                              radius: 28,
                              backgroundColor: Colors.white,
                              backgroundImage: AssetImage('assets/images/profile_placeholder.jpg'), // Placeholder image
                            ),
                            IconButton(
                              icon: const Icon(Icons.settings, color: Colors.white, size: 28),
                              onPressed: () {
                                // Navigate to settings
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Monday, 03 January',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.8),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          'Hello Joshua,',
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Main Content Area (Agenda, Productivity, Collaboration)
                Transform.translate(
                  offset: const Offset(0, -50), // Overlap with header
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFF2F5FA), // Match overall background
                      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Your Agenda Section
                          Text(
                            'Your Agenda',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: head_color,
                            ),
                          ),
                          const SizedBox(height: 15),
                          SizedBox(
                            height: 200, // Fixed height for grid
                            child: GridView.builder(
                              physics: const NeverScrollableScrollPhysics(), // Disable scrolling
                              itemCount: 3,
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 15,
                                mainAxisSpacing: 15,
                                childAspectRatio: 1.0, // Adjust as needed to fit the content
                              ),
                              itemBuilder: (context, index) {
                                if (index == 0) {
                                  return _buildAgendaCard(
                                      context, '2', 'Tasks Due', const Color(0xFF673AB7)); // Deep purple
                                } else if (index == 1) {
                                  return _buildAgendaCard(
                                      context, '2', 'Due Tomorrow', const Color(0xFF9C27B0)); // Another shade of purple
                                } else {
                                  return _buildAgendaCard(
                                      context, '16', 'Tasks Due in Seven Days', const Color(0xFF2196F3)); // Blue
                                }
                              },
                            ),
                          ),
                          const SizedBox(height: 30),

                          // Productivity Score Section
                          Text(
                            'Productivity Score',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: head_color,
                            ),
                          ),
                          const SizedBox(height: 15),
                          _buildProductivityRow('Task in the last 30 days:', '49', Colors.orange),
                          const SizedBox(height: 10),
                          _buildProductivityRow('Task in the last 30 days:', '7', Colors.orange),
                          const SizedBox(height: 10),
                          _buildProductivityRow('Task completion rate:', '14 % ', Colors.orange),
                          const SizedBox(height: 30),

                          // Task Collaboration Section
                          Text(
                            'Task Collaboration',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: head_color,
                            ),
                          ),
                          const SizedBox(height: 15),
                          _buildProductivityRow('No. of Tasks Assigned to you:', '3', primary_color),
                          const SizedBox(height: 100), // Space for FAB
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Bottom Navigation Bar with FAB
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 80, // Height of the bottom nav bar
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(Icons.home, 'Home', 0),
                  _buildNavItem(Icons.task, 'Tasks', 1),
                  const SizedBox(width: 60), // Space for FAB
                  _buildNavItem(Icons.search, 'Search', 2),
                  _buildNavItem(Icons.settings, 'Settings', 3),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: MediaQuery.of(context).size.width / 2 - 35, // Center the FAB
            child: FloatingActionButton(
              onPressed: () {
                // Navigate to add task screen
              },
              backgroundColor: primary_color,
              elevation: 5,
              child: const Icon(Icons.add, color: Colors.white, size: 30),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgendaCard(BuildContext context, String value, String title, Color numberColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: numberColor.withOpacity(0.3), // Simulating gradient border
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Icon(Icons.arrow_forward_ios, size: 18, color: Colors.green[400]),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 48,
                    fontWeight: FontWeight.w600,
                    color: numberColor,
                  ),
                ),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: text_color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductivityRow(String label, String value, Color valueColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: text_color,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: valueColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    return GestureDetector(
      onTap: () {
        // Handle navigation for each item
        // For now, these are just visual placeholders.
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.grey[700], size: 28),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

}
