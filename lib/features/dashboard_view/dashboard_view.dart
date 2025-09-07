import 'package:cric_live/utils/import_exports.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder:
              (context, innerBoxIsScrolled) => [
                SliverAppBar(
                  elevation: 0,
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  expandedHeight: 120, // Reduced from 140
                  floating: false,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    // THE CHANGE IS IN THIS WIDGET BUILDER
                    title: _buildAmazingTitle(),
                    titlePadding: const EdgeInsets.only(
                      left:
                          16, // Restored normal padding since drawer moved to right
                      bottom: 60,
                      right: 16,
                    ),
                    centerTitle: false,
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.deepOrange.shade400,
                            Colors.deepOrange.shade600,
                            Colors.deepOrange.shade800,
                          ],
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Background cricket elements
                          Positioned(
                            right: -30,
                            top: -30,
                            child: Icon(
                              Icons.sports_cricket,
                              size: 120,
                              // Corrected from withValues to withOpacity
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                          Positioned(
                            left: -20,
                            bottom: -20,
                            child: Icon(
                              Icons.sports_baseball,
                              size: 80,
                              color: Colors.white.withOpacity(0.05),
                            ),
                          ),
                          // Floating particles effect
                          Positioned(
                            right: 100,
                            top: 60,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          Positioned(
                            left: 80,
                            top: 40,
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          Positioned(
                            right: 50,
                            bottom: 30,
                            child: Container(
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.4),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.search, color: Colors.white),
                        onPressed: () => Get.toNamed(NAV_SEARCH),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: PopupMenuButton<String>(
                        icon: const Icon(Icons.add, color: Colors.white),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        itemBuilder:
                            (context) => [
                              PopupMenuItem(
                                value: "tournament",
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.emoji_events,
                                      color: Colors.deepOrange,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      "Create Tournament",
                                      style: GoogleFonts.nunito(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: "match",
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.sports_cricket,
                                      color: Colors.deepOrange,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      "Create Match",
                                      style: GoogleFonts.nunito(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                        onSelected: (value) {
                          if (value == "tournament") {
                            Get.toNamed(NAV_CREATE_TOURNAMENT);
                          } else if (value == "match") {
                            Get.toNamed(NAV_CREATE_MATCH);
                          }
                        },
                      ),
                    ),
                    // Profile Action Button
                    Container(
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: PopupMenuButton<String>(
                        icon: const Icon(
                          Icons.account_circle,
                          color: Colors.white,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        offset: const Offset(0, 45),
                        itemBuilder:
                            (context) => [
                              // User Email Header
                              PopupMenuItem(
                                enabled: false,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 20,
                                          backgroundColor:
                                              Colors.deepOrange.shade100,
                                          child: Icon(
                                            Icons.person,
                                            color: Colors.deepOrange.shade600,
                                            size: 24,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Obx(() {
                                            try {
                                              final controller =
                                                  Get.find<
                                                    DashboardController
                                                  >();
                                              return Text(
                                                controller
                                                        .email
                                                        .value
                                                        .isNotEmpty
                                                    ? controller.email.value
                                                    : 'cricket@user.com',
                                                style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14,
                                                  color:
                                                      Colors
                                                          .deepOrange
                                                          .shade700,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              );
                                            } catch (e) {
                                              return Text(
                                                'cricket@user.com',
                                                style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14,
                                                  color:
                                                      Colors
                                                          .deepOrange
                                                          .shade700,
                                                ),
                                              );
                                            }
                                          }),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Divider(
                                      color: Colors.grey.shade300,
                                      thickness: 1,
                                    ),
                                  ],
                                ),
                              ),
                              // Settings Option
                              PopupMenuItem(
                                value: "settings",
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.settings_outlined,
                                      color: Colors.grey.shade600,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      "Settings",
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Help & Support Option
                              PopupMenuItem(
                                value: "help",
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.help_outline,
                                      color: Colors.grey.shade600,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      "Help & Support",
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Logout Option
                              PopupMenuItem(
                                value: "logout",
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.logout,
                                      color: Colors.red.shade600,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      "Logout",
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: Colors.red.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                        onSelected: (value) {
                          _handleProfileMenuSelection(context, value);
                        },
                      ),
                    ),
                  ],
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(50),
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TabBar(
                        indicator: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          color: Colors.deepOrange,
                        ),
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.grey.shade600,
                        labelStyle: GoogleFonts.nunito(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                        unselectedLabelStyle: GoogleFonts.nunito(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        dividerColor: Colors.transparent,
                        splashFactory: NoSplash.splashFactory,
                        tabs: const [
                          Tab(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.radio_button_checked, size: 18),
                                SizedBox(width: 8),
                                Text("Live"),
                              ],
                            ),
                          ),
                          Tab(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.history, size: 18),
                                SizedBox(width: 8),
                                Text("History"),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
          body: const TabBarView(
            children: [DisplayLiveMatchView(), HistoryView()],
          ),
        ),
        // Removed drawer completely
      ),
    );
  }

  void _handleProfileMenuSelection(BuildContext context, String value) {
    switch (value) {
      case 'settings':
        // Add settings navigation when ready
        Get.snackbar(
          'Settings',
          'Settings feature coming soon!',
          backgroundColor: Colors.deepOrange,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        break;
      case 'help':
        // Add help & support navigation when ready
        Get.snackbar(
          'Help & Support',
          'Help & Support feature coming soon!',
          backgroundColor: Colors.blue,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        break;
      case 'logout':
        _showLogoutDialog(context);
        break;
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.logout, color: Colors.red.shade600, size: 24),
              const SizedBox(width: 12),
              Text(
                'Logout',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to logout from CricLive?',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Get.offAllNamed(NAV_LOGIN);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Logout',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // THIS IS THE ONLY PART THAT WAS CHANGED
  Widget _buildAmazingTitle() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Check if the title is in its collapsed state.
        bool isCollapsed = constraints.maxHeight < 80;

        // By removing the complex Row and Expanded widgets, we allow the
        // FlexibleSpaceBar to handle the alignment correctly. It will
        // naturally place this widget to the left of the `actions`.
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Using a simple Text widget for the main title.
            Text(
              'CricLive',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
              maxLines: 1,
            ),
            // Subtitle is only visible when expanded.
            if (!isCollapsed)
              Text(
                'Live Cricket Experience',
                style: GoogleFonts.poppins(
                  // Corrected font size to be visible and method for opacity
                  fontSize: 7,
                  fontWeight: FontWeight.w600,

                  color: Colors.white.withOpacity(0.6),
                ),
              ),
          ],
        );
      },
    );
  }
}
