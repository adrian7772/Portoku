import 'package:flutter/material.dart';
import 'app_state.dart';

class AppStateRoot extends StatefulWidget {
  final Widget child;
  const AppStateRoot({super.key, required this.child});

  @override
  State<AppStateRoot> createState() => _AppStateRootState();
}

class _AppStateRootState extends State<AppStateRoot> {
  late final AppState _state = AppState();
  late final Future<void> _loadFuture = _state.load();

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppStateScope(
      notifier: _state,
      child: FutureBuilder(
        future: _loadFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return widget.child;
        },
      ),
    );
  }
}
