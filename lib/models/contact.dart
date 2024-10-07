class Contact {
  final String id;
  final String name;
  final String publicKey;

  Contact({
    required this.id,
    required this.name,
    required this.publicKey,
  });

  factory Contact.fromJson(Map<String, dynamic> json) => Contact(
        id: json['id'],
        name: json['name'],
        publicKey: json['publicKey'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'publicKey': publicKey,
      };
}
