class Contact {
  final String id;
  String name;
  final String publicKey;
  DateTime? lastUsedDate;

  Contact({
    required this.id,
    required this.name,
    required this.publicKey,
    this.lastUsedDate,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'],
      name: json['name'],
      publicKey: json['publicKey'],
      lastUsedDate: json['lastUsedDate'] != null
          ? DateTime.parse(json['lastUsedDate'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'publicKey': publicKey,
      'lastUsedDate': lastUsedDate?.toIso8601String(),
    };
  }
}
