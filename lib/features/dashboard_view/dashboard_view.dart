import 'package:cric_live/utils/import_exports.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the initial tab index from arguments (defaults to 0 for Live tab)
    final arguments = Get.arguments as Map<String, dynamic>?;
    final initialIndex = arguments?['initialTab'] ?? 0;

    return SafeArea(
      top: false,
      child: DefaultTabController(
        length: 2,
        initialIndex: initialIndex,
        child: Scaffold(
          body: NestedScrollView(
            headerSliverBuilder:
                (context, innerBoxIsScrolled) => [
                  SliverAppBar(
                    elevation: 0,
                    backgroundColor: Colors.deepOrange.shade600,
                    foregroundColor: Colors.white,
                    expandedHeight: 100,
                    floating: false,
                    pinned: true,
                    snap: false,
                    stretch: false,
                    flexibleSpace: FlexibleSpaceBar(
                      collapseMode: CollapseMode.parallax,
                      stretchModes: const [
                        StretchMode.zoomBackground,
                        StretchMode.blurBackground,
                      ],
                      title: _buildEnhancedTitle(),
                      titlePadding: const EdgeInsets.only(
                        left: 20,
                        bottom: 40,
                        right: 20,
                        top: 10,
                      ),
                      centerTitle: false,
                      background: _buildEnhancedBackground(),
                    ),
                    actions: _buildEnhancedActions(),
                    bottom: _buildEnhancedTabBar(),
                  ),
                ],
            body: const TabBarView(
              children: [DisplayLiveMatchView(), HistoryView()],
            ),
          ),
          // Removed drawer completely
        ),
      ),
    );
  }

  void _handleProfileMenuSelection(BuildContext context, String value) {
    switch (value) {
      case 'help':
        // Navigate to feedback page
        Get.toNamed(NAV_FEEDBACK);
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

  // Enhanced Background with Modern Design
  Widget _buildEnhancedBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: const [0.0, 0.3, 0.7, 1.0],
          colors: [
            Colors.deepOrange.shade300,
            Colors.deepOrange.shade500,
            Colors.deepOrange.shade700,
            Colors.deepOrange.shade900,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Animated Background Pattern
          Positioned.fill(
            child: CustomPaint(painter: _CricketPatternPainter()),
          ),
          // Main Cricket Icon with Animation
          Positioned(
            right: -25,
            top: -25,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: 0.5 + (0.5 * value),
                  child: Transform.rotate(
                    angle: value * 0.2,
                    child: Icon(
                      Icons.sports_cricket,
                      size: 110,
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                  ),
                );
              },
            ),
          ),
          // Secondary Sports Icons
          Positioned(
            left: -15,
            bottom: -15,
            child: Transform.rotate(
              angle: -0.1,
              child: Icon(
                Icons.sports_baseball,
                size: 70,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          // Floating Particles with Enhanced Animation
          ..._buildFloatingParticles(),
          // Glassmorphism Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.05),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.1),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Compact and Clean Title
  Widget _buildEnhancedTitle() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate how expanded the AppBar is
        final isExpanded = constraints.maxHeight > kToolbarHeight + 20;

        return Container(
          alignment: Alignment.centerLeft,
          child: Column(
            mainAxisSize: MainAxisSize.min,

            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isExpanded) ...[
                    Icon(Icons.sports_cricket, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    'CricLive',
                    style: GoogleFonts.poppins(
                      fontSize: isExpanded ? 22 : 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              // Subtitle - only when expanded
              if (isExpanded)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    'Your Cricket Companion',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.9),
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  // Enhanced Actions with Better Design
  List<Widget> _buildEnhancedActions() {
    return [
      // Search Button with Enhanced Design
      _buildActionButton(
        icon: Icons.search_rounded,
        onTap: () => Get.toNamed(NAV_SEARCH),
        tooltip: 'Search',
      ),
      const SizedBox(width: 8),
      // Create Menu with Enhanced Design
      _buildCreateMenuButton(),
      const SizedBox(width: 8),
      // Profile Menu with Enhanced Design
      _buildProfileMenuButton(),
      const SizedBox(width: 16),
    ];
  }

  // Enhanced Action Button
  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 0.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
        ),
      ),
    );
  }

  // Enhanced Create Menu Button
  Widget _buildCreateMenuButton() {
    return PopupMenuButton<String>(
      tooltip: 'Create',
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 12,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
      ),
      itemBuilder:
          (context) => [
            _buildEnhancedPopupItem(
              icon: Icons.emoji_events_rounded,
              title: 'Create Tournament',
              subtitle: 'Start a new tournament',
              value: 'tournament',
            ),
            _buildEnhancedPopupItem(
              icon: Icons.sports_cricket_rounded,
              title: 'Create Match',
              subtitle: 'Start a new match',
              value: 'match',
            ),
          ],
      onSelected: (value) {
        if (value == 'tournament') {
          Get.toNamed(NAV_CREATE_TOURNAMENT);
        } else if (value == 'match') {
          Get.toNamed(NAV_CREATE_MATCH);
        }
      },
    );
  }

  // Enhanced Profile Menu Button
  Widget _buildProfileMenuButton() {
    return Builder(
      builder: (BuildContext context) {
        return PopupMenuButton<String>(
          tooltip: 'Profile',
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 12,
          offset: const Offset(0, 50),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 0.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.account_circle_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          itemBuilder:
              (popupContext) => [
                // User Info Header
                PopupMenuItem(enabled: false, child: _buildUserInfoHeader()),
                _buildEnhancedPopupItem(
                  icon: Icons.help_outline_rounded,
                  title: 'Help & Support',
                  subtitle: 'Get help and support',
                  value: 'help',
                ),
                _buildEnhancedPopupItem(
                  icon: Icons.logout_rounded,
                  title: 'Logout',
                  subtitle: 'Sign out of your account',
                  value: 'logout',
                  isDestructive: true,
                ),
              ],
          onSelected: (value) {
            _handleProfileMenuSelection(context, value);
          },
        );
      },
    );
  }

  // Enhanced Tab Bar
  PreferredSize _buildEnhancedTabBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(50),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.deepOrange.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TabBar(
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              colors: [Colors.deepOrange.shade400, Colors.deepOrange.shade600],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.deepOrange.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey.shade600,
          labelStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            letterSpacing: 0.3,
          ),
          unselectedLabelStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          splashFactory: NoSplash.splashFactory,
          tabs: [
            _buildEnhancedTab(
              icon: Icons.radio_button_checked_rounded,
              label: 'Live',
              isLive: true,
            ),
            _buildEnhancedTab(icon: Icons.history_rounded, label: 'History'),
          ],
        ),
      ),
    );
  }

  // Enhanced Tab Design
  Widget _buildEnhancedTab({
    required IconData icon,
    required String label,
    bool isLive = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              Icon(icon, size: 16),
              if (isLive)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withValues(alpha: 0.5),
                          blurRadius: 3,
                          spreadRadius: 0.5,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
    );
  }

  // Helper Methods
  List<Widget> _buildFloatingParticles() {
    return List.generate(6, (index) {
      final positions = [
        {'right': 120.0, 'top': 80.0, 'size': 10.0},
        {'left': 100.0, 'top': 60.0, 'size': 8.0},
        {'right': 80.0, 'bottom': 50.0, 'size': 6.0},
        {'left': 60.0, 'bottom': 80.0, 'size': 12.0},
        {'right': 180.0, 'top': 120.0, 'size': 5.0},
        {'left': 140.0, 'bottom': 40.0, 'size': 9.0},
      ];

      final pos = positions[index];

      return AnimatedPositioned(
        duration: Duration(milliseconds: 2000 + (index * 200)),
        curve: Curves.easeInOutSine,
        right: pos['right'],
        left: pos['left'],
        top: pos['top'],
        bottom: pos['bottom'],
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 1500 + (index * 100)),
          builder: (context, value, child) {
            return Transform.scale(
              scale: 0.5 + (0.5 * value),
              child: Container(
                width: pos['size']!,
                height: pos['size']!,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(
                    alpha: 0.2 + (0.3 * (1 - index / 6)),
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.1),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    });
  }

  PopupMenuItem<String> _buildEnhancedPopupItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? Colors.red.shade600 : Colors.deepOrange;

    return PopupMenuItem(
      value: value,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: isDestructive ? Colors.red.shade600 : null,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.deepOrange.shade400,
                      Colors.deepOrange.shade600,
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.deepOrange.shade100,
                  child: Icon(
                    Icons.person_rounded,
                    color: Colors.deepOrange.shade600,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Obx(() {
                  try {
                    final controller = Get.find<DashboardController>();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back!',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          controller.email.value.isNotEmpty
                              ? controller.email.value.split('@')[0]
                              : 'Cricket User',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.deepOrange.shade700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    );
                  } catch (e) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back!',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          'Cricket User',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.deepOrange.shade700,
                          ),
                        ),
                      ],
                    );
                  }
                }),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: Colors.grey.shade200, thickness: 1, height: 1),
        ],
      ),
    );
  }
}

// Custom Painter for Background Pattern
class _CricketPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white.withValues(alpha: 0.03)
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke;

    // Draw cricket field lines pattern
    final path = Path();

    // Draw some curved lines representing cricket field
    for (int i = 0; i < 3; i++) {
      final y = size.height * (0.3 + i * 0.2);
      path.moveTo(0, y);
      path.quadraticBezierTo(size.width * 0.5, y - 20, size.width, y);
    }

    canvas.drawPath(path, paint);

    // Draw some dots pattern
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 5; j++) {
        if ((i + j) % 3 == 0) {
          canvas.drawCircle(
            Offset((size.width / 8) * i, (size.height / 5) * j),
            1.5,
            Paint()
              ..color = Colors.white.withValues(alpha: 0.05)
              ..style = PaintingStyle.fill,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
