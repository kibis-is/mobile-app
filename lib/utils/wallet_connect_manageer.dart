import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';
import 'package:flutter/foundation.dart';

class WalletConnectManager {
  late Web3Wallet _walletConnectClient;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (!_isInitialized) {
      const projectId = kReleaseMode
          ? '86eaff455340651e0ee12c8572c2d228'
          : '0451c3741ac5a5eba94c213ee1073cb1';

      _walletConnectClient = await Web3Wallet.createInstance(
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
      await initialize(); // Attempt to initialize if not already initialized
    }
    return await _walletConnectClient.pair(uri: uri);
  }

  /// Listen for session proposals and prompt the user to select an account.
  Future<void> listenForSessionProposals(
      Future<String?> Function(SessionProposalEvent) onSessionProposal) async {
    if (!_isInitialized) {
      await initialize(); // Ensure initialization before listening
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
      // Extract required namespaces from the proposal
      final requiredNamespaces = proposal.params.requiredNamespaces;

      debugPrint('Approving session with ID: ${proposal.id}');
      debugPrint('Initial namespaces: $requiredNamespaces');

      // Create a map for the namespaces to approve the session
      final Map<String, Namespace> namespaces = {};

      // Loop through required namespaces and populate the namespaces map
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

      debugPrint('Session approved successfully!');

      final activeSessions = await getActiveSessions();
      debugPrint(
          'Total active sessions after approval: ${activeSessions.length}');
    } catch (e) {
      debugPrint('Failed to approve session: $e');
      throw Exception('Failed to approve session');
    }
  }

  /// Disconnect a single session by its topic
  Future<void> disconnectSession(String topic) async {
    if (!_isInitialized) {
      await initialize(); // Ensure initialization before disconnecting
    }

    try {
      await _walletConnectClient.disconnectSession(
        topic: topic,
        reason: const WalletConnectError(
          code: 0,
          message: "User disconnected the session",
        ),
      );
      debugPrint('Session $topic disconnected successfully.');
    } catch (e) {
      debugPrint('Failed to disconnect session $topic: $e');
      throw Exception('Failed to disconnect session');
    }
  }

  /// Disconnect all active sessions
  Future<void> disconnectAllSessions() async {
    if (!_isInitialized) {
      await initialize(); // Ensure initialization before disconnecting
    }

    final sessions = await getActiveSessions();
    for (var session in sessions) {
      await disconnectSession(session.topic);
    }

    debugPrint('All sessions disconnected successfully.');
  }

  /// Disconnect all sessions associated with a specific account
  Future<void> disconnectAllSessionsForAccount(String publicKey) async {
    if (!_isInitialized) {
      await initialize(); // Ensure initialization before disconnecting
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

  Web3Wallet get client => _walletConnectClient;

  bool get isInitialized => _isInitialized;

  void reset() {
    _isInitialized = false;
    debugPrint('WalletConnect reset');
  }
}
