import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../core/theme.dart';
import '../../core/services/habit_service.dart'; // Ensure import
import 'package:sakin_app/l10n/generated/app_localizations.dart';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  bool _isEditMode = false;
  bool _isDeleteMode = false;

  List<Map<String, dynamic>> _habits = [];
  List<double> _heatmapData = []; // Last 28 days data
  double _todayProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // 1. Load habits
    final habits = HabitService.loadHabits();

    // 2. Prepare heatmap data (Last 28 days)
    final history = HabitService.loadHeatmap();
    List<double> heatmap = [];
    final now = DateTime.now();

    // Go back 27 days + today = 28 blocks
    for (int i = 27; i >= 0; i--) {
      DateTime date = now.subtract(Duration(days: i));
      String dateKey = date.toIso8601String().split('T')[0];
      heatmap.add(history[dateKey] ?? 0.0); // 0.0 if incomplete
    }

    // 3. Calculate today's progress percentage
    int completed = habits.where((h) => h['completed'] == true).length;
    double progress = habits.isEmpty ? 0 : completed / habits.length;

    setState(() {
      _habits = habits;
      _heatmapData = heatmap;
      _todayProgress = progress;
    });
  }

  // Central save function and UI update
  Future<void> _saveAndUpdate() async {
    await HabitService.saveHabits(_habits);
    _loadData(); // Reload to update heatmap immediately
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(isDark),
              const SizedBox(height: 20),
              Text(AppLocalizations.of(context)!.habitLog,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white70 : Colors.black54)),
              const SizedBox(height: 10),
              _buildHeatmap(isDark),
              const SizedBox(height: 25),
              _buildControlBar(isDark),
              const SizedBox(height: 15),
              Text(AppLocalizations.of(context)!.todaysTasks,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: isDark ? Colors.white : Colors.black)),
              const SizedBox(height: 10),
              _buildHabitsList(isDark),
            ],
          ),
        ),
      ),
    );
  }

  // --- Widgets ---

  Widget _buildControlBar(bool isDark) {
    return Row(
      children: [
        Expanded(
            child: _controlBtn(AppLocalizations.of(context)!.addHabit,
                HugeIcons.strokeRoundedPlusSign,
                isDark: isDark,
                isActive: false,
                onTap: () => _showHabitDialog())),
        const SizedBox(width: 10),
        Expanded(
            child: _controlBtn(AppLocalizations.of(context)!.edit,
                HugeIcons.strokeRoundedEdit02,
                isDark: isDark,
                isActive: _isEditMode,
                activeColor: Colors.orange,
                onTap: () => setState(() {
                      _isEditMode = !_isEditMode;
                      _isDeleteMode = false;
                    }))),
        const SizedBox(width: 10),
        Expanded(
            child: _controlBtn(AppLocalizations.of(context)!.delete,
                HugeIcons.strokeRoundedDelete02,
                isDark: isDark,
                isActive: _isDeleteMode,
                activeColor: Colors.red,
                onTap: () => setState(() {
                      _isDeleteMode = !_isDeleteMode;
                      _isEditMode = false;
                    }))),
      ],
    );
  }

  Widget _controlBtn(String label, dynamic icon,
      {required bool isDark,
      required bool isActive,
      required VoidCallback onTap,
      Color activeColor = AppTheme.primaryColor}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? activeColor.withValues(alpha: 0.2)
              : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isActive
                  ? activeColor
                  : (isDark ? Colors.white10 : Colors.grey.shade300)),
        ),
        child: Column(children: [
          HugeIcon(
              icon: icon,
              color: isActive
                  ? activeColor
                  : (isDark ? Colors.white : Colors.black87),
              size: 20),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isActive
                      ? activeColor
                      : (isDark ? Colors.white70 : Colors.black54))),
        ]),
      ),
    );
  }

  Widget _buildHabitsList(bool isDark) {
    if (_habits.isEmpty) {
      return Center(
          child: Text(AppLocalizations.of(context)!.noTasksYet,
              style: const TextStyle(color: Colors.grey)));
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _habits.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final habit = _habits[index];
        bool isCompleted = habit['completed'] ?? false;

        return GestureDetector(
          onTap: () {
            if (_isDeleteMode) {
              _showDeleteConfirm(index);
            } else if (_isEditMode) {
              _showHabitDialog(initialTitle: habit['title'], index: index);
            } else {
              // Toggle status and save
              setState(() => _habits[index]['completed'] = !isCompleted);
              _saveAndUpdate();
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isDeleteMode
                    ? Colors.red.withValues(alpha: 0.5)
                    : (_isEditMode
                        ? Colors.orange.withValues(alpha: 0.5)
                        : Colors.transparent),
                width: (_isDeleteMode || _isEditMode) ? 1.5 : 0,
              ),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4))
              ],
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted
                        ? AppTheme.primaryColor
                        : Colors.transparent,
                    border: Border.all(
                        color: isCompleted
                            ? AppTheme.primaryColor
                            : (isDark ? Colors.white38 : Colors.grey.shade400),
                        width: 2),
                  ),
                  child: isCompleted
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    habit['title'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isCompleted
                          ? (isDark ? Colors.white38 : Colors.grey)
                          : (isDark ? Colors.white : Colors.black87),
                      decoration:
                          isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
                HugeIcon(
                    icon: _getIcon(habit['icon']),
                    color: isDark ? Colors.white38 : Colors.grey,
                    size: 20),
                if (_isDeleteMode) ...[
                  const SizedBox(width: 10),
                  const Icon(Icons.delete_forever, color: Colors.red, size: 20)
                ],
                if (_isEditMode) ...[
                  const SizedBox(width: 10),
                  const Icon(Icons.edit, color: Colors.orange, size: 20)
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  // --- Dialogs ---

  void _showHabitDialog({String? initialTitle, int? index}) {
    final controller = TextEditingController(text: initialTitle);
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text(initialTitle == null ? l10n.addHabit : l10n.editHabit),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: l10n.habitName),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white),
            onPressed: () {
              if (controller.text.isNotEmpty) {
                if (index != null) {
                  _habits[index]['title'] = controller.text;
                } else {
                  _habits.add({
                    'title': controller.text,
                    'icon': 0,
                    'completed': false
                  });
                }
                _saveAndUpdate();
                setState(() => _isEditMode = false);
              }
              Navigator.pop(ctx);
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirm(int index) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text(l10n.deleteHabitTitle),
        content: Text(l10n.deleteHabitConfirmation),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
          TextButton(
            onPressed: () {
              setState(() {
                _habits.removeAt(index);
                if (_habits.isEmpty) _isDeleteMode = false;
              });
              _saveAndUpdate();
              Navigator.pop(ctx);
            },
            child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // --- Helpers ---

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.05),
              blurRadius: 10)
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(AppLocalizations.of(context)!.achievementBoard,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black)),
            Text(AppLocalizations.of(context)!.smallSteps,
                style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white70 : Colors.grey)),
          ]),
          Stack(alignment: Alignment.center, children: [
            SizedBox(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(
                    value: _todayProgress,
                    color: AppTheme.primaryColor,
                    backgroundColor:
                        isDark ? Colors.white10 : Colors.grey.shade100)),
            Text("${(_todayProgress * 100).toInt()}%",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: isDark ? Colors.white : Colors.black)),
          ]),
        ],
      ),
    );
  }

  Widget _buildHeatmap(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16)),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7, crossAxisSpacing: 5, mainAxisSpacing: 5),
        itemCount: 28, // 4 weeks
        itemBuilder: (_, i) {
          double opacity = i < _heatmapData.length ? _heatmapData[i] : 0.0;
          return Container(
            decoration: BoxDecoration(
              color: opacity > 0
                  ? AppTheme.primaryColor
                      .withValues(alpha: 0.2 + (opacity * 0.8))
                  : (isDark ? Colors.white10 : Colors.grey.shade200),
              borderRadius: BorderRadius.circular(4),
              border: i == 27
                  ? Border.all(color: AppTheme.primaryColor, width: 2)
                  : null, // Highlight today
            ),
          );
        },
      ),
    );
  }

  dynamic _getIcon(dynamic code) {
    // This can be expanded to return different icons based on code
    return HugeIcons.strokeRoundedCheckList;
  }
}
