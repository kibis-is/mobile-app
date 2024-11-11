import 'package:kibisis/generated/l10n.dart';
import 'package:kibisis/providers/storage_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:reown_walletkit/reown_walletkit.dart';

class WalletConnectManager {
  late ReownWalletKit _walletConnectClient;
  bool _isInitialized = false;
  final StorageService _storageService;

  WalletConnectManager(this._storageService);

  Future<void> initialize() async {
    if (!_isInitialized) {
      const projectId = kReleaseMode
          ? '86eaff455340651e0ee12c8572c2d228'
          : '0451c3741ac5a5eba94c213ee1073cb1';

      _walletConnectClient = await ReownWalletKit.createInstance(
        projectId: projectId,
        relayUrl: 'wss://relay.walletconnect.com',
        metadata: const PairingMetadata(
          name: 'Kibisis Mobile',
          description: 'A wallet that can be requested to sign transactions',
          url: 'https://kibis.is',
          icons: ['https://yourapp.com/icon.png'],
          redirect: Redirect(
            native: 'mywallet://',
            universal: 'https://mywallet.com/app',
          ),
        ),
      );
      _isInitialized = true;
      debugPrint(
          'WalletConnect initialized in ${kReleaseMode ? 'release' : 'development'} mode');
    }
  }

  Future<PairingInfo> pair(Uri uri) async {
    if (!_isInitialized) {
      await initialize();
    }
    return await _walletConnectClient.pair(uri: uri);
  }

  Future<void> listenForSessionProposals(
      Future<String?> Function(SessionProposalEvent) onSessionProposal) async {
    if (!_isInitialized) {
      await initialize();
    }

    debugPrint('Listening for session proposals...');

    _walletConnectClient.onSessionProposal.subscribe(
      (SessionProposalEvent? proposal) async {
        if (proposal != null) {
          debugPrint(
              'Session proposal received: ${proposal.params.proposer.metadata.name}');
          String? selectedAccount = await onSessionProposal(proposal);
          if (selectedAccount != null) {
            await approveSession(proposal, selectedAccount);
          } else {
            debugPrint('User canceled the WalletConnect process.');
          }
        }
      },
    );
  }

  Future<void> approveSession(
      SessionProposalEvent proposal, String selectedAccount) async {
    try {
      final requiredNamespaces = proposal.params.requiredNamespaces;

      debugPrint('Approving session with ID: ${proposal.id}');
      debugPrint('Initial namespaces: $requiredNamespaces');

      final Map<String, Namespace> namespaces = {};

      requiredNamespaces.forEach((key, value) {
        final formattedAccount = '${value.chains?.first}:$selectedAccount';
        debugPrint('Formatted account: $formattedAccount');

        namespaces[key] = Namespace(
          accounts: [formattedAccount],
          methods: value.methods,
          events: value.events,
        );
      });

      debugPrint('Namespaces being approved: $namespaces');

      await _walletConnectClient.approveSession(
        id: proposal.id,
        namespaces: namespaces,
      );

      await _saveSession(proposal.id);

      debugPrint('Session approved successfully!');
    } catch (e) {
      debugPrint('Failed to approve session: $e');
      throw Exception(S.current.failedToApproveSession);
    }
  }

  Future<void> disconnectSession(String topic) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      await _walletConnectClient.disconnectSession(
        topic: topic,
        reason: const ReownSignError(
          code: 0,
          message: "User disconnected the session",
        ),
      );

      await _removeSessionByTopic(topic);

      debugPrint('Session $topic disconnected successfully.');
    } catch (e) {
      debugPrint('Failed to disconnect session $topic: $e');
      throw Exception(S.current.failedToDisconnectSession);
    }
  }

  Future<void> disconnectAllSessions() async {
    if (!_isInitialized) {
      await initialize();
    }

    final sessions = await getActiveSessions();
    for (var session in sessions) {
      await disconnectSession(session.topic);
    }

    debugPrint('All sessions disconnected successfully.');
  }

  Future<void> disconnectAllSessionsForAccount(String publicKey) async {
    if (!_isInitialized) {
      await initialize();
    }

    final sessions = await getActiveSessions();
    for (var session in sessions) {
      final accounts = session.namespaces.values.expand((ns) => ns.accounts);
      if (accounts.any((account) => account.endsWith(publicKey))) {
        await disconnectSession(session.topic);
      }
    }

    debugPrint(
        'All sessions for account $publicKey disconnected successfully.');
  }

  Future<List<SessionData>> getActiveSessions() async {
    if (!_isInitialized) {
      await initialize();
    }

    final activeSessionsMap = _walletConnectClient.getActiveSessions();
    final sessions = activeSessionsMap.values.toList();

    debugPrint('Total active sessions: ${sessions.length}');
    for (var session in sessions) {
      final accounts = session.namespaces.values.expand((ns) => ns.accounts);
      debugPrint('Session ${session.topic}: Accounts: $accounts');
    }

    return sessions;
  }

  Future<void> reconnectSessions() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      final sessions = await getActiveSessions();
      final currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      for (var session in sessions) {
        if (session.expiry < currentTime) {
          debugPrint(
              'Session ${session.topic} has expired. Handling expiration...');
          continue;
        }

        await _walletConnectClient.updateSession(
          topic: session.topic,
          namespaces: session.namespaces,
        );
        debugPrint('Reconnected to session: ${session.topic}');
      }
    } catch (e) {
      debugPrint('Failed to reconnect sessions: $e');
    }
  }

  Future<void> _saveSession(int id) async {
    try {
      final sessions = await getActiveSessions();
      final sessionData =
          sessions.firstWhere((session) => session.topic == id.toString());

      final sessionMap = {
        'topic': sessionData.topic,
        'expiry': sessionData.expiry,
        'namespaces': sessionData.namespaces,
      };

      await _storageService.saveSessions([sessionMap]);
      debugPrint('Session $id saved locally.');
    } catch (e) {
      debugPrint('Failed to save session $id: $e');
    }
  }

  Future<void> _removeSessionByTopic(String topic) async {
    try {
      await _storageService.removeSessionByTopic(topic);
      debugPrint('Session $topic removed from local storage.');
    } catch (e) {
      debugPrint('Failed to remove session $topic: $e');
    }
  }

  ReownWalletKit get client => _walletConnectClient;

  bool get isInitialized => _isInitialized;

  void reset() {
    _isInitialized = false;
    debugPrint('WalletConnect reset');
  }
}
