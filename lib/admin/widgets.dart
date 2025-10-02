import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../main.dart';

class AdminCard extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback? onTap;
  final IconData? icon;
  final Color? iconColor;
  const AdminCard({
    super.key,
    required this.title,
    required this.child,
    this.onTap,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final card = Card(
      elevation: 2,
      shadowColor: scheme.shadow.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [
                scheme.surface,
                scheme.surfaceVariant.withOpacity(0.5),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: scheme.outlineVariant.withOpacity(0.5)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (icon != null)
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: (iconColor ?? scheme.primary).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: iconColor ?? scheme.primary),
                  ),
                if (icon != null) const SizedBox(width: 12),
                Expanded(child: Text(title, style: Theme.of(context).textTheme.titleMedium)),
                const Icon(Icons.chevron_right),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ]),
        ),
      ),
    );
    return card;
  }
}

class AdminGrid extends StatelessWidget {
  final List<Widget> children;
  const AdminGrid({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final cols = width > 1400 ? 3 : width > 900 ? 2 : 1;
    return GridView.count(
      crossAxisCount: cols,
      childAspectRatio: 1.8,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: children,
    );
  }
}

class AdminToolbar extends ConsumerWidget {
  final List<Widget> actions;
  const AdminToolbar({super.key, required this.actions});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(children: [
        Expanded(child: Text('Admin', style: Theme.of(context).textTheme.titleLarge)),
        ...actions,
        const SizedBox(width: 8),
        Tooltip(
          message: 'Appearance',
          child: IconButton(
            icon: const Icon(Icons.brightness_6_outlined),
            onPressed: () async {
              ThemeMode current = ref.read(themeModeProvider);
              final mode = await showDialog<ThemeMode>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Appearance'),
                  content: StatefulBuilder(
                    builder: (ctx, setState) => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RadioListTile<ThemeMode>(
                          value: ThemeMode.system,
                          groupValue: current,
                          onChanged: (v) => setState(() => current = v!),
                          title: const Text('System default'),
                        ),
                        RadioListTile<ThemeMode>(
                          value: ThemeMode.light,
                          groupValue: current,
                          onChanged: (v) => setState(() => current = v!),
                          title: const Text('Light'),
                        ),
                        RadioListTile<ThemeMode>(
                          value: ThemeMode.dark,
                          groupValue: current,
                          onChanged: (v) => setState(() => current = v!),
                          title: const Text('Dark'),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
                    ElevatedButton(onPressed: () => Navigator.of(ctx).pop(current), child: const Text('Apply')),
                  ],
                ),
              );
              if (mode != null) {
                ref.read(themeModeProvider.notifier).state = mode;
                await saveThemeModePreference(mode);
              }
            },
          ),
        ),
      ]),
    );
  }
}
