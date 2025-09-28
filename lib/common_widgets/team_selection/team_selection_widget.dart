import 'package:cric_live/utils/import_exports.dart';

enum TeamSortBy { name, winRate, matches, recent }

enum TeamViewMode { grid, list }

class TeamSelectionWidget extends StatefulWidget {
  final List<TeamSelectionModel> teams;
  final Function(TeamSelectionModel)? onTeamSelected;
  final Function(TeamSelectionModel)? onViewPlayers;
  final Function(TeamSelectionModel)? onDeleteTeam;
  final String title;
  final String searchHint;
  final bool allowMultipleSelection;
  final List<TeamSelectionModel>? selectedTeams;
  final bool showStats;
  final bool showActions;
  final bool showFilters;
  final bool showCreateButton;
  final VoidCallback? onCreateTeam;
  final Widget? emptyState;
  final Widget? loadingWidget;
  final bool isLoading;
  final EdgeInsets? padding;
  final TeamViewMode defaultViewMode;

  const TeamSelectionWidget({
    super.key,
    required this.teams,
    this.onTeamSelected,
    this.onViewPlayers,
    this.onDeleteTeam,
    this.title = 'Select Team',
    this.searchHint = 'Search teams...',
    this.allowMultipleSelection = false,
    this.selectedTeams,
    this.showStats = true,
    this.showActions = true,
    this.showFilters = true,
    this.showCreateButton = true,
    this.onCreateTeam,
    this.emptyState,
    this.loadingWidget,
    this.isLoading = false,
    this.padding,
    this.defaultViewMode = TeamViewMode.list,
  });

  @override
  State<TeamSelectionWidget> createState() => _TeamSelectionWidgetState();
}

class _TeamSelectionWidgetState extends State<TeamSelectionWidget>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  List<TeamSelectionModel> _filteredTeams = [];
  List<TeamSelectionModel> _selectedTeams = [];
  TeamSortBy _sortBy = TeamSortBy.name;

  late AnimationController _searchAnimationController;
  late Animation<double> _searchAnimation;
  // Removed _filterAnimation since we're removing filters

  @override
  void initState() {
    super.initState();
    _selectedTeams = List.from(widget.selectedTeams ?? []);
    _initializeData();
    _setupAnimations();
  }

  void _setupAnimations() {
    _searchAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    // Removed filter animation controller since we're removing filters

    _searchAnimation = CurvedAnimation(
      parent: _searchAnimationController,
      curve: Curves.easeInOut,
    );
    // Removed filter animation

    _searchAnimationController.forward();
  }

  void _initializeData() {
    _filteredTeams = List.from(widget.teams);
    _applyFilters();
  }

  @override
  void didUpdateWidget(TeamSelectionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.teams != widget.teams) {
      _initializeData();
    }
    if (oldWidget.selectedTeams != widget.selectedTeams) {
      _selectedTeams = List.from(widget.selectedTeams ?? []);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _searchAnimationController.dispose();
    // Removed _filterAnimationController.dispose() since we removed the filter animation controller
    super.dispose();
  }

  void _applyFilters() {
    setState(() {
      _filteredTeams =
          widget.teams.where((team) {
            // Search filter
            final searchQuery = _searchController.text.toLowerCase();
            if (searchQuery.isNotEmpty) {
              final matchesSearch =
                  team.teamName.toLowerCase().contains(searchQuery) ||
                  (team.captain?.toLowerCase().contains(searchQuery) ??
                      false) ||
                  (team.coach?.toLowerCase().contains(searchQuery) ?? false) ||
                  (team.tournamentName?.toLowerCase().contains(searchQuery) ??
                      false);
              if (!matchesSearch) return false;
            }

            return true;
          }).toList();

      // Apply sorting
      _applySorting();
    });
  }

  void _applySorting() {
    _filteredTeams.sort((a, b) {
      switch (_sortBy) {
        case TeamSortBy.name:
          return a.teamName.compareTo(b.teamName);
        case TeamSortBy.winRate:
          return b.winPercentage.compareTo(a.winPercentage);
        case TeamSortBy.matches:
          return (b.totalMatches ?? 0).compareTo(a.totalMatches ?? 0);
        case TeamSortBy.recent:
          return (b.createdAt ?? DateTime(1970)).compareTo(
            a.createdAt ?? DateTime(1970),
          );
      }
    });
  }

  void _onTeamTap(TeamSelectionModel team) {
    if (widget.allowMultipleSelection) {
      setState(() {
        if (_selectedTeams.contains(team)) {
          _selectedTeams.remove(team);
        } else {
          _selectedTeams.add(team);
        }
      });
    } else {
      widget.onTeamSelected?.call(team);
    }
  }

  bool _isTeamSelected(TeamSelectionModel team) {
    return _selectedTeams.contains(team);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: CommonAppHeader(
        title: widget.title,
        subtitle: 'Select your cricket team',
        leadingIcon: Icons.group,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildSearchBar(theme),
          ),
          Expanded(
            child: CustomScrollView(
              slivers: [_buildTeamList(theme)],
            ),
          ),
        ],
      ),
      floatingActionButton:
          widget.showCreateButton ? _buildCreateButton(theme) : null,
      bottomNavigationBar:
          widget.allowMultipleSelection && _selectedTeams.isNotEmpty
              ? _buildSelectionActions(theme)
              : null,
    );
  }


  Widget _buildSearchBar(ThemeData theme) {
    return AnimatedBuilder(
      animation: _searchAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * _searchAnimation.value),
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.5,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              onChanged: (value) => _applyFilters(),
              decoration: InputDecoration(
                hintText: widget.searchHint,
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                suffixIcon:
                    _searchController.text.isNotEmpty
                        ? IconButton(
                          icon: Icon(Icons.clear_rounded),
                          onPressed: () {
                            _searchController.clear();
                            _applyFilters();
                          },
                        )
                        : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
        );
      },
    );
  }




  Widget _buildTeamList(ThemeData theme) {
    if (widget.isLoading) {
      return SliverToBoxAdapter(
        child: widget.loadingWidget ?? _buildDefaultLoading(theme),
      );
    }

    if (_filteredTeams.isEmpty) {
      return SliverToBoxAdapter(
        child: widget.emptyState ?? _buildDefaultEmptyState(theme),
      );
    }

    // Only support list view now, removed grid view
    return SliverPadding(
      padding: widget.padding ?? const EdgeInsets.symmetric(vertical: 8),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildTeamCard(_filteredTeams[index]),
          childCount: _filteredTeams.length,
        ),
      ),
    );
  }

  Widget _buildTeamCard(TeamSelectionModel team) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: TeamCard(
        team: team,
        isSelected: _isTeamSelected(team),
        onTap: () => _onTeamTap(team),
        onViewPlayers:
            widget.onViewPlayers != null
                ? () => widget.onViewPlayers!(team)
                : null,
        onDeleteTeam:
            widget.onDeleteTeam != null
                ? () => widget.onDeleteTeam!(team)
                : null,
        showStats: widget.showStats,
        showActions: widget.showActions,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      ),
    );
  }

  Widget _buildDefaultLoading(ThemeData theme) {
    return const CenterLoader(message: 'Loading teams...');
  }

  Widget _buildDefaultEmptyState(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text('No teams found', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateButton(ThemeData theme) {
    return FloatingActionButton.extended(
      onPressed: widget.onCreateTeam,
      icon: Icon(Icons.add_rounded),
      label: Text('Create Team'),
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: theme.colorScheme.onPrimary,
    );
  }

  Widget _buildSelectionActions(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: theme.colorScheme.outline.withOpacity(0.2)),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '${_selectedTeams.length} selected',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: () {
              setState(() {
                _selectedTeams.clear();
              });
            },
            child: Text('Clear'),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed:
                _selectedTeams.isNotEmpty
                    ? () {
                      // Return selected teams
                      Get.back(result: _selectedTeams);
                    }
                    : null,
            child: Text('Done'),
          ),
        ],
      ),
    );
  }
}
