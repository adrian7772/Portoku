import 'package:flutter/material.dart';
import '../data/dummy_data.dart';
import 'video_list_page.dart';

class ProfilePage extends StatefulWidget {
  final String accountId;
  const ProfilePage({super.key, required this.accountId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  static const Color _navy = Color(0xFF0A1A2F);
  static const Color _navyCard = Color(0xFF0F2A54);
  static const Color _accentBlue = Color(0xFF3B82F6);
  static const Color _lightBlue = Color(0xFF7DD3FC);


  static final Map<String, bool> _subscribedByAccount = {};

  bool get _isSubscribed => _subscribedByAccount[widget.accountId] ?? false;

  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 160),
    lowerBound: 0,
    upperBound: 1,
  );

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  Future<void> _toggleSubscribe(String username) async {
    await _pulse.forward();
    await _pulse.reverse();

    setState(() {
      _subscribedByAccount[widget.accountId] = !_isSubscribed;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(
          _isSubscribed
              ? 'Subscribed ke @$username'
              : 'Unsubscribed dari @$username',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final acc = accounts.firstWhere((a) => a.id == widget.accountId);
    final subscribed = _isSubscribed;

    return Theme(
      data: Theme.of(context).copyWith(
        useMaterial3: true,
        scaffoldBackgroundColor: _navy,
        colorScheme: Theme.of(context).colorScheme.copyWith(
              brightness: Brightness.dark,
              primary: Colors.white,
              onPrimary: _navy,
              secondary: _accentBlue,
              onSecondary: Colors.white,
              surface: _navyCard,
              onSurface: Colors.white,
            ),
        appBarTheme: const AppBarTheme(
          backgroundColor: _navy,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(title: Text(acc.username)),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _navyCard,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.white12),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 20,
                    offset: Offset(0, 10),
                    color: Colors.black26,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              _accentBlue.withOpacity(0.9),
                              _lightBlue.withOpacity(0.85),
                            ],
                          ),
                          boxShadow: const [
                            BoxShadow(
                              blurRadius: 16,
                              offset: Offset(0, 8),
                              color: Colors.black26,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.person,
                            size: 34, color: Colors.white),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              acc.displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '@${acc.username}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.72),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      _PillStat(label: 'Followers', value: acc.followers),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // bio
                  Text(
                    acc.bio,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.86),
                      height: 1.35,
                    ),
                  ),

                  const SizedBox(height: 16),


                  Row(
                    children: [
                      Expanded(
                        child: AnimatedBuilder(
                          animation: _pulse,
                          builder: (_, __) {
                            final t = 1.0 + (_pulse.value * 0.05);
                            return Transform.scale(
                              scale: t,
                              child: _GlassButton(
                                icon: subscribed
                                    ? Icons.check_rounded
                                    : Icons.subscriptions_rounded,
                                label: subscribed ? 'Subscribed' : 'Subscribe',
                                background: subscribed
                                    ? Colors.white.withOpacity(0.14)
                                    : _accentBlue,
                                border: subscribed ? Colors.white24 : null,
                                onPressed: () => _toggleSubscribe(acc.username),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _GlassButton(
                          icon: Icons.play_circle_fill_rounded,
                          label: 'Lihat Video',
                          background: Colors.white.withOpacity(0.14),
                          border: Colors.white24,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => VideoListPage(
                                  accountId: widget.accountId,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PillStat extends StatelessWidget {
  final String label;
  final int value;
  const _PillStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$value',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.75),
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color background;
  final Color? border;

  const _GlassButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.background,
    this.border,
  });

  @override
  State<_GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<_GlassButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          height: 48,
          decoration: BoxDecoration(
            color: widget.background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: widget.border ?? Colors.transparent),
            boxShadow: const [
              BoxShadow(
                blurRadius: 18,
                offset: Offset(0, 10),
                color: Colors.black26,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
