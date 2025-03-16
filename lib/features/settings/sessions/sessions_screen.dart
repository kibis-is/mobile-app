import 'package:ellipsized_text/ellipsized_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kibisis/common_widgets/confirmation_dialog.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/generated/l10n.dart';
import 'package:kibisis/providers/fab_provider.dart';
import 'package:kibisis/providers/storage_provider.dart';
import 'package:kibisis/utils/app_icons.dart';
import 'package:kibisis/utils/theme_extensions.dart';
import 'package:kibisis/utils/wallet_connect_manageer.dart';
import 'package:kibisis/providers/accounts_list_provider.dart';
import 'package:kibisis/common_widgets/top_snack_bar.dart';
import 'package:reown_walletkit/reown_walletkit.dart';
import 'package:shimmer/shimmer.dart';

class SessionsScreen extends ConsumerStatefulWidget {
  static String title = S.current.sessions;
  const SessionsScreen({super.key});

  @override
  SessionsScreenState createState() => SessionsScreenState();
}

class SessionsScreenState extends ConsumerState<SessionsScreen> {
  late Future<List<SessionData>> _sessionsFuture;
  String? _loadingSessionTopic;
  final bool _isClearingAccountSessions = false;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  WalletConnectManager get _walletConnectManager {
    final storageService = ref.read(storageProvider);
    return WalletConnectManager(storageService);
  }

  void _loadSessions() {
    _sessionsFuture = _walletConnectManager.getActiveSessions();
    debugPrint('Fetching active sessions...');
  }

  Future<void> _disconnectSessionHandler(
      {required String topic,
      required String sessionName,
      required Future<void> Function() disconnectFunc}) async {
    setState(() {
      _loadingSessionTopic = topic;
    });

    bool success = false;

    try {
      await disconnectFunc();
      success = true;
    } catch (e) {
      debugPrint('Failed to disconnect session $topic: $e');
      if (!mounted) return;
      _showSnackBar(
          S.of(context).failedToDisconnect(sessionName), SnackType.error);
    }

    if (success) {
      if (mounted) {
        _showSnackBar(
            S.of(context).sessionDisconnected(sessionName), SnackType.success);
      }
      _loadSessions();
    }

    setState(() {
      _loadingSessionTopic = null;
    });
  }

  Future<void> _disconnectSession(String topic, String sessionName) async {
    await _disconnectSessionHandler(
      topic: topic,
      sessionName: sessionName,
      disconnectFunc: () => _walletConnectManager.disconnectSession(topic),
    );
  }

  void _disconnectAllSessions() async {
    await _disconnectSessionHandler(
      topic: 'all',
      sessionName: S.of(context).allSessions,
      disconnectFunc: _walletConnectManager.disconnectAllSessions,
    );
  }

  Future<void> _disconnectSessionsForAccount(String publicKey) async {
    await _disconnectSessionHandler(
      topic: publicKey,
      sessionName: S.of(context).allSessionsFor(publicKey),
      disconnectFunc: () =>
          _walletConnectManager.disconnectAllSessionsForAccount(publicKey),
    );
  }

  Future<void> _confirmDisconnect(
      String message, VoidCallback onConfirm) async {
    final bool confirm = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return ConfirmationDialog(
              yesText: S.of(context).disconnect,
              noText: S.of(context).cancel,
              content: message,
            );
          },
        ) ??
        false;

    if (confirm) {
      onConfirm();
    }
  }

  void _showSnackBar(String message, SnackType type) {
    if (!mounted) return;
    showCustomSnackBar(
      context: context,
      snackType: type,
      message: message,
    );
  }

  Widget _buildLoadingSessions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kScreenPadding / 2),
      child: Shimmer.fromColors(
        baseColor: context.colorScheme.background,
        highlightColor: context.colorScheme.onSurfaceVariant,
        period: const Duration(milliseconds: 2000),
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: kScreenPadding),
          itemCount: 3,
          itemBuilder: (_, __) => ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.colorScheme.surface,
              ),
            ),
            title: Container(
              width: double.infinity,
              height: kScreenPadding,
              color: context.colorScheme.surface,
            ),
            subtitle: Container(
              width: double.infinity,
              height: kScreenPadding / 2,
              color: context.colorScheme.surface,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accountsState = ref.watch(accountsListProvider);
    final fabPosition = ref.watch(fabPositionProvider);
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
                        S.of(context).disconnectAllSessionsPrompt,
                        _disconnectAllSessions,
                      ),
                      color: context.colorScheme.error,
                      tooltip: S.of(context).disconnectAllSessions,
                    );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<SessionData>>(
        future: _sessionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingSessions(context);
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            debugPrint('No active sessions found.');
            return Center(child: Text(S.of(context).noActiveSessions));
          }

          final sessions = snapshot.data!;
          debugPrint('Active sessions found: ${sessions.length}');

          final Map<String, List<SessionData>> accountSessions =
              _groupSessionsByAccount(sessions);

          final List<Map<String, String>> activeAccounts = accountsState
              .accounts
              .where((account) =>
                  accountSessions.containsKey(account['publicKey']))
              .toList();

          if (activeAccounts.isEmpty) {
            debugPrint('No active sessions for any accounts.');
            return Center(child: Text(S.of(context).noActiveSessions));
          }

          return _buildSessionsList(activeAccounts, accountSessions);
        },
      ),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        onPressed: () =>
            GoRouter.of(context).push('/qrScanner', extra: ScanMode.session),
        backgroundColor: context.colorScheme.secondary,
        foregroundColor: Colors.white,
        child: const Icon(AppIcons.scan),
      ),
      floatingActionButtonLocation: fabPosition == FabPosition.left
          ? FloatingActionButtonLocation.startFloat
          : FloatingActionButtonLocation.endFloat,
    );
  }

  Map<String, List<SessionData>> _groupSessionsByAccount(
      List<SessionData> sessions) {
    final Map<String, List<SessionData>> accountSessions = {};
    for (var session in sessions) {
      for (var namespace in session.namespaces.values) {
        for (var account in namespace.accounts) {
          final accountParts = account.split(':');
          final publicKey = accountParts.last;
          accountSessions.putIfAbsent(publicKey, () => []).add(session);
        }
      }
    }
    return accountSessions;
  }

  Widget _buildSessionsList(List<Map<String, String>> activeAccounts,
      Map<String, List<SessionData>> accountSessions) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: kScreenPadding),
            itemCount: activeAccounts.length,
            itemBuilder: (context, index) {
              final account = activeAccounts[index];
              final accountName =
                  account['accountName'] ?? S.of(context).unnamedAccount;
              final publicKey =
                  account['publicKey'] ?? S.of(context).noPublicKey;
              final sessionsForAccount = accountSessions[publicKey]!;

              return _buildAccountSessionTile(
                  accountName, publicKey, sessionsForAccount);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAccountSessionTile(String accountName, String publicKey,
      List<SessionData> sessionsForAccount) {
    return ExpansionTile(
      initiallyExpanded: true,
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
        ),
      ),
      collapsedIconColor: context.colorScheme.onSurface,
      iconColor: context.colorScheme.onSurface,
      childrenPadding: const EdgeInsets.only(
          bottom: kScreenPadding / 2,
          left: 0,
          right: kScreenPadding,
          top: kScreenPadding / 2),
      children: _buildSessionListItems(publicKey, sessionsForAccount),
    );
  }

  List<Widget> _buildSessionListItems(
      String publicKey, List<SessionData> sessionsForAccount) {
    return [
      if (sessionsForAccount.length > 1)
        TextButton(
          onPressed: _isClearingAccountSessions
              ? null
              : () => _confirmDisconnect(
                    S.of(context).disconnectAllSessionsForAccountPrompt,
                    () => _disconnectSessionsForAccount(publicKey),
                  ),
          child: Row(
            children: [
              Icon(
                AppIcons.disconnect,
                size: AppIcons.large,
                color: context.colorScheme.error,
              ),
              const SizedBox(width: kScreenPadding),
              Text(S.of(context).disconnectAll,
                  style: context.textTheme.titleSmall
                      ?.copyWith(color: context.colorScheme.error)),
            ],
          ),
        ),
      const SizedBox(height: kScreenPadding / 2),
      ...sessionsForAccount.map((session) {
        return _buildSessionTile(session);
      }),
    ];
  }

  Widget _buildSessionTile(SessionData session) {
    final isLoading = _loadingSessionTopic == session.topic;

    return ListTile(
      isThreeLine: true,
      title: EllipsizedText(
        session.peer.metadata.name,
        style: context.textTheme.titleMedium,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EllipsizedText(session.peer.metadata.url,
              style: context.textTheme.bodyMedium),
          Text(
            '${S.of(context).expires} ${DateFormat.yMMMd().add_Hms().format(DateTime.fromMillisecondsSinceEpoch(session.expiry * 1000))}',
            style: context.textTheme.labelMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      trailing: isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : IconButton(
              icon: Icon(AppIcons.disconnect,
                  size: AppIcons.large, color: context.colorScheme.error),
              onPressed: () =>
                  _disconnectSession(session.topic, session.peer.metadata.name),
            ),
    );
  }
}
