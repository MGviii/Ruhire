// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'providers.dart';
import '../auth_providers.dart';
import 'widgets.dart';
import '../screens.dart' as app;
import '../main.dart';

class ParentHomeScaffold extends ConsumerStatefulWidget {
  const ParentHomeScaffold({super.key});

  @override
  ConsumerState<ParentHomeScaffold> createState() => _ParentHomeScaffoldState();
}

class ParentAttendancePage extends ConsumerStatefulWidget {
  const ParentAttendancePage({super.key});

  @override
  ConsumerState<ParentAttendancePage> createState() => _ParentAttendancePageState();
}

class _ParentAttendancePageState extends ConsumerState<ParentAttendancePage> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).pop()),
        title: const Text('Attendance'),
        actions: [
          Builder(
            builder: (ctx) => IconButton(
              tooltip: 'Menu',
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(ctx).openEndDrawer(),
            ),
          ),
        ],
      ),
      endDrawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const ListTile(title: Text('Menu', style: TextStyle(fontWeight: FontWeight.bold))),
              const Divider(height: 0),
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Profile'),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ParentProfilePage()));
                },
              ),
              const Divider(height: 0),
              ListTile(
                leading: const Icon(Icons.brightness_6_outlined),
                title: const Text('Appearance'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final mode = await showDialog<ThemeMode>(
                    context: context,
                    builder: (ctx) {
                      ThemeMode current = ref.read(themeModeProvider);
                      return AlertDialog(
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
                      );
                    },
                  );
                  if (mode != null) {
                    ref.read(themeModeProvider.notifier).state = mode;
                    await saveThemeModePreference(mode);
                  }
                },
              ),
              const Divider(height: 0),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.redAccent),
                title: const Text('Logout'),
                onTap: () async {
                  Navigator.of(context).pop();
                  await ref.read(authControllerProvider.notifier).signOut();
                  if (mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const app.RoleGate()),
                      (route) => false,
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
      body: const AttendanceScreen(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.directions_bus_outlined), selectedIcon: Icon(Icons.directions_bus), label: 'Bus'),
          NavigationDestination(icon: Icon(Icons.notifications_outlined), selectedIcon: Icon(Icons.notifications), label: 'Notifications'),
        ],
      ),
    );
  }
}

class ParentProfilePage extends ConsumerStatefulWidget {
  const ParentProfilePage({super.key});

  @override
  ConsumerState<ParentProfilePage> createState() => _ParentProfilePageState();
}

class _ParentProfilePageState extends ConsumerState<ParentProfilePage> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).pop()),
        title: const Text('Profile'),
        actions: [
          Builder(
            builder: (ctx) => IconButton(
              tooltip: 'Menu',
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(ctx).openEndDrawer(),
            ),
          ),
        ],
      ),
      endDrawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const ListTile(title: Text('Menu', style: TextStyle(fontWeight: FontWeight.bold))),
              const Divider(height: 0),
              ListTile(
                leading: const Icon(Icons.list_alt_outlined),
                title: const Text('Attendance'),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ParentAttendancePage()));
                },
              ),
              const Divider(height: 0),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.redAccent),
                title: const Text('Logout'),
                onTap: () async {
                  Navigator.of(context).pop();
                  await ref.read(authControllerProvider.notifier).signOut();
                  if (mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const app.RoleGate()),
                      (route) => false,
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
      body: const ProfileScreen(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.directions_bus_outlined), selectedIcon: Icon(Icons.directions_bus), label: 'Bus'),
          NavigationDestination(icon: Icon(Icons.notifications_outlined), selectedIcon: Icon(Icons.notifications), label: 'Notifications'),
        ],
      ),
    );
  }
}

class ParentNotificationsScreen extends ConsumerWidget {
  const ParentNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final init = ref.watch(notificationInitProvider);
    return init.when(
      data: (_) => ListView(
        padding: const EdgeInsets.all(12),
        children: const [
          Card(
            child: ListTile(
              leading: Icon(Icons.notifications),
              title: Text('Notifications'),
              subtitle: Text('You will see your notifications here.'),
            ),
          ),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

class _ParentHomeScaffoldState extends ConsumerState<ParentHomeScaffold> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const ParentDashboardScreen(),
      const ParentMapScreen(),
      const ParentNotificationsScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Parent'),
        actions: [
          Builder(
            builder: (ctx) => IconButton(
              tooltip: 'Menu',
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(ctx).openEndDrawer(),
            ),
          ),
        ],
      ),
      endDrawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const ListTile(
                title: Text('Menu', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const Divider(height: 0),
              ListTile(
                leading: const Icon(Icons.list_alt_outlined),
                title: const Text('Attendance'),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ParentAttendancePage()));
                },
              ),
              const Divider(height: 0),
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Profile'),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ParentProfilePage()));
                },
              ),
              const Divider(height: 0),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.redAccent),
                title: const Text('Logout'),
                onTap: () async {
                  Navigator.of(context).pop();
                  await ref.read(authControllerProvider.notifier).signOut();
                  if (mounted) {
                    // hard redirect to auth gate
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const app.RoleGate()),
                      (route) => false,
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
      body: pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.directions_bus_outlined), selectedIcon: Icon(Icons.directions_bus), label: 'Bus'),
          NavigationDestination(icon: Icon(Icons.notifications_outlined), selectedIcon: Icon(Icons.notifications), label: 'Notifications'),
        ],
      ),
    );
  }
}

class ParentDashboardScreen extends ConsumerWidget {
  const ParentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roleInit = ref.watch(notificationInitProvider);
    final profileAsync = ref.watch(profileProvider);
    final lastLocation = ref.watch(busLocationStreamProvider).asData?.value;

    return ResponsivePadding(
      child: ListView(
        children: [
          SectionCard(
            title: 'Your Child',
            child: Consumer(
              builder: (context, ref, _) {
                final childrenAsync = ref.watch(childrenProvider);
                return childrenAsync.when(
                  data: (kids) {
                    if (kids.isEmpty) {
                      return const Text('No linked child found');
                    }
                    return Column(
                      children: kids
                          .map((c) => ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const Icon(Icons.child_care),
                                title: Text(c.name.isEmpty ? '-' : c.name),
                                subtitle: Text(c.className.isEmpty ? '-' : 'Class: ${c.className}'),
                              ))
                          .toList(),
                    );
                  },
                  loading: () => const LinearProgressIndicator(),
                  error: (e, _) => Text('Error: $e'),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          SectionCard(
            title: 'Your Information',
            child: profileAsync.when(
              data: (p) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.parentName.isEmpty ? 'Name: -' : 'Name: ${p.parentName}'),
                  const SizedBox(height: 4),
                  Text(p.parentEmail.isEmpty ? 'Email: -' : 'Email: ${p.parentEmail}'),
                  if (p.parentPhone.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text('Phone: ${p.parentPhone}'),
                  ],
                ],
              ),
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Error: $e'),
            ),
          ),
          SectionCard(
            title: 'Bus',
            child: Text(lastLocation == null
                ? 'Locating...'
                : 'Lat: ${lastLocation.latitude.toStringAsFixed(5)}, Lng: ${lastLocation.longitude.toStringAsFixed(5)}'),
          ),
          SectionCard(
            title: 'Notifications',
            child: roleInit.when(
              data: (_) => const Text('Notifications initialized'),
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Error: $e'),
            ),
          ),
        ],
      ),
    );
  }
}

class ParentMapScreen extends ConsumerStatefulWidget {
  const ParentMapScreen({super.key});

  @override
  ConsumerState<ParentMapScreen> createState() => _ParentMapScreenState();
}

class _ParentMapScreenState extends ConsumerState<ParentMapScreen> {
  GoogleMapController? _controller;

  @override
  Widget build(BuildContext context) {
    final locationAsync = ref.watch(busLocationStreamProvider);
    return locationAsync.when(
      data: (loc) {
        final marker = Marker(
          markerId: const MarkerId('bus'),
          position: LatLng(loc.latitude, loc.longitude),
          infoWindow: const InfoWindow(title: 'School Bus'),
        );
        return GoogleMap(
          initialCameraPosition: CameraPosition(target: LatLng(loc.latitude, loc.longitude), zoom: 15),
          markers: {marker},
          onMapCreated: (c) => _controller = c,
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

class AttendanceScreen extends ConsumerWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(attendanceProvider);
    return async.when(
      data: (rows) => ListView.separated(
        padding: const EdgeInsets.all(12),
        itemBuilder: (_, i) => ListTile(
          leading: Icon(rows[i].present ? Icons.check_circle : Icons.cancel, color: rows[i].present ? Colors.green : Colors.red),
          title: Text('${rows[i].date.toLocal()}'.split(' ')[0]),
          subtitle: Text(rows[i].present ? 'Present' : 'Absent'),
        ),
        separatorBuilder: (_, __) => const Divider(height: 0),
        itemCount: rows.length,
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(profileProvider);
    return async.when(
      data: (p) => ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            child: Column(
              children: [
                const ListTile(title: Text('Your Child')),
                const Divider(height: 0),
                Consumer(
                  builder: (context, ref, _) {
                    final childrenAsync = ref.watch(childrenProvider);
                    return childrenAsync.when(
                      data: (kids) {
                        if (kids.isEmpty) {
                          return const ListTile(title: Text('No linked child'));
                        }
                        return Column(
                          children: kids
                              .map((c) => ListTile(
                                    title: Text(c.name.isEmpty ? '-' : c.name),
                                    subtitle: Text(c.className.isEmpty ? '-' : 'Class: ${c.className}'),
                                  ))
                              .toList(),
                        );
                      },
                      loading: () => const Padding(
                        padding: EdgeInsets.all(12),
                        child: LinearProgressIndicator(),
                      ),
                      error: (e, _) => ListTile(title: Text('Error: $e')),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                const ListTile(title: Text('Your Information')),
                const Divider(height: 0),
                ListTile(title: const Text('Name'), subtitle: Text(p.parentName.isEmpty ? '-' : p.parentName)),
                ListTile(title: const Text('Email'), subtitle: Text(p.parentEmail.isEmpty ? '-' : p.parentEmail)),
                if (p.parentPhone.isNotEmpty)
                  ListTile(title: const Text('Phone'), subtitle: Text(p.parentPhone)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ListTile(title: Text('Appearance')),
                const Divider(height: 0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Consumer(
                    builder: (context, ref, _) {
                      final current = ref.watch(themeModeProvider);
                      return Column(
                        children: [
                          RadioListTile<ThemeMode>(
                            value: ThemeMode.system,
                            groupValue: current,
                            onChanged: (v) async {
                              if (v == null) return;
                              ref.read(themeModeProvider.notifier).state = v;
                              await saveThemeModePreference(v);
                            },
                            title: const Text('System default'),
                          ),
                          RadioListTile<ThemeMode>(
                            value: ThemeMode.light,
                            groupValue: current,
                            onChanged: (v) async {
                              if (v == null) return;
                              ref.read(themeModeProvider.notifier).state = v;
                              await saveThemeModePreference(v);
                            },
                            title: const Text('Light'),
                          ),
                          RadioListTile<ThemeMode>(
                            value: ThemeMode.dark,
                            groupValue: current,
                            onChanged: (v) async {
                              if (v == null) return;
                              ref.read(themeModeProvider.notifier).state = v;
                              await saveThemeModePreference(v);
                            },
                            title: const Text('Dark'),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}
