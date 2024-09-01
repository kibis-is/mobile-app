import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/utils/app_icons.dart';
import 'package:kibisis/utils/theme_extensions.dart';
import 'package:kibisis/utils/wallet_connect_manageer.dart';
import 'package:walletconnect_flutter_v2/apis/sign_api/models/session_models.dart';
import 'package:kibisis/providers/account_provider.dart';
import 'package:kibisis/common_widgets/top_snack_bar.dart';

class SessionsScreen extends ConsumerStatefulWidget {
  static String title = 'Sessions';
  const SessionsScreen({super.key});

  @override
  SessionsScreenState createState() => SessionsScreenState();
}

class SessionsScreenState extends ConsumerState<SessionsScreen> {
  late Future<List<SessionData>> _sessionsFuture;
  String? _loadingSessionTopic; // Track the session being disconnected

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  void _loadSessions() {
    final walletConnectManager = WalletConnectManager();
    _sessionsFuture = walletConnectManager.getActiveSessions();
    debugPrint('Fetching active sessions...');
  }

  Future<void> _disconnectSession(String topic, String sessionName) async {
    setState(() {
      _loadingSessionTopic = topic; // Show the loading spinner for this session
    });

    final walletConnectManager = WalletConnectManager();
    await walletConnectManager.disconnectSession(topic);

    if (!mounted) return;
    showCustomSnackBar(
      context: context,
      snackType: SnackType.success,
      message: '$sessionName disconnected successfully.',
    );

    setState(() {
      _loadingSessionTopic = null; // Stop the loading spinner
    });

    // Reload sessions to refresh the UI
    _loadSessions();
  }

  @override
  Widget build(BuildContext context) {
    final accountState = ref.watch(accountProvider);
    final publicKey = accountState.account?.publicAddress.toString();

    return Scaffold(
      appBar: AppBar(
        title: Text(SessionsScreen.title),
      ),
      body: FutureBuilder<List<SessionData>>(
        future: _sessionsFuture,
        builder: (context, snapshot) {
          debugPrint('Fetching active sessions...');
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            debugPrint('No active sessions found.');
            return const Center(child: Text('No active sessions.'));
          }

          final sessions = snapshot.data!;
          debugPrint('Active sessions found: ${sessions.length}');
          final filteredSessions = sessions.where((session) {
            final accounts =
                session.namespaces.values.expand((ns) => ns.accounts);
            debugPrint('Session ${session.topic}: Accounts: $accounts');
            final match = accounts.any((account) {
              final accountParts = account.split(':');
              final address = accountParts.last; // Get the address part
              debugPrint(
                  'Checking if $address matches active account public key $publicKey');
              return address == publicKey;
            });
            debugPrint('Session ${session.topic}: Match found: $match');
            return match;
          }).toList();

          if (filteredSessions.isEmpty) {
            debugPrint('No active sessions for the current account.');
            return const Center(
                child: Text('No active sessions for this account.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: kScreenPadding),
            itemCount: filteredSessions.length,
            itemBuilder: (context, index) {
              final session = filteredSessions[index];
              final isLoading = _loadingSessionTopic == session.topic;
              debugPrint('Displaying session: ${session.peer.metadata.name}');

              return ListTile(
                title: Text(session.peer.metadata.name),
                subtitle: Text(session.peer.metadata.url),
                trailing: isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () => _disconnectSession(
                          session.topic,
                          session.peer.metadata.name,
                        ),
                      ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            GoRouter.of(context).push('/qrScanner', extra: ScanMode.general),
        backgroundColor: context.colorScheme.secondary,
        foregroundColor: Colors.white,
        child: const Icon(AppIcons.add),
      ),
    );
  }
}
