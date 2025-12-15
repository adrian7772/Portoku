import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/profile_drawer.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const ProfileDrawer(),
      appBar: AppBar(
        title: const Text('Beranda'),
        leading: Builder(
          builder: (context) => IconButton(
            tooltip: 'Sidebar',
            icon: const Icon(Icons.menu_rounded),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Selamat datang 👋',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.text,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Aplikasi Portoku adalah aplikasi berbagi Video Portofolio tanpa kompresi video. \n\nCalon klien bisa melihat portofolio kalian dengan kualitas penuh',
                    style: TextStyle(
                      fontSize: 13.5,
                      height: 1.35,
                      color: AppTheme.subText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppTheme.accent, AppTheme.lightBlue],
                      ),
                    ),
                    child: const Icon(Icons.explore_rounded,
                        color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Explore',
                          style: TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.text,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Pilih akun kreator dan lihat Portofolio mereka',
                          style: TextStyle(
                            fontSize: 12.8,
                            color: AppTheme.subText,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  FilledButton(
                    onPressed: () {
                      // Pindah tab Explore lebih “benar”
                      DefaultTabController.maybeOf(context);
                      // Karena kita pakai bottom nav, user tinggal tap Explore.
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Tap tab Explore di bawah 👇')),
                      );
                    },
                    child: const Text('Buka'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
