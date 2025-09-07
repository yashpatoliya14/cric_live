import 'package:cric_live/utils/import_exports.dart';

class ChoosePlayerView extends StatelessWidget {
  const ChoosePlayerView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ChoosePlayerController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(APPBAR_CHOOSE_PLAYER),
        elevation: 2,
        shadowColor: Colors.grey.withOpacity(0.3),
        actions: [
          Obx(
            () =>
                controller.selectedPlayers.isNotEmpty
                    ? TextButton(
                      onPressed: controller.clearSelection,
                      child: Text(
                        CLEAR_SELECTION,
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                    : const SizedBox.shrink(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildHeader(controller, context),
          _buildSearchBar(controller, context),
          Expanded(
            child: Obx(
              () =>
                  controller.isLoading.value
                      ? _buildLoadingState()
                      : controller.filteredPlayers.isEmpty
                      ? _buildEmptyState(controller, context)
                      : _buildPlayersList(controller, context),
            ),
          ),
        ],
      ),
      floatingActionButton: Obx(
        () =>
            controller.selectedPlayers.length >= controller.limit
                ? FloatingActionButton.extended(
                  onPressed: () {
                    if (controller.selectedPlayers.length == controller.limit) {
                      Get.back(result: controller.selectedPlayers);
                    }
                  },
                  icon: const Icon(Icons.check),
                  label: Text(CONTINUE),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                )
                : const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildHeader(ChoosePlayerController controller, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Obx(
            () => Text(
              '$SELECTED_PLAYERS: ${controller.selectedPlayers.length}/${controller.limit}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color:
                    controller.selectedPlayers.length == controller.limit
                        ? Theme.of(context).primaryColor
                        : Colors.grey.shade700,
              ),
            ),
          ),
          Obx(
            () => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color:
                    controller.selectedPlayers.length == controller.limit
                        ? Theme.of(context).primaryColor.withOpacity(0.1)
                        : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color:
                      controller.selectedPlayers.length == controller.limit
                          ? Theme.of(context).primaryColor
                          : Colors.grey.shade300,
                ),
              ),
              child: Text(
                controller.selectedPlayers.length == controller.limit
                    ? 'Ready!'
                    : SELECT_PLAYERS_HINT,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color:
                      controller.selectedPlayers.length == controller.limit
                          ? Theme.of(context).primaryColor
                          : Colors.grey.shade600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(
    ChoosePlayerController controller,
    BuildContext context,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: controller.searchController,
        decoration: InputDecoration(
          hintText: SEARCH_PLAYERS,
          prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
          suffixIcon: Obx(
            () =>
                controller.searchQuery.value.isNotEmpty
                    ? IconButton(
                      icon: Icon(Icons.clear, color: Colors.grey.shade600),
                      onPressed: () {
                        controller.searchController.clear();
                      },
                    )
                    : const SizedBox.shrink(),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(context).primaryColor,
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const FullScreenLoader(message: 'Loading players...');
  }

  Widget _buildEmptyState(
    ChoosePlayerController controller,
    BuildContext context,
  ) {
    final bool isSearching = controller.searchQuery.value.isNotEmpty;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSearching ? Icons.search_off : Icons.people_outline,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              isSearching ? NO_PLAYERS_FOUND : NO_PLAYERS_AVAILABLE,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            if (isSearching) ...[
              const SizedBox(height: 8),
              Text(
                'Try searching with a different name',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPlayersList(
    ChoosePlayerController controller,
    BuildContext context,
  ) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: controller.filteredPlayers.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final player = controller.filteredPlayers[index];
        return Obx(() => _buildPlayerCard(player, controller, context));
      },
    );
  }

  Widget _buildPlayerCard(
    PlayerModel player,
    ChoosePlayerController controller,
    BuildContext context,
  ) {
    final bool isSelected = controller.isSelected(player);
    final bool canSelect =
        controller.selectedPlayers.length < controller.limit || isSelected;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color:
            isSelected
                ? Theme.of(context).primaryColor.withOpacity(0.05)
                : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isSelected
                  ? Theme.of(context).primaryColor
                  : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: canSelect ? () => controller.onChangedCheckBox(player) : null,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor:
                      isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.grey.shade300,
                  child: Icon(
                    Icons.person,
                    color: isSelected ? Colors.white : Colors.grey.shade600,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        player.playerName ?? 'Unknown Player',
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w600,
                          color:
                              isSelected
                                  ? Theme.of(context).primaryColor
                                  : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Player ID: ${player.teamPlayerId ?? 'N/A'}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child:
                      isSelected
                          ? Container(
                            key: const ValueKey('selected'),
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            ),
                          )
                          : Container(
                            key: const ValueKey('unselected'),
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color:
                                    canSelect
                                        ? Colors.grey.shade400
                                        : Colors.grey.shade300,
                                width: 2,
                              ),
                              shape: BoxShape.circle,
                            ),
                          ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
