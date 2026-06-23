import 'package:flutter/material.dart';

import 'models/auth_session.dart';
import 'pages/auth_page.dart';
import 'pages/hunter_shell.dart';
import 'services/auth_api.dart';
import 'services/task_api.dart';
import 'theme/hunter_theme.dart';

void main() {
  runApp(const HunterQuestApp());
}

class HunterQuestApp extends StatelessWidget {
  const HunterQuestApp({
    super.key,
    this.authApi,
    this.taskApi,
    this.initialSession,
    this.requireAuth = true,
  });

  final AuthApi? authApi;
  final TaskApi? taskApi;
  final AuthSession? initialSession;
  final bool requireAuth;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Solo Levelling Tasks',
      debugShowCheckedModeBanner: false,
      theme: buildHunterTheme(),
      home: _AuthGate(
        authApi: authApi ?? const AuthApi(),
        taskApi: taskApi,
        initialSession: initialSession,
        requireAuth: requireAuth,
      ),
    );
  }
}

class _AuthGate extends StatefulWidget {
  const _AuthGate({
    required this.authApi,
    required this.requireAuth,
    this.taskApi,
    this.initialSession,
  });

  final AuthApi authApi;
  final TaskApi? taskApi;
  final AuthSession? initialSession;
  final bool requireAuth;

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  AuthSession? _session;

  @override
  void initState() {
    super.initState();
    _session = widget.initialSession;
  }

  void _setSession(AuthSession session) {
    setState(() {
      _session = session;
    });
  }

  void _logout() {
    setState(() {
      _session = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.requireAuth || _session != null) {
      return HunterShell(
        taskApi:
            widget.taskApi ??
            TaskApi(authToken: widget.requireAuth ? _session?.token : null),
        currentUser: _session?.user,
        onLogout: widget.requireAuth ? _logout : null,
      );
    }

    return AuthPage(authApi: widget.authApi, onSignedIn: _setSession);
  }
}
