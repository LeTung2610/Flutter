import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/login_screen.dart';
import '../screens/admin_dashboard_screen.dart';
import '../main.dart'; 

class AuthRefreshListenable extends ChangeNotifier {
  AuthRefreshListenable() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      notifyListeners();
    });
  }
}

class AppRouter {
  static final AuthRefreshListenable authRefreshListenable = AuthRefreshListenable();

  static final router = GoRouter(
    initialLocation: '/',
    refreshListenable: authRefreshListenable,
    redirect: (context, state) {
      final bool loggedIn = FirebaseAuth.instance.currentUser != null;
      final bool loggingIn = state.matchedLocation == '/login';
      
      if (!loggedIn) return loggingIn ? null : '/login';
      if (loggingIn) return '/';
      
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const MainNavigation(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
    ],
  );
}
