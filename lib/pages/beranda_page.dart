import 'package:flutter/material.dart';

import 'home_page.dart';
import 'account_picker_page.dart';
import 'me_profile_page.dart';

import '../state/tab_swipe_lock.dart';

class BerandaPage extends StatefulWidget {
  const BerandaPage({super.key});

  @override
  State<BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> {
  int _index = 0;

  final _homeKey = GlobalKey<NavigatorState>();
  final _exploreKey = GlobalKey<NavigatorState>();
  final _profileKey = GlobalKey<NavigatorState>();

  late final PageController _pageCtrl = PageController(initialPage: _index);

  GlobalKey<NavigatorState> get _currentKey {
    switch (_index) {
      case 0:
        return _homeKey;
      case 1:
        return _exploreKey;
      default:
        return _profileKey;
    }
  }

  Future<bool> _showExitDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar aplikasi?'),
        content: const Text('Yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<bool> _onWillPop() async {
    final nav = _currentKey.currentState;

    if (nav != null && nav.canPop()) {
      nav.pop();
      return false;
    }

    if (_index != 0) {
      _goToTab(0);
      return false;
    }

    final exit = await _showExitDialog();
    return exit;
  }

  void _goToTab(int i) {
    setState(() => _index = i);
    _pageCtrl.animateToPage(
      i,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: ValueListenableBuilder<bool>(
  valueListenable: TabSwipeLock.locked,
  builder: (context, locked, _) {
    return PageView(
      controller: _pageCtrl,
      physics: locked
          ? const NeverScrollableScrollPhysics()
          : const BouncingScrollPhysics(),
      onPageChanged: (i) => setState(() => _index = i),
      children: [
        _buildTabNavigator(key: _homeKey, root: const HomePage()),
        _buildTabNavigator(key: _exploreKey, root: const AccountPickerPage()),
        _buildTabNavigator(key: _profileKey, root: const MeProfilePage()),
      ],
    );
  },
),

        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: _goToTab,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.explore_outlined),
              selectedIcon: Icon(Icons.explore_rounded),
              label: 'Explore',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabNavigator({
    required GlobalKey<NavigatorState> key,
    required Widget root,
  }) {
    return Navigator(
      key: key,
      onGenerateRoute: (settings) {
        return MaterialPageRoute(builder: (_) => root);
      },
    );
  }
}
