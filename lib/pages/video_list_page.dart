import 'package:flutter/material.dart';
import '../data/dummy_data.dart';
import 'video_player_page.dart';

// ✅ samakan isi drawer seperti ProfileDrawer
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';

class VideoListPage extends StatelessWidget {
  final String accountId;
  const VideoListPage({super.key, required this.accountId});

  @override
  Widget build(BuildContext context) {
    final acc = accounts.firstWhere((a) => a.id == accountId);
    final list = videos.where((v) => v.accountId == accountId).toList();

    const navy = Color(0xFF0A1A2F);
    const navyLight = Color(0xFF102A43);
    const accentBlue = Color(0xFF3B82F6);

    return Scaffold(
      backgroundColor: navy,

      // ✅ DRAWER: ISINYA DISAMAKAN DENGAN ProfileDrawer
      drawer: const _ProfileDrawerSame(),

      appBar: AppBar(
        elevation: 0,
        centerTitle: false,

        // ✅ tombol sidebar kiri (tanpa ubah struktur halaman)
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),

        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        title: Text('Video • ${acc.displayName}'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0A1A2F), Color(0xFF102A43)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),

      body: list.isEmpty
          ? const Center(
              child: Text(
                'Belum ada video untuk akun ini.',
                style: TextStyle(color: Colors.white70),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, i) {
                final v = list[i];

                return InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VideoPlayerPage(videoId: v.id),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: navyLight,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ===== Thumbnail =====
Stack(
  alignment: Alignment.center,
  children: [
    // ✅ Thumbnail dari lokal (assets)
    ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: SizedBox(
        height: 160,
        width: double.infinity,
        child: Image.asset(
          v.thumbnailAsset,           // ✅ path thumbnail dari dummy_data.dart
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            // fallback kalau file gak ketemu / path salah
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    accentBlue.withOpacity(0.35),
                    navy,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            );
          },
        ),
      ),
    ),

    // ✅ overlay biar icon play tetap jelas
    Container(
      height: 160,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        color: Colors.black.withOpacity(0.18),
      ),
    ),

    // tombol play
    Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.play_arrow_rounded,
        size: 36,
        color: Colors.white,
      ),
    ),
  ],
),


                        // ===== Info =====
                        Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  v.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.chevron_right,
                                color: Colors.white54,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

/* =========================================================
   Drawer internal: isinya sama dengan ProfileDrawer kamu
   (tanpa import file ProfileDrawer, jadi struktur VideoListPage tetap)
   ========================================================= */

class _ProfileDrawerSame extends StatelessWidget {
  const _ProfileDrawerSame();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Drawer(
      backgroundColor: AppTheme.navy,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.white12),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 18,
                    offset: Offset(0, 10),
                    color: Colors.black26,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppTheme.accent, AppTheme.lightBlue],
                      ),
                    ),
                    child: const Icon(Icons.person_rounded, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (user?.displayName?.isNotEmpty == true)
                              ? user!.displayName!
                              : 'Pengguna',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppTheme.text,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.email ?? '(email tidak tersedia)',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppTheme.subText,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _InfoTileSame(title: 'UID', value: user?.uid ?? '-'),
            _InfoTileSame(
              title: 'Email Verified',
              value: (user?.emailVerified ?? false) ? 'Ya' : 'Belum',
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white12),
              ),
              child: const Text(
                'Fitur upload belum diselesaikan. Aplikasi masih dalam tahap pengembangan. Setelah aplikasi rilis sepenuhnya anda akan bisa mengupload video anda disini.\n\nNantinya fitur hubungi Kreator juga akan dirilis sehingga calon klien bisa menjangkau kreator.',
                style: TextStyle(
                  color: AppTheme.subText,
                  height: 1.35,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTileSame extends StatelessWidget {
  final String title;
  final String value;
  const _InfoTileSame({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 12.5,
                color: AppTheme.subText,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: const TextStyle(
                fontSize: 12.5,
                color: AppTheme.text,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
