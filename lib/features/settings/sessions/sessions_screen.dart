import 'package:ellipsized_text/ellipsized_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kibisis/common_widgets/confirmation_dialog.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/providers/storage_provider.dart';
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
  String? _loadingSessionTopic;
  bool _isClearingAccountSessions = false;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  void _loadSessions() {
    final storageService = ref.read(storageProvider);
    final walletConnectManager = WalletConnectManager(storageService);
    _sessionsFuture = walletConnectManager.getActiveSessions();
    debugPrint('Fetching active sessions...');
  }

  Future<void> _disconnectSession(String topic, String sessionName) async {
    setState(() {
      _loadingSessionTopic = topic;
    });
    final storageService = ref.read(storageProvider);
    final walletConnectManager = WalletConnectManager(storageService);
    bool success = false;

    try {
      await walletConnectManager.disconnectSession(topic);
      success = true;
    } catch (e) {
      debugPrint('Failed to disconnect session $topic: $e');
      if (!mounted) return;

      showCustomSnackBar(
        context: context,
        snackType: SnackType.error,
        message: 'Failed to disconnect $sessionName. Please try again.',
      );
    }

    if (success) {
      if (!mounted) return;

      showCustomSnackBar(
        context: context,
        snackType: SnackType.success,
        message: '$sessionName disconnected successfully.',
      );

      _loadSessions();
    }

    setState(() {
      _loadingSessionTopic = null;
    });
  }

  void _disconnectAllSessions() async {
    setState(() {
      _isClearingAccountSessions = true;
    });
    final storageService = ref.read(storageProvider);
    final walletConnectManager = WalletConnectManager(storageService);
    await walletConnectManager.disconnectAllSessions();

    if (!mounted) return;
    showCustomSnackBar(
      context: context,
      snackType: SnackType.success,
      message: 'All sessions disconnected successfully.',
    );

    setState(() {
      _isClearingAccountSessions = false;
    });

    _loadSessions();
  }

  Future<void> _confirmDisconnect(
      String message, VoidCallback onConfirm) async {
    final bool confirm = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return ConfirmationDialog(
              yesText: 'Disconnect',
              noText: 'Cancel',
              content: message,
            );
          },
        ) ??
        false;

    if (confirm) {
      onConfirm();
    }
  }

  Future<void> _disconnectSessionsForAccount(String publicKey) async {
    setState(() {
      _isClearingAccountSessions = true;
    });
    final storageService = ref.read(storageProvider);
    final walletConnectManager = WalletConnectManager(storageService);
    await walletConnectManager.disconnectAllSessionsForAccount(publicKey);

    if (!mounted) return;
    showCustomSnackBar(
      context: context,
      snackType: SnackType.success,
      message: 'All sessions for $publicKey disconnected successfully.',
    );

    setState(() {
      _isClearingAccountSessions = false;
    });
    _loadSessions();
  }

  @override
  Widget build(BuildContext context) {
    final accountsState = ref.watch(accountsListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(SessionsScreen.title),
        actions: [
          FutureBuilder<List<SessionData>>(
            future: _sessionsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container();
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Container();
              }

              return _isClearingAccountSessions
                  ? const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : IconButton(
                      icon: const Icon(AppIcons.disconnect),
                      onPressed: () => _confirmDisconnect(
                        'Disconnect all sessions?',
                        _disconnectAllSessions,
                      ),
                      color: context.colorScheme.error,
                      tooltip: 'Disconnect All Sessions?',
                    );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<SessionData>>(
        future: _sessionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            debugPrint('No active sessions found.');
            return const Center(child: Text('No active sessions.'));
          }

          final sessions = snapshot.data!;
          debugPrint('Active sessions found: ${sessions.length}');

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
              const SizedBox(height: 20),
              Expanded(
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
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            EllipsizedText(
                              session.peer.metadata.url,
                              style: context.textTheme.bodyMedium,
                            ),
                            EllipsizedText(
                                'Expires: ${DateFormat.yMMMd().add_Hms().format(DateTime.fromMillisecondsSinceEpoch(session.expiry * 1000))}',
                                style: context.textTheme.bodySmall),
                          ],
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
                                  : () => _confirmDisconnect(
                                        'Disconnect all sessions for this account?',
                                        () => _disconnectSessionsForAccount(
                                            publicKey),
                                      ),
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
                            isThreeLine: true,
                            title: EllipsizedText(
                              session.peer.metadata.name,
                              style: context.textTheme.titleMedium,
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                EllipsizedText(
                                  session.peer.metadata.url,
                                  style: context.textTheme.bodyMedium,
                                ),
                                Text(
                                  'Expires: ${DateFormat.yMMMd().add_Hms().format(DateTime.fromMillisecondsSinceEpoch(session.expiry * 1000))}',
                                  style: context.textTheme.bodySmall?.copyWith(
                                    color: context.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
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
            GoRouter.of(context).push('/qrScanner', extra: ScanMode.session),
        backgroundColor: context.colorScheme.secondary,
        foregroundColor: Colors.white,
        child: const Icon(AppIcons.scan),
      ),
    );
  }
}
