import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'models/team_selection_model.dart';
import 'widgets/team_card.dart';

enum TeamSortBy { name, winRate, matches, recent }

enum TeamViewMode { grid, list }

class TeamSelectionWidget extends StatefulWidget {
  final List<TeamSelectionModel> teams;
  final Function(TeamSelectionModel)? onTeamSelected;
  final Function(TeamSelectionModel)? onViewPlayers;
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
    Key? key,
    required this.teams,
    this.onTeamSelected,
    this.onViewPlayers,
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
  }) : super(key: key);

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
  TeamViewMode _viewMode = TeamViewMode.list;
  bool _showActiveOnly = false;
  String _selectedTournament = 'All';
  List<String> _availableTournaments = ['All'];

  late AnimationController _searchAnimationController;
  late AnimationController _filterAnimationController;
  late Animation<double> _searchAnimation;
  late Animation<double> _filterAnimation;

  @override
  void initState() {
    super.initState();
    _viewMode = widget.defaultViewMode;
    _selectedTeams = List.from(widget.selectedTeams ?? []);
    _initializeData();
    _setupAnimations();
  }

  void _setupAnimations() {
    _searchAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _filterAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _searchAnimation = CurvedAnimation(
      parent: _searchAnimationController,
      curve: Curves.easeInOut,
    );
    _filterAnimation = CurvedAnimation(
      parent: _filterAnimationController,
      curve: Curves.easeInOut,
    );

    _searchAnimationController.forward();
  }

  void _initializeData() {
    _filteredTeams = List.from(widget.teams);
    _extractTournaments();
    _applyFilters();
  }

  void _extractTournaments() {
    final tournaments =
        widget.teams
            .where((team) => team.tournamentName != null)
            .map((team) => team.tournamentName!)
            .toSet()
            .toList();
    _availableTournaments = ['All', ...tournaments];
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
    _filterAnimationController.dispose();
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

            // Active status filter
            if (_showActiveOnly && team.isActive != true) return false;

            // Tournament filter
            if (_selectedTournament != 'All' &&
                team.tournamentName != _selectedTournament) {
              return false;
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
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(theme),
          if (widget.showFilters) _buildFilterSection(theme),
          _buildTeamList(theme),
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

  Widget _buildSliverAppBar(ThemeData theme) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      backgroundColor: theme.colorScheme.surface,
      foregroundColor: theme.colorScheme.onSurface,
      elevation: 0,
      title: Text(
        widget.title,
        style: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primaryContainer.withValues(alpha: 0.1),
                theme.colorScheme.secondaryContainer.withValues(alpha: 0.1),
              ],
            ),
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: _buildSearchBar(theme),
        ),
      ),
      actions: [
        _buildViewModeToggle(theme),
        if (widget.showFilters) _buildFilterToggle(theme),
      ],
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
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
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

  Widget _buildViewModeToggle(ThemeData theme) {
    return IconButton(
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: Icon(
          _viewMode == TeamViewMode.grid
              ? Icons.view_list_rounded
              : Icons.grid_view_rounded,
          key: ValueKey(_viewMode),
        ),
      ),
      onPressed: () {
        setState(() {
          _viewMode =
              _viewMode == TeamViewMode.grid
                  ? TeamViewMode.list
                  : TeamViewMode.grid;
        });
      },
      tooltip: _viewMode == TeamViewMode.grid ? 'List View' : 'Grid View',
    );
  }

  Widget _buildFilterToggle(ThemeData theme) {
    return IconButton(
      icon: AnimatedRotation(
        duration: Duration(milliseconds: 1000),
        turns: _filterAnimation.value * 0.5,
        child: Icon(Icons.tune_rounded),
      ),
      onPressed: () {
        if (_filterAnimationController.isCompleted) {
          _filterAnimationController.reverse();
        } else {
          _filterAnimationController.forward();
        }
      },

      tooltip: 'Filters',
    );
  }

  Widget _buildFilterSection(ThemeData theme) {
    return SliverToBoxAdapter(
      child: AnimatedBuilder(
        animation: _filterAnimation,
        builder: (context, child) {
          return ClipRect(
            child: Align(
              alignment: Alignment.topCenter,
              heightFactor: _filterAnimation.value,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                  border: Border(
                    bottom: BorderSide(
                      color: theme.colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildSortFilter(theme)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildTournamentFilter(theme)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildActiveFilter(theme),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSortFilter(ThemeData theme) {
    return DropdownButtonFormField<TeamSortBy>(
      value: _sortBy,
      decoration: InputDecoration(
        labelText: 'Sort by',
        prefixIcon: Icon(Icons.sort_rounded),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: [
        DropdownMenuItem(value: TeamSortBy.name, child: Text('Name')),
        DropdownMenuItem(value: TeamSortBy.winRate, child: Text('Win Rate')),
        DropdownMenuItem(value: TeamSortBy.matches, child: Text('Matches')),
        DropdownMenuItem(value: TeamSortBy.recent, child: Text('Recent')),
      ],
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _sortBy = value;
            _applySorting();
          });
        }
      },
    );
  }

  Widget _buildTournamentFilter(ThemeData theme) {
    return DropdownButtonFormField<String>(
      value: _selectedTournament,
      decoration: InputDecoration(
        labelText: 'Tournament',
        prefixIcon: Icon(Icons.emoji_events_rounded),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items:
          _availableTournaments
              .map(
                (tournament) => DropdownMenuItem(
                  value: tournament,
                  child: Text(tournament),
                ),
              )
              .toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedTournament = value;
            _applyFilters();
          });
        }
      },
    );
  }

  Widget _buildActiveFilter(ThemeData theme) {
    return SwitchListTile(
      title: Text('Show active teams only'),
      subtitle: Text('Filter out inactive teams'),
      value: _showActiveOnly,
      onChanged: (value) {
        setState(() {
          _showActiveOnly = value;
          _applyFilters();
        });
      },
      secondary: Icon(Icons.toggle_on_rounded),
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

    if (_viewMode == TeamViewMode.grid) {
      return SliverPadding(
        padding: widget.padding ?? const EdgeInsets.all(16),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.8,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) => _buildTeamCard(_filteredTeams[index]),
            childCount: _filteredTeams.length,
          ),
        ),
      );
    } else {
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
        showStats: widget.showStats,
        showActions: widget.showActions,
        margin:
            _viewMode == TeamViewMode.grid
                ? EdgeInsets.zero
                : const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  Widget _buildDefaultLoading(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text('Loading teams...', style: theme.textTheme.bodyLarge),
        ],
      ),
    );
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
