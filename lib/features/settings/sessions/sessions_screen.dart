import 'package:ellipsized_text/ellipsized_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/utils/app_icons.dart';
import 'package:kibisis/utils/theme_extensions.dart';
import 'package:kibisis/utils/wallet_connect_manageer.dart';
import 'package:walletconnect_flutter_v2/apis/sign_api/models/session_models.dart';
import 'package:kibisis/providers/accounts_list_provider.dart';
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
  bool _isClearingAccountSessions = false;

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
      _loadingSessionTopic = topic;
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

  void _disconnectAllSessions() async {
    setState(() {
      _isClearingAccountSessions = true; // Show the loading spinner
    });

    final walletConnectManager = WalletConnectManager();
    await walletConnectManager.disconnectAllSessions();

    if (!mounted) return;
    showCustomSnackBar(
      context: context,
      snackType: SnackType.success,
      message: 'All sessions disconnected successfully.',
    );

    setState(() {
      _isClearingAccountSessions = false; // Stop the loading spinner
    });

    // Reload sessions to refresh the UI
    _loadSessions();
  }

  Future<void> _disconnectSessionsForAccount(String publicKey) async {
    setState(() {
      _isClearingAccountSessions = true; // Show the loading spinner
    });

    final walletConnectManager = WalletConnectManager();
    await walletConnectManager.disconnectAllSessionsForAccount(publicKey);

    if (!mounted) return;
    showCustomSnackBar(
      context: context,
      snackType: SnackType.success,
      message: 'All sessions for $publicKey disconnected successfully.',
    );

    setState(() {
      _isClearingAccountSessions = false; // Stop the loading spinner
    });

    // Reload sessions to refresh the UI
    _loadSessions();
  }

  @override
  Widget build(BuildContext context) {
    final accountsState = ref.watch(accountsListProvider);

    if (accountsState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (accountsState.error != null) {
      return Center(child: Text('Error: ${accountsState.error}'));
    }

    if (accountsState.accounts.isEmpty) {
      return const Center(child: Text('No accounts available.'));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(SessionsScreen.title),
        actions: [
          if (accountsState.accounts.isNotEmpty)
            if (_isClearingAccountSessions)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            else
              IconButton(
                icon: const Icon(AppIcons.disconnect),
                onPressed: _disconnectAllSessions,
                color: context.colorScheme.error,
                tooltip: 'Clear All Sessions',
              ),
        ],
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

          // Group sessions by account public key
          final Map<String, List<SessionData>> accountSessions = {};
          for (var session in sessions) {
            for (var namespace in session.namespaces.values) {
              for (var account in namespace.accounts) {
                final accountParts = account.split(':');
                final publicKey = accountParts.last;
                if (accountSessions.containsKey(publicKey)) {
                  accountSessions[publicKey]!.add(session);
                } else {
                  accountSessions[publicKey] = [session];
                }
              }
            }
          }

          // Filter accounts with active sessions
          final List<Map<String, String>> activeAccounts = accountsState
              .accounts
              .where((account) =>
                  accountSessions.containsKey(account['publicKey']))
              .toList();

          if (activeAccounts.isEmpty) {
            debugPrint('No active sessions for any accounts.');
            return const Center(child: Text('No active sessions.'));
          }

          return Column(
            children: [
              const SizedBox(
                  height: 20), // This is the SizedBox added at the top
              Expanded(
                // Use Expanded to allow the ListView to take up the remaining space
                child: ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: kScreenPadding),
                  itemCount: activeAccounts.length,
                  itemBuilder: (context, index) {
                    final account = activeAccounts[index];
                    final accountName =
                        account['accountName'] ?? 'Unnamed Account';
                    final publicKey = account['publicKey'] ?? 'No Public Key';
                    final sessionsForAccount = accountSessions[publicKey]!;

                    if (accountsState.accounts.length == 1 &&
                        sessionsForAccount.length == 1) {
                      final session = sessionsForAccount.first;
                      final isLoading = _loadingSessionTopic == session.topic;

                      return ListTile(
                        title: EllipsizedText(
                          session.peer.metadata.name,
                          style: context.textTheme.titleMedium,
                        ),
                        subtitle: EllipsizedText(
                          session.peer.metadata.url,
                          style: context.textTheme.bodyMedium,
                        ),
                        trailing: isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : IconButton(
                                icon: Icon(AppIcons.disconnect,
                                    size: AppIcons.large,
                                    color: context.colorScheme.error),
                                onPressed: () => _disconnectSession(
                                  session.topic,
                                  session.peer.metadata.name,
                                ),
                              ),
                      );
                    }

                    return ExpansionTile(
                      title: EllipsizedText(
                        accountName,
                        style: context.textTheme.titleMedium,
                      ),
                      subtitle: EllipsizedText(
                        publicKey,
                        type: EllipsisType.middle,
                        style: context.textTheme.bodyMedium,
                      ),
                      leading: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: context.colorScheme.primary,
                          ),
                          padding: const EdgeInsets.all(kScreenPadding / 2),
                          child: Icon(
                            AppIcons.wallet,
                            size: AppIcons.large,
                            color: context.colorScheme.onPrimary,
                          )),
                      collapsedIconColor: context.colorScheme.onSurface,
                      iconColor: context.colorScheme.onSurface,
                      childrenPadding: const EdgeInsets.only(
                          bottom: kScreenPadding / 2,
                          left: 0,
                          right: kScreenPadding,
                          top: kScreenPadding / 2),
                      children: [
                        if (sessionsForAccount.length > 1)
                          TextButton(
                              onPressed: _isClearingAccountSessions
                                  ? null
                                  : () =>
                                      _disconnectSessionsForAccount(publicKey),
                              child: Row(
                                children: [
                                  Icon(
                                    AppIcons.disconnect,
                                    size: AppIcons.large,
                                    color: context.colorScheme.error,
                                  ),
                                  const SizedBox(
                                    width: kScreenPadding,
                                  ),
                                  Text('Disconnect All',
                                      style: context.textTheme.titleSmall
                                          ?.copyWith(
                                              color:
                                                  context.colorScheme.error)),
                                ],
                              )),
                        const SizedBox(height: kScreenPadding / 2),
                        ...sessionsForAccount.map((session) {
                          final isLoading =
                              _loadingSessionTopic == session.topic;
                          debugPrint(
                              'Displaying session: ${session.peer.metadata.name}');

                          return ListTile(
                            title: EllipsizedText(
                              session.peer.metadata.name,
                              style: context.textTheme.titleMedium,
                            ),
                            subtitle: EllipsizedText(
                              session.peer.metadata.url,
                              style: context.textTheme.bodyMedium,
                            ),
                            trailing: isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : IconButton(
                                    icon: Icon(AppIcons.disconnect,
                                        size: AppIcons.large,
                                        color: context.colorScheme.error),
                                    onPressed: () => _disconnectSession(
                                      session.topic,
                                      session.peer.metadata.name,
                                    ),
                                  ),
                          );
                        }),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            GoRouter.of(context).push('/qrScanner', extra: ScanMode.general),
        backgroundColor: context.colorScheme.secondary,
        foregroundColor: Colors.white,
        child: const Icon(AppIcons.scan),
      ),
    );
  }
}
