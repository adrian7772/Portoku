import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/comment.dart';

enum Reaction { none, like, dislike }

class AppState extends ChangeNotifier {
  static const _kReactionsKey = 'portoku_reactions_v1';
  static const _kCommentsKey = 'portoku_comments_v1';

  // 0 = none, 1 = like, 2 = dislike
  final Map<String, int> _reactions = {};
  final Map<String, List<Comment>> _comments = {};

  bool _loaded = false;
  bool get loaded => _loaded;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    final reactionsRaw = prefs.getString(_kReactionsKey);
    if (reactionsRaw != null && reactionsRaw.isNotEmpty) {
      final map = jsonDecode(reactionsRaw) as Map<String, dynamic>;
      _reactions
        ..clear()
        ..addAll(map.map((k, v) => MapEntry(k, (v as num).toInt())));
    }

    final commentsRaw = prefs.getString(_kCommentsKey);
    if (commentsRaw != null && commentsRaw.isNotEmpty) {
      final map = jsonDecode(commentsRaw) as Map<String, dynamic>;
      _comments.clear();
      map.forEach((videoId, listAny) {
        final list = (listAny as List)
            .map((e) => Comment.fromJson(e as Map<String, dynamic>))
            .toList();
        _comments[videoId] = list;
      });
    }

    _loaded = true;
    notifyListeners();
  }

  Future<void> _saveReactions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kReactionsKey, jsonEncode(_reactions));
  }

  Future<void> _saveComments() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonMap = _comments.map((videoId, list) =>
        MapEntry(videoId, list.map((c) => c.toJson()).toList()));
    await prefs.setString(_kCommentsKey, jsonEncode(jsonMap));
  }

  Reaction reactionOf(String videoId) {
    final v = _reactions[videoId] ?? 0;
    if (v == 1) return Reaction.like;
    if (v == 2) return Reaction.dislike;
    return Reaction.none;
  }

  int likeCount(String videoId) => reactionOf(videoId) == Reaction.like ? 1 : 0;
  int dislikeCount(String videoId) =>
      reactionOf(videoId) == Reaction.dislike ? 1 : 0;

  Future<void> toggleLike(String videoId) async {
    final current = reactionOf(videoId);
    _reactions[videoId] = (current == Reaction.like) ? 0 : 1;
    notifyListeners();
    await _saveReactions();
  }

  Future<void> toggleDislike(String videoId) async {
    final current = reactionOf(videoId);
    _reactions[videoId] = (current == Reaction.dislike) ? 0 : 2;
    notifyListeners();
    await _saveReactions();
  }

  List<Comment> commentsFor(String videoId) =>
      List.unmodifiable(_comments[videoId] ?? []);

  Future<void> addComment({
    required String videoId,
    required String author,
    required String message,
  }) async {
    final list = _comments[videoId] ?? [];
    final newComment = Comment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      videoId: videoId,
      author: author,
      message: message,
      createdAt: DateTime.now(),
    );
    _comments[videoId] = [...list, newComment];
    notifyListeners();
    await _saveComments();
  }
}

class AppStateScope extends InheritedNotifier<AppState> {
  const AppStateScope({
    super.key,
    required AppState notifier,
    required Widget child,
  }) : super(notifier: notifier, child: child);

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppStateScope>();
    assert(scope != null, 'AppStateScope not found in widget tree');
    return scope!.notifier!;
  }
}
