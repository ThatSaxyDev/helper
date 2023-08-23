import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import "dart:developer" as dev_tools show log;

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool loggedin = ref.watch(loggedInProvider);
    return Listener(
      onPointerDown: (event) {
        ref.read(appSessionServiceProvider.notifier).resetTimerState();
      },
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: loggedin == false ? const Page1() : const Page2(),
      ),
    );
  }
}

class Page1 extends ConsumerWidget {
  const Page1({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Page 1'),
      ),
      body: Center(
        child: ElevatedButton(
            onPressed: () {
              //! start the session timer
              ref.read(appSessionServiceProvider.notifier).countTime();

              //! flip the auth state (loggedinprovider)
              ref.read(loggedInProvider.notifier).update((state) => true);
            },
            child: const Text('Log in')),
      ),
    );
  }
}

class Page2 extends ConsumerWidget {
  const Page2({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int timerState = ref.watch(appSessionServiceProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Page 2'),
      ),
      body: Center(child: Text('Logged in, log out in ${(10 - timerState)}')),
    );
  }
}

StateNotifierProvider<AppSessionService, int> appSessionServiceProvider =
    StateNotifierProvider((ref) {
  return AppSessionService(ref: ref);
});

class AppSessionService extends StateNotifier<int> {
  final Ref _ref;
  AppSessionService({required Ref ref})
      : _ref = ref,
        super(0);

  void countTime() {
    state = 0;
    Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        state++;
        "Session time in seconds: $state".log();
        switch (state) {
          //! for 5 mins of inactivity, it would be case 300
          case 10:
            'Logged out due to in activity!!'.log();
            //! PERFROM YOUR AUTH STATE SWITCH LOGIC HERE
            //! in this case, I am merely switching the provider value back to false
            _ref.read(loggedInProvider.notifier).update((state) => false);
            timer.cancel();
            state = 0;
            break;
          default:
            () {};
        }
      },
    );
  }

  //! set counter to zero
  void resetTimerState() {
    state = 0;
  }
}

StateProvider<bool> loggedInProvider = StateProvider((ref) => false);

//! LOG EXTENSION - THIS HELPS TO CALL A .log() ON ANY OBJECT
//! checks if the app in is debug mode first.
extension Log on Object {
  void log() {
    if (kDebugMode) {
      dev_tools.log(toString());
    }
  }
}
