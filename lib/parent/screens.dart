// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
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
            child: lastLocation == null
                ? const Text('Locating...')
                : (kIsWeb
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 220,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Theme.of(context).dividerColor,
                              ),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(12.0),
                              child: Text(
                                'Map is loading... If this persists, hard reload the page or check API key restrictions.',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Lat: ${lastLocation.latitude.toStringAsFixed(5)}, Lng: ${lastLocation.longitude.toStringAsFixed(5)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 220,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: GoogleMap(
                                initialCameraPosition: CameraPosition(
                                  target: LatLng(lastLocation.latitude, lastLocation.longitude),
                                  zoom: 15,
                                ),
                                markers: {
                                  Marker(
                                    markerId: const MarkerId('bus_dashboard'),
                                    position: LatLng(lastLocation.latitude, lastLocation.longitude),
                                    infoWindow: const InfoWindow(
                                      title: 'Mock Address',
                                      snippet: 'School Bus Location',
                                    ),
                                  ),
                                },
                                myLocationButtonEnabled: false,
                                zoomControlsEnabled: false,
                                liteModeEnabled: false,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Lat: ${lastLocation.latitude.toStringAsFixed(5)}, Lng: ${lastLocation.longitude.toStringAsFixed(5)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      )),
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
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    // Check existing permission status without prompting.
    _checkPermissionSilently();
  }

  Future<void> _checkPermissionSilently() async {
    if (kIsWeb) return; // Permissions not needed on web here
    final status = await Geolocator.checkPermission();
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (mounted) {
      setState(() {
        _hasPermission = serviceEnabled && (status == LocationPermission.whileInUse || status == LocationPermission.always);
      });
    }
  }

  Future<void> _requestLocationPermission(BuildContext context) async {
    if (kIsWeb) return;
    var serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Prompt user to enable location services
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Enable Location Services'),
          content: const Text('Location services are disabled. Please enable them in system settings to show your position on the map.'),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Close')),
            TextButton(
              onPressed: () {
                Geolocator.openLocationSettings();
                Navigator.of(ctx).pop();
              },
              child: const Text('Open Settings'),
            ),
          ],
        ),
      );
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Permission Required'),
          content: const Text('Location permission is permanently denied. Please grant it from app settings.'),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Close')),
            TextButton(
              onPressed: () {
                Geolocator.openAppSettings();
                Navigator.of(ctx).pop();
              },
              child: const Text('Open App Settings'),
            ),
          ],
        ),
      );
      return;
    }

    if (mounted) {
      setState(() {
        _hasPermission = (permission == LocationPermission.whileInUse || permission == LocationPermission.always);
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locationAsync = ref.watch(busLocationStreamProvider);
    return locationAsync.when(
      data: (loc) {
        if (kIsWeb) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 300,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Theme.of(context).dividerColor),
                    ),
                    child: const Text(
                      'Map is loading... If this persists, hard reload the page or check API key restrictions.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('Lat: ${loc.latitude.toStringAsFixed(5)}, Lng: ${loc.longitude.toStringAsFixed(5)}'),
                ],
              ),
            ),
          );
        }
        final marker = Marker(
          markerId: const MarkerId('bus'),
          position: LatLng(loc.latitude, loc.longitude),
          infoWindow: const InfoWindow(title: 'School Bus'),
        );
        if (!_hasPermission) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('To show your current position on the map, allow location access.'),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => _requestLocationPermission(context),
                    icon: const Icon(Icons.my_location),
                    label: const Text('Enable Location'),
                  ),
                ],
              ),
            ),
          );
        }
        return GoogleMap(
          initialCameraPosition: CameraPosition(target: LatLng(loc.latitude, loc.longitude), zoom: 15),
          markers: {marker},
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
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
