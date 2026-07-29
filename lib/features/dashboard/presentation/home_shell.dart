import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_typography.dart';
import '../../../core/router/module_registry.dart';
import '../../authentication/presentation/auth_controller.dart';
import '../../../shared/widgets/avatars/profile_avatar.dart'; // We will create this

class HomeShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const HomeShell({super.key, required this.navigationShell});

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moduleRegistry = ref.watch(moduleRegistryProvider);
    final bottomNavModules = moduleRegistry.bottomNavModules;
    
    // We get the authenticated user
    final authState = ref.watch(authControllerProvider);
    final user = authState.user;
    
    final orgName = user?.companyName ?? user?.organizationName ?? 'My Organization';
    
    return Scaffold(
      appBar: AppBar(
        title: Text(orgName, style: AppTypography.title.copyWith(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: const Badge(
              child: Icon(Icons.notifications_none_rounded),
            ),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0, left: 8.0),
            child: ProfileAvatar(
              name: user?.username ?? 'User',
              photoId: user?.profilePhotoId,
              onTap: () {
                // Open profile or drawer
              },
            ),
          ),
        ],
      ),
      body: navigationShell,
      bottomNavigationBar: bottomNavModules.isEmpty ? null : NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _goBranch,
        destinations: bottomNavModules.map((module) {
          return NavigationDestination(
            icon: Icon(module.icon),
            label: module.title,
          );
        }).toList(),
      ),
    );
  }
}
