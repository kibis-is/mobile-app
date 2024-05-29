class Timeout {
  final String name;
  final int time;
  final String icon;

  Timeout({required this.name, required this.time, required this.icon});

  static List<Timeout> timeoutList = [
    Timeout(name: '1 minute', time: 60, icon: '0xe3af'),
    Timeout(name: '5 minutes', time: 300, icon: '0xe3af'),
    Timeout(name: '10 minutes', time: 600, icon: '0xe3af'),
    Timeout(name: '15 minutes', time: 900, icon: '0xe3af'),
  ];
}
