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
    } else {
      debugPrint('WalletConnect already initialized');
    }
  }

  Future<PairingInfo> pair(Uri uri) async {
    if (!_isInitialized) {
      await initialize(); // Attempt to initialize if not already initialized
    }
    debugPrint('Pairing with URI: $uri');
    final pairingInfo = await _walletConnectClient.pair(uri: uri);
    debugPrint('Pairing successful: ${pairingInfo.topic}');
    return pairingInfo;
  }

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
      final requiredNamespaces = proposal.params.requiredNamespaces;
      debugPrint('Required namespaces: $requiredNamespaces');

      final Map<String, Namespace> namespaces = {};
      requiredNamespaces.forEach((key, value) {
        final formattedAccount = '${value.chains?.first}:$selectedAccount';
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
    } catch (e) {
      debugPrint('Failed to approve session: $e');
      throw Exception('Failed to approve session');
    }
  }

  Future<List<SessionData>> getActiveSessions() async {
    if (!_isInitialized) {
      await initialize(); // Attempt to initialize if not already initialized
    }

    final activeSessionsMap = _walletConnectClient.getActiveSessions();
    debugPrint('Active sessions retrieved: ${activeSessionsMap.length}');
    return activeSessionsMap.values.toList();
  }

  Future<void> disconnectSession(String topic) async {
    if (!_isInitialized) {
      await initialize(); // Attempt to initialize if not already initialized
    }

    try {
      await _walletConnectClient.disconnectSession(
        topic: topic,
        reason: const WalletConnectError(
          code: 0,
          message: "User disconnected the session",
        ),
      );
      debugPrint('Session disconnected: $topic');
    } catch (e) {
      debugPrint('Failed to disconnect session: $e');
    }
  }

  Web3Wallet get client => _walletConnectClient;

  bool get isInitialized => _isInitialized;

  void reset() {
    _isInitialized = false;
    debugPrint('WalletConnect reset');
  }
}
