import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import '../state/tab_swipe_lock.dart';


import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';

import '../data/dummy_data.dart';
import '../state/app_state.dart';
import 'comment_sheet.dart';

class VideoPlayerPage extends StatefulWidget {
  final String videoId;
  const VideoPlayerPage({super.key, required this.videoId});

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage>
    with SingleTickerProviderStateMixin {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  double _speed = 1.0;

  bool _showControls = true;
  Timer? _hideTimer;


  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 180),
    lowerBound: 0.0,
    upperBound: 1.0,
  );


  static const Color _navy = Color(0xFF0B1B3A);
  static const Color _lightBlue = Color(0xFF7DD3FC);

  @override
  void initState() {
    super.initState();
    TabSwipeLock.acquire();

    final item = videos.firstWhere((v) => v.id == widget.videoId);

    _controller = VideoPlayerController.asset(item.assetPath);
    _initializeVideoPlayerFuture = _controller.initialize();

    _controller.addListener(_onVideoStateChanged);
  }

  void _onVideoStateChanged() {
    if (!mounted) return;

    if (_controller.value.isPlaying) {
      _startAutoHide();
    } else {
      _cancelAutoHide();
      setState(() => _showControls = true);
    }
  }

  void _startAutoHide() {
    _cancelAutoHide();
    _hideTimer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      if (_controller.value.isPlaying) {
        setState(() => _showControls = false);
      }
    });
  }

  void _cancelAutoHide() {
    _hideTimer?.cancel();
    _hideTimer = null;
  }

  @override
  void dispose() {
    TabSwipeLock.release();

    _cancelAutoHide();
    _controller.removeListener(_onVideoStateChanged);
    _controller.dispose();
    _pulse.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _showControls = true;
        _cancelAutoHide();
      } else {
        _controller.play();
        _startAutoHide();
      }
    });
  }

  void _rewind10() {
    final current = _controller.value.position;
    final target = current - const Duration(seconds: 10);
    _controller.seekTo(target.isNegative ? Duration.zero : target);

    if (_controller.value.isPlaying) {
      setState(() => _showControls = true);
      _startAutoHide();
    }
  }

  void _forward10() {
    final current = _controller.value.position;
    final dur = _controller.value.duration;
    final target = current + const Duration(seconds: 10);
    _controller.seekTo(target >= dur ? dur : target);

    if (_controller.value.isPlaying) {
      setState(() => _showControls = true);
      _startAutoHide();
    }
  }

  Future<void> _setSpeed(double s) async {
    await _controller.setPlaybackSpeed(s);
    if (!mounted) return;
    setState(() => _speed = s);
  }


  Future<void> _cycleSpeed() async {
    const order = <double>[1.5, 2.0, 0.5, 1.0];
    final idx = order.indexOf(_speed);
    final next = order[(idx + 1) % order.length];
    await _setSpeed(next);


    TabSwipeLock.release();
  }

  Future<void> _openComments() async {

    await _pulse.forward();
    await _pulse.reverse();

    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: CommentSheet(videoId: widget.videoId),
      ),
    );
  }

  void _onVideoTap() {
    setState(() => _showControls = !_showControls);

    if (_controller.value.isPlaying && _showControls) {
      _startAutoHide();
    } else {
      _cancelAutoHide();
    }
  }

  Future<void> _openFullscreen() async {
    final wasPlaying = _controller.value.isPlaying;
    final pos = _controller.value.position;

    _controller.pause();


    await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) => _FullscreenVideoPage(
          controller: _controller,
          initialPosition: pos,
          autoplay: wasPlaying,
        ),
      ),
    );

    if (!mounted) return;
    setState(() => _showControls = true);
    if (_controller.value.isPlaying) _startAutoHide();
  }

  static String _fmt(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    if (h > 0) return '${two(h)}:${two(m)}:${two(s)}';
    return '${two(m)}:${two(s)}';
  }

  @override
  Widget build(BuildContext context) {
    final item = videos.firstWhere((v) => v.id == widget.videoId);
    final state = AppStateScope.of(context);

    final description = item.description;

    return Scaffold(
      backgroundColor: _navy,


      drawer: const _ProfileDrawerSame(),

      appBar: AppBar(
        backgroundColor: _navy,
        foregroundColor: Colors.white,


        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),

        title: Text(item.title),
        actions: [

          AnimatedBuilder(
            animation: _pulse,
            builder: (_, __) {
              final t = 1.0 + (_pulse.value * 0.06);
              return Transform.scale(
                scale: t,
                child: IconButton(
                  icon: const Icon(Icons.comment),
                  onPressed: _openComments,
                  tooltip: 'Komentar',
                ),
              );
            },
          ),


          Listener(
            onPointerDown: (_) => TabSwipeLock.acquire(),
            onPointerUp: (_) => TabSwipeLock.release(),
            onPointerCancel: (_) => TabSwipeLock.release(),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () async {
                await _pulse.forward();
                await _pulse.reverse();
                await _cycleSpeed();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Center(
                  child: Text(
                    '${_speed}x',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      body: FutureBuilder(
        future: _initializeVideoPlayerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [

              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF0F2A54),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 20,
                      offset: Offset(0, 10),
                      color: Colors.black26,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _onVideoTap,
                      child: Stack(
                        children: [
                          Positioned.fill(child: VideoPlayer(_controller)),

    
                          Positioned.fill(
                            child: IgnorePointer(
                              ignoring: !_showControls,
                              child: AnimatedOpacity(
                                opacity: _showControls ? 1 : 0,
                                duration: const Duration(milliseconds: 150),
                                child: Container(
                                  color: Colors.black26,
                                  child: Stack(
                                    children: [

                                      Center(
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            _GlassCircleButton(
                                              icon: Icons.replay_10_rounded,
                                              onPressed: _rewind10,
                                            ),
                                            const SizedBox(width: 16),
                                            _GlassCircleButton(
                                              big: true,
                                              icon: _controller.value.isPlaying
                                                  ? Icons.pause_rounded
                                                  : Icons.play_arrow_rounded,
                                              onPressed: _togglePlayPause,
                                            ),
                                            const SizedBox(width: 16),
                                            _GlassCircleButton(
                                              icon: Icons.forward_10_rounded,
                                              onPressed: _forward10,
                                            ),
                                          ],
                                        ),
                                      ),

                             
                                      Positioned(
                                        right: 6,
                                        bottom: 42,
                                        child: _GlassCircleButton(
                                          icon: Icons.fullscreen_rounded,
                                          onPressed: _openFullscreen,
                                        ),
                                      ),

                              
                                      Positioned(
                                        left: 0,
                                        right: 0,
                                        bottom: 0,
                                        child: Container(
                                          padding: const EdgeInsets.fromLTRB(
                                              12, 10, 12, 10),
                                          decoration: const BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                Colors.transparent,
                                                Colors.black54
                                              ],
                                            ),
                                          ),
                                          child: AnimatedBuilder(
                                            animation: _controller,
                                            builder: (context, _) {
                                              final pos =
                                                  _controller.value.position;
                                              final dur =
                                                  _controller.value.duration;

                                              return Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  VideoProgressIndicator(
                                                    _controller,
                                                    allowScrubbing: true,
                                                    padding: EdgeInsets.zero,
                                                    colors: VideoProgressColors(
                                                      playedColor: _lightBlue,
                                                      bufferedColor:
                                                          Colors.white24,
                                                      backgroundColor:
                                                          Colors.white12,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        _fmt(pos),
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                      Text(
                                                        _fmt(dur),
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),

   
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F2A54),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Deskripsi',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    AnimatedBuilder(
                      animation: state,
                      builder: (context, _) {
                        final reaction = state.reactionOf(widget.videoId);
                        final likeCount = state.likeCount(widget.videoId);
                        final dislikeCount = state.dislikeCount(widget.videoId);

                        return Row(
                          children: [
                            _IconCountButton(
                              active: reaction == Reaction.like,
                              activeColor: _lightBlue,
                              icon: Icons.thumb_up_rounded,
                              count: likeCount,
                              onTap: () async {
                                await _pulse.forward();
                                await _pulse.reverse();
                                await state.toggleLike(widget.videoId);
                              },
                            ),
                            const SizedBox(width: 20),
                            _IconCountButton(
                              active: reaction == Reaction.dislike,
                              activeColor: Colors.redAccent,
                              icon: Icons.thumb_down_rounded,
                              count: dislikeCount,
                              onTap: () async {
                                await _pulse.forward();
                                await _pulse.reverse();
                                await state.toggleDislike(widget.videoId);
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: null,
    );
  }
}



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


class _GlassCircleButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool big;

  const _GlassCircleButton({
    required this.icon,
    required this.onPressed,
    this.big = false,
  });

  @override
  State<_GlassCircleButton> createState() => _GlassCircleButtonState();
}

class _GlassCircleButtonState extends State<_GlassCircleButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final size = widget.big ? 64.0 : 48.0;
    final iconSize = widget.big ? 38.0 : 26.0;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _pressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withOpacity(0.18)),
          ),
          child: Icon(
            widget.icon,
            size: iconSize,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}


class _IconCountButton extends StatefulWidget {
  final bool active;
  final Color activeColor;
  final IconData icon;
  final int count;
  final Future<void> Function() onTap;

  const _IconCountButton({
    required this.active,
    required this.activeColor,
    required this.icon,
    required this.count,
    required this.onTap,
  });

  @override
  State<_IconCountButton> createState() => _IconCountButtonState();
}

class _IconCountButtonState extends State<_IconCountButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final color =
        widget.active ? widget.activeColor : Colors.white.withOpacity(0.85);

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () async {
        await widget.onTap();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Row(
          children: [
            Icon(widget.icon, size: 22, color: color),
            const SizedBox(width: 6),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              transitionBuilder: (child, anim) => ScaleTransition(
                scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
                child: FadeTransition(opacity: anim, child: child),
              ),
              child: Text(
                '${widget.count}',
                key: ValueKey(widget.count),
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _FullscreenVideoPage extends StatefulWidget {
  final VideoPlayerController controller;
  final Duration initialPosition;
  final bool autoplay;

  const _FullscreenVideoPage({
    required this.controller,
    required this.initialPosition,
    required this.autoplay,
  });

  @override
  State<_FullscreenVideoPage> createState() => _FullscreenVideoPageState();
}

class _FullscreenVideoPageState extends State<_FullscreenVideoPage> {
  bool _showControls = true;
  Timer? _hideTimer;

  static const Color _lightBlue = Color(0xFF7DD3FC);

  @override
  void initState() {
    super.initState();
    _enterFullscreenMode();

    widget.controller.seekTo(widget.initialPosition).then((_) {
      if (widget.autoplay) widget.controller.play();
      _startAutoHideIfPlaying();
      setState(() {});
    });

    widget.controller.addListener(_onChanged);
  }

  Future<void> _enterFullscreenMode() async {
    // landscape + immersive (system UI)
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    await SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  Future<void> _exitFullscreenMode() async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    await SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  void _onChanged() {
    if (!mounted) return;
    if (widget.controller.value.isPlaying) {
      _startAutoHideIfPlaying();
    } else {
      _cancelHide();
      setState(() => _showControls = true);
    }
  }

  void _startAutoHideIfPlaying() {
    _cancelHide();
    _hideTimer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      if (widget.controller.value.isPlaying) {
        setState(() => _showControls = false);
      }
    });
  }

  void _cancelHide() {
    _hideTimer?.cancel();
    _hideTimer = null;
  }

  @override
  void dispose() {
    _cancelHide();
    widget.controller.removeListener(_onChanged);
    _exitFullscreenMode();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      widget.controller.value.isPlaying
          ? widget.controller.pause()
          : widget.controller.play();
    });
  }

  void _rewind10() {
    final current = widget.controller.value.position;
    final target = current - const Duration(seconds: 10);
    widget.controller.seekTo(target.isNegative ? Duration.zero : target);

    if (widget.controller.value.isPlaying) {
      setState(() => _showControls = true);
      _startAutoHideIfPlaying();
    }
  }

  void _forward10() {
    final current = widget.controller.value.position;
    final dur = widget.controller.value.duration;
    final target = current + const Duration(seconds: 10);
    widget.controller.seekTo(target >= dur ? dur : target);

    if (widget.controller.value.isPlaying) {
      setState(() => _showControls = true);
      _startAutoHideIfPlaying();
    }
  }

  static String _fmt(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    if (h > 0) return '${two(h)}:${two(m)}:${two(s)}';
    return '${two(m)}:${two(s)}';
  }

  void _onTap() {
    setState(() => _showControls = !_showControls);
    if (widget.controller.value.isPlaying && _showControls) {
      _startAutoHideIfPlaying();
    } else {
      _cancelHide();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _onTap,
        child: Stack(
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: controller.value.isInitialized
                    ? controller.value.aspectRatio
                    : 16 / 9,
                child: VideoPlayer(controller),
              ),
            ),

            Positioned.fill(
              child: IgnorePointer(
                ignoring: !_showControls,
                child: AnimatedOpacity(
                  opacity: _showControls ? 1 : 0,
                  duration: const Duration(milliseconds: 150),
                  child: Container(
                    color: Colors.black26,
                    child: Stack(
                      children: [
                        Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _GlassCircleButton(
                                icon: Icons.replay_10_rounded,
                                onPressed: _rewind10,
                              ),
                              const SizedBox(width: 16),
                              _GlassCircleButton(
                                big: true,
                                icon: controller.value.isPlaying
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                onPressed: _togglePlayPause,
                              ),
                              const SizedBox(width: 16),
                              _GlassCircleButton(
                                icon: Icons.forward_10_rounded,
                                onPressed: _forward10,
                              ),
                            ],
                          ),
                        ),

                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding:
                                const EdgeInsets.fromLTRB(12, 10, 12, 10),
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, Colors.black54],
                              ),
                            ),
                            child: AnimatedBuilder(
                              animation: controller,
                              builder: (_, __) {
                                final pos = controller.value.position;
                                final dur = controller.value.duration;

                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    VideoProgressIndicator(
                                      controller,
                                      allowScrubbing: true,
                                      padding: EdgeInsets.zero,
                                      colors: VideoProgressColors(
                                        playedColor: _lightBlue,
                                        bufferedColor: Colors.white24,
                                        backgroundColor: Colors.white12,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          _fmt(pos),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                          ),
                                        ),
                                        Text(
                                          _fmt(dur),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            Positioned(
              top: 16,
              left: 12,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: IconButton(
                  color: Colors.white,
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
