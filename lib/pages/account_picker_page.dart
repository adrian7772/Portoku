import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_theme.dart';
import '../widgets/profile_drawer.dart';
import '../data/dummy_data.dart';
import 'video_list_page.dart';

class AccountPickerPage extends StatefulWidget {
  const AccountPickerPage({super.key});

  @override
  State<AccountPickerPage> createState() => _AccountPickerPageState();
}

class _AccountPickerPageState extends State<AccountPickerPage> {
  // ===== SharedPrefs keys =====
  static const _kSubscribedKey = 'portoku_subscribed_by_account_v1';
  static const _kFollowersKey = 'portoku_followers_by_account_v1';

  // ===== state lokal =====
  final Map<String, bool> _subscribedByAccount = {};
  final Map<String, int> _followersByAccount = {};

  @override
  void initState() {
    super.initState();
    _bootstrapState();
  }

  Future<void> _bootstrapState() async {
    // isi default dari dummy_data.dart dulu
    for (final a in accounts) {
      _subscribedByAccount.putIfAbsent(a.id, () => false);
      _followersByAccount.putIfAbsent(a.id, () => a.followers);
    }

    // lalu load dari SharedPreferences (kalau ada)
    final prefs = await SharedPreferences.getInstance();

    final subRaw = prefs.getString(_kSubscribedKey);
    if (subRaw != null && subRaw.isNotEmpty) {
      final Map<String, dynamic> m = jsonDecode(subRaw);
      for (final entry in m.entries) {
        _subscribedByAccount[entry.key] = entry.value == true;
      }
    }

    final folRaw = prefs.getString(_kFollowersKey);
    if (folRaw != null && folRaw.isNotEmpty) {
      final Map<String, dynamic> m = jsonDecode(folRaw);
      for (final entry in m.entries) {
        final v = entry.value;
        if (v is int) {
          _followersByAccount[entry.key] = v;
        } else if (v is num) {
          _followersByAccount[entry.key] = v.toInt();
        }
      }
    }

    if (mounted) setState(() {});
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kSubscribedKey, jsonEncode(_subscribedByAccount));
    await prefs.setString(_kFollowersKey, jsonEncode(_followersByAccount));
  }

  void _toggleSubscribe(String accountId, String username) {
    setState(() {
      final cur = _subscribedByAccount[accountId] ?? false;
      final next = !cur;
      _subscribedByAccount[accountId] = next;

      final curFollowers = _followersByAccount[accountId] ??
          accounts.firstWhere((a) => a.id == accountId).followers;

      if (next) {
        _followersByAccount[accountId] = curFollowers + 1;
      } else {
        // jangan sampai minus
        _followersByAccount[accountId] = (curFollowers - 1).clamp(0, 1 << 30);
      }
    });

    // simpan ke prefs (async, tapi nggak mengubah struktur UI)
    _persist();

    final subscribed = _subscribedByAccount[accountId] ?? false;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          subscribed ? 'Kamu subscribe @$username' : 'Kamu unsubscribe @$username',
        ),
      ),
    );
  }

  String _fmtFollowers(int n) {
    if (n >= 1000000) {
      final v = n / 1000000.0;
      return '${v.toStringAsFixed(v >= 10 ? 0 : 1)}M';
    }
    if (n >= 1000) {
      final v = n / 1000.0;
      return '${v.toStringAsFixed(v >= 10 ? 0 : 1)}K';
    }
    return '$n';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const ProfileDrawer(),
      appBar: AppBar(
        title: const Text('Explore'),
        leading: Builder(
          builder: (context) => IconButton(
            tooltip: 'Sidebar',
            icon: const Icon(Icons.menu_rounded),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: accounts.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final a = accounts[i];
          final subscribed = _subscribedByAccount[a.id] ?? false;
          final followers = _followersByAccount[a.id] ?? a.followers;

          return Card(
            color: AppTheme.surface,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
              side: BorderSide(color: Colors.white.withOpacity(0.10)),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: () {
                Navigator.push(
  context,
  MaterialPageRoute(
    settings: const RouteSettings(name: '/videoList'),
    builder: (_) => VideoListPage(accountId: a.id),
  ),
);

              },
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white12),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          a.avatarAsset,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [AppTheme.accent, AppTheme.lightBlue],
                              ),
                            ),
                            child: const Icon(Icons.person_rounded,
                                color: Colors.white, size: 22),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            a.displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15.8,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.text,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            a.username,
                            style: const TextStyle(
                              fontSize: 12.6,
                              color: AppTheme.subText,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            a.bio,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.5,
                              color: AppTheme.subText.withOpacity(0.88),
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.people_alt_rounded,
                                size: 14,
                                color: AppTheme.subText.withOpacity(0.9),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${_fmtFollowers(followers)} followers',
                                style: TextStyle(
                                  fontSize: 12.2,
                                  color: AppTheme.subText.withOpacity(0.95),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 10),

                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: subscribed
                                ? AppTheme.accent.withOpacity(0.16)
                                : Colors.white.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: IconButton(
                            tooltip: subscribed ? 'Unsubscribe' : 'Subscribe',
                            onPressed: () => _toggleSubscribe(a.id, a.username),
                            icon: Icon(
                              subscribed
                                  ? Icons.notifications_active_rounded
                                  : Icons.notifications_none_rounded,
                              size: 20,
                              color: subscribed ? Colors.white : AppTheme.subText,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.chevron_right_rounded,
                            color: AppTheme.subText),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
