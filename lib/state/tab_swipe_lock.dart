import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

class TabSwipeLock {
  TabSwipeLock._();

  static final ValueNotifier<bool> locked = ValueNotifier<bool>(false);
  static int _count = 0;

  static void acquire() {
    _count++;
    if (_count < 0) _count = 0;
    _scheduleNotify();
  }

  static void release() {
    _count--;
    if (_count < 0) _count = 0;
    _scheduleNotify();
  }

  static void _scheduleNotify() {
    final next = _count > 0;

    void commit() {
      if (locked.value == next) return;
      locked.value = next;
    }

    final phase = SchedulerBinding.instance.schedulerPhase;
    final inBuild = phase == SchedulerPhase.persistentCallbacks ||
        phase == SchedulerPhase.midFrameMicrotasks;

    if (inBuild) {
      WidgetsBinding.instance.addPostFrameCallback((_) => commit());
    } else {
      commit();
    }
  }
}
