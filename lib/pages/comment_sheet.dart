import 'package:flutter/material.dart';
import '../state/app_state.dart';

class CommentSheet extends StatefulWidget {
  final String videoId;

  const CommentSheet({
    super.key,
    required this.videoId,
  });

  @override
  State<CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends State<CommentSheet>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();

  // Tema sama seperti VideoPlayerPage
  static const Color _navy = Color(0xFF0B1B3A);
  static const Color _card = Color(0xFF0F2A54);
  static const Color _lightBlue = Color(0xFF7DD3FC);

  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 170),
    lowerBound: 0,
    upperBound: 1,
  );

  @override
  void dispose() {
    _controller.dispose();
    _pulse.dispose();
    super.dispose();
  }

  Future<void> _send(AppState state) async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    await _pulse.forward();
    await _pulse.reverse();

    await state.addComment(
      videoId: widget.videoId,
      author: 'akuntester1',
      message: text,
    );

    _controller.clear();
    if (mounted) FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: EdgeInsets.fromLTRB(12, 12, 12, 12 + bottomInset),
        decoration: const BoxDecoration(
          color: _navy,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: Column(
          children: [
            // ===== Header modern =====
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(18),
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
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.14)),
                    ),
                    child: const Icon(
                      Icons.comment_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Komentar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: Colors.white.withOpacity(0.12)),
                    ),
                    child: AnimatedBuilder(
                      animation: state,
                      builder: (_, __) => Text(
                        '${state.commentsFor(widget.videoId).length}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ===== List komentar (modern cards + animasi) =====
            Expanded(
              child: AnimatedBuilder(
                animation: state,
                builder: (context, _) {
                  final comments = state.commentsFor(widget.videoId);

                  if (comments.isEmpty) {
                    return Center(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: _card,
                          borderRadius: BorderRadius.circular(18),
                          border:
                              Border.all(color: Colors.white.withOpacity(0.10)),
                        ),
                        child: Text(
                          'Belum ada komentar.\nJadilah yang pertama 👀',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            height: 1.25,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.only(bottom: 10),
                    itemCount: comments.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final c = comments[index];

                      return TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 240),
                        curve: Curves.easeOutCubic,
                        builder: (context, t, child) => Opacity(
                          opacity: t,
                          child: Transform.translate(
                            offset: Offset(0, (1 - t) * 8),
                            child: child,
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _card,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.10)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // avatar
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      _lightBlue.withOpacity(0.85),
                                      Colors.white.withOpacity(0.12),
                                    ],
                                  ),
                                  border: Border.all(
                                      color: Colors.white.withOpacity(0.10)),
                                ),
                                child: Center(
                                  child: Text(
                                    (c.author.isNotEmpty
                                            ? c.author[0]
                                            : 'U')
                                        .toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      c.author,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      c.message,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.88),
                                        height: 1.25,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            // ===== Input modern (glass) =====
            Container(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withOpacity(0.10)),
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
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      cursorColor: _lightBlue,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(state),
                      decoration: InputDecoration(
                        hintText: 'Tulis komentar...',
                        hintStyle:
                            TextStyle(color: Colors.white.withOpacity(0.55)),
                        isDense: true,
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.06),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // tombol send modern + pulse
                  AnimatedBuilder(
                    animation: _pulse,
                    builder: (_, __) {
                      final t = 1.0 + (_pulse.value * 0.06);
                      return Transform.scale(
                        scale: t,
                        child: GestureDetector(
                          onTap: () => _send(state),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: _lightBlue.withOpacity(0.20),
                              border: Border.all(
                                  color: _lightBlue.withOpacity(0.55)),
                            ),
                            child: const Icon(
                              Icons.send_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      );
                    },
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
