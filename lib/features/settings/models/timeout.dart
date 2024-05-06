class Timeout {
  final String name;
  final int time;
  final String icon;

  Timeout({required this.name, required this.time, required this.icon});

  static List<Timeout> timeoutList = [
    Timeout(name: '1 minute', time: 1, icon: '0xe3af'),
    Timeout(name: '5 minutes', time: 5, icon: '0xe3af'),
    Timeout(name: '10 minutes', time: 10, icon: '0xe3af'),
    Timeout(name: '15 minutes', time: 15, icon: '0xe3af'),
    Timeout(name: '30 minutes', time: 30, icon: '0xe3af'),
  ];
}
