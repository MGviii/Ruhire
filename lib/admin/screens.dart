import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'providers.dart';
import 'widgets.dart';
import 'profile_providers.dart';
import 'student_widgets.dart';
import '../auth_providers.dart';

class AdminScaffold extends ConsumerStatefulWidget {
  const AdminScaffold({super.key});

  @override
  ConsumerState<AdminScaffold> createState() => _AdminScaffoldState();
}

class _AdminScaffoldState extends ConsumerState<AdminScaffold> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = const [
      AdminDashboardScreen(),
      AdminLiveMapScreen(),
      AdminAttendanceScreen(),
      AdminReportsScreen(),
      AdminManagementScreen(),
      AdminProfileScreen(),
    ];

    return Scaffold(
      body: Row(children: [
        NavigationRail(
          selectedIndex: index,
          onDestinationSelected: (i) => setState(() => index = i),
          labelType: NavigationRailLabelType.all,
          destinations: const [
            NavigationRailDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: Text('Dashboard')),
            NavigationRailDestination(icon: Icon(Icons.map_outlined), selectedIcon: Icon(Icons.map), label: Text('Live Map')),
            NavigationRailDestination(icon: Icon(Icons.fact_check_outlined), selectedIcon: Icon(Icons.fact_check), label: Text('Attendance')),
            NavigationRailDestination(icon: Icon(Icons.insert_drive_file_outlined), selectedIcon: Icon(Icons.insert_drive_file), label: Text('Reports')),
            NavigationRailDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: Text('Manage')),
            NavigationRailDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: Text('Profile')),
          ],
        ),
        const VerticalDivider(width: 1),
        Expanded(child: pages[index]),
      ]),
    );
  }
}

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(adminDashboardStatsProvider);
    final buses = ref.watch(adminBusesProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(children: [
        const AdminToolbar(actions: []),
        AdminGrid(children: [
          AdminCard(
            title: 'Buses',
            child: stats.when(
              data: (s) => Text('${s.totalBuses}'),
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Error: $e'),
            ),
          ),
          AdminCard(
            title: 'Active Students',
            child: stats.when(
              data: (s) => Text('${s.activeStudents}'),
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Error: $e'),
            ),
          ),
          AdminCard(
            title: 'Alerts',
            child: stats.when(
              data: (s) => Text('${s.activeAlerts}'),
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Error: $e'),
            ),
          ),
        ]),
        const SizedBox(height: 12),
        AdminCard(
          title: 'Active Buses',
          child: buses.when(
            data: (list) => Wrap(spacing: 8, runSpacing: 8, children: list.map((b) => Chip(label: Text(b.name))).toList()),
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('Error: $e'),
          ),
        ),
      ]),
    );
  }
}

class AdminLiveMapScreen extends ConsumerWidget {
  const AdminLiveMapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final buses = ref.watch(adminBusesProvider);
    return buses.when(
      data: (list) {
        if (list.isEmpty) return const Center(child: Text('No buses'));
        final first = list.first;
        final markers = list
            .map((b) => Marker(
                  markerId: MarkerId(b.id),
                  position: LatLng(b.latitude, b.longitude),
                  infoWindow: InfoWindow(title: b.name, snippet: 'Onboard: ${b.onboardStudentIds.length}'),
                ))
            .toSet();
        return GoogleMap(
          initialCameraPosition: CameraPosition(target: LatLng(first.latitude, first.longitude), zoom: 12),
          markers: markers,
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

class AdminAttendanceScreen extends ConsumerStatefulWidget {
  const AdminAttendanceScreen({super.key});

  @override
  ConsumerState<AdminAttendanceScreen> createState() => _AdminAttendanceScreenState();
}

class _AdminAttendanceScreenState extends ConsumerState<AdminAttendanceScreen> {
  String? status;
  String query = '';
  final Set<String> _selected = <String>{};

  @override
  Widget build(BuildContext context) {
    final rows = ref.watch(adminAttendanceProvider((query: query.isEmpty ? null : query, status: status)));
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const AdminToolbar(actions: []),
        Row(children: [
          SizedBox(
            width: 240,
            child: TextField(
              decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search student'),
              onChanged: (v) => setState(() => query = v),
            ),
          ),
          const SizedBox(width: 12),
          DropdownButton<String>(
            value: status,
            hint: const Text('Status'),
            items: const [DropdownMenuItem(value: 'check-in', child: Text('Check-in')), DropdownMenuItem(value: 'check-out', child: Text('Check-out'))],
            onChanged: (v) => setState(() => status = v),
          ),
        ]),
        if (_selected.isNotEmpty) ...[
          const SizedBox(height: 8),
          Material(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.12)),
              ),
              child: Row(children: [
                Text('${_selected.length} selected'),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => setState(() => _selected.clear()),
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Export selected (placeholder)')),
                    );
                  },
                  icon: const Icon(Icons.download),
                  label: const Text('Export'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Marked as reviewed (placeholder)')),
                    );
                  },
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Mark reviewed'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error, foregroundColor: Theme.of(context).colorScheme.onError),
                  onPressed: () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Delete records'),
                        content: Text('Are you sure you want to delete ${_selected.length} selected record(s)?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                          ElevatedButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Delete')),
                        ],
                      ),
                    );
                    if (ok == true) {
                      // Placeholder: wire to backend when available
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Deleted ${_selected.length} record(s) (placeholder)')),
                        );
                        setState(() => _selected.clear());
                      }
                    }
                  },
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Delete'),
                ),
              ]),
            ),
          ),
        ],
        const SizedBox(height: 12),
        Expanded(
          child: rows.when(
            data: (list) => SingleChildScrollView(
              child: DataTableTheme(
                data: DataTableThemeData(
                  headingRowColor: MaterialStateProperty.all(Theme.of(context).colorScheme.surface),
                  dataRowColor: MaterialStateProperty.resolveWith((states) {
                    if (states.contains(MaterialState.hovered)) {
                      return Theme.of(context).colorScheme.primary.withOpacity(0.06);
                    }
                    return Colors.transparent;
                  }),
                ),
                child: DataTable(
                  showCheckboxColumn: true,
                  onSelectAll: (checked) {
                    setState(() {
                      _selected.clear();
                      if (checked == true) {
                        for (final r in list) {
                          _selected.add(r.id);
                        }
                      }
                    });
                  },
                  columns: const [
                    DataColumn(label: Text('Student')),
                    DataColumn(label: Text('Timestamp')),
                    DataColumn(label: Text('Status')),
                  ],
                  rows: list
                      .map((r) => DataRow(
                            selected: _selected.contains(r.id),
                            onSelectChanged: (checked) {
                              setState(() {
                                if (checked == true) {
                                  _selected.add(r.id);
                                } else {
                                  _selected.remove(r.id);
                                }
                              });
                            },
                            cells: [
                              DataCell(MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: Text(r.studentName),
                              )),
                              DataCell(Text(r.timestamp.toLocal().toString())),
                              DataCell(Text(r.status)),
                            ],
                          ))
                      .toList(),
                ),
              ),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
          ),
        ),
      ]),
    );
  }
}

class AdminReportsScreen extends ConsumerWidget {
  const AdminReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const AdminToolbar(actions: []),
        const SizedBox(height: 12),
        Row(children: [
          ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.download), label: const Text('Export CSV (placeholder)')),
          const SizedBox(width: 12),
          OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.picture_as_pdf), label: const Text('Export PDF (placeholder)')),
        ]),
        const SizedBox(height: 12),
        const Text('Configure your real export logic with backend integration.'),
      ]),
    );
  }
}

class AdminManagementScreen extends ConsumerWidget {
  const AdminManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const AdminToolbar(actions: []),
        const StudentsManagementSection(),
        const SizedBox(height: 12),
        const ParentsManagementSection(),
        const SizedBox(height: 12),
        const DriversManagementSection(),
      ]),
    );
  }
}

class AdminProfileScreen extends ConsumerStatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  ConsumerState<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends ConsumerState<AdminProfileScreen> {
  // ignore: unused_field
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _newEmail = TextEditingController();
  bool _editing = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _newEmail.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(adminProfileProvider);
    final action = ref.watch(adminProfileControllerProvider);

    return Padding(
      padding: const EdgeInsets.all(12),
      child: profileAsync.when(
        data: (p) {
          // Prefill controllers only when not editing to avoid overwriting user input
          if (!_editing) {
            _name.text = p.name;
            _phone.text = p.phone;
            _email.text = p.email;
          }
          return SingleChildScrollView(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const AdminToolbar(actions: []),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Your information', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    if (!_editing) ...[
                      ListTile(title: const Text('Name'), subtitle: Text(p.name.isEmpty ? '-' : p.name)),
                      ListTile(title: const Text('Email'), subtitle: Text(p.email.isEmpty ? '-' : p.email)),
                      ListTile(title: const Text('Phone'), subtitle: Text(p.phone.isEmpty ? '-' : p.phone)),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: IconButton(
                          tooltip: 'Edit',
                          icon: const Icon(Icons.edit),
                          onPressed: () => setState(() => _editing = true),
                        ),
                      ),
                    ] else ...[
                      Form(
                        key: _formKey,
                        child: Column(children: [
                          Row(children: [
                            Expanded(
                              child: TextFormField(
                                controller: _name,
                                decoration: const InputDecoration(labelText: 'Name'),
                                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _phone,
                                decoration: const InputDecoration(labelText: 'Phone'),
                              ),
                            ),
                          ]),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _email,
                            decoration: const InputDecoration(labelText: 'Email'),
                            validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                          ),
                          const SizedBox(height: 12),
                          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                            TextButton(
                              onPressed: action.isLoading ? null : () => setState(() => _editing = false),
                              child: const Text('Cancel'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: action.isLoading
                                  ? null
                                  : () async {
                                      if (!_formKey.currentState!.validate()) return;
                                      await ref.read(adminProfileControllerProvider.notifier).updateAll(
                                            name: _name.text.trim(),
                                            phone: _phone.text.trim(),
                                            email: _email.text.trim(),
                                          );
                                      if (mounted && !ref.read(adminProfileControllerProvider).hasError) {
                                        setState(() => _editing = false);
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated')));
                                      }
                                    },
                              child: action.isLoading
                                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                                  : const Text('Save'),
                            ),
                          ]),
                        ]),
                      ),
                    ],
                    if (action.hasError)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(action.error.toString(), style: const TextStyle(color: Colors.red)),
                      ),
                  ]),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: ExpansionTile(
                  title: const Text('Security'),
                  childrenPadding: const EdgeInsets.all(12),
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: action.isLoading
                            ? null
                            : () async {
                                final currentController = TextEditingController();
                                final newPassController = TextEditingController();
                                final confirmController = TextEditingController();
                                final formKey = GlobalKey<FormState>();
                                final result = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Change Password'),
                                    content: Form(
                                      key: formKey,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          TextFormField(
                                            controller: currentController,
                                            obscureText: true,
                                            decoration: const InputDecoration(labelText: 'Current Password'),
                                            validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                                          ),
                                          const SizedBox(height: 8),
                                          TextFormField(
                                            controller: newPassController,
                                            obscureText: true,
                                            decoration: const InputDecoration(labelText: 'New Password'),
                                            validator: (v) => (v == null || v.length < 6) ? 'Min 6 chars' : null,
                                          ),
                                          const SizedBox(height: 8),
                                          TextFormField(
                                            controller: confirmController,
                                            obscureText: true,
                                            decoration: const InputDecoration(labelText: 'Confirm Password'),
                                            validator: (v) => v != newPassController.text ? 'Passwords do not match' : null,
                                          ),
                                        ],
                                      ),
                                    ),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                                      ElevatedButton(
                                        onPressed: () {
                                          if (formKey.currentState!.validate()) {
                                            Navigator.of(ctx).pop(true);
                                          }
                                        },
                                        child: const Text('Update'),
                                      ),
                                    ],
                                  ),
                                );
                                if (result == true) {
                                  await ref.read(adminProfileControllerProvider.notifier).changePassword(
                                        currentPassword: currentController.text,
                                        newPassword: newPassController.text,
                                      );
                                  if (mounted) {
                                    final ok = !ref.read(adminProfileControllerProvider).hasError;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(ok ? 'Password updated' : 'Failed to update password')),
                                    );
                                  }
                                }
                              },
                        child: action.isLoading
                            ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Text('Change password'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Account', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.logout),
                          label: const Text('Logout'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.redAccent),
                          ),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Logout'),
                                content: const Text('Are you sure you want to logout?'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                                  ElevatedButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Logout')),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              await ref.read(authControllerProvider.notifier).signOut();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
