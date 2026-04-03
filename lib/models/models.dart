class LocationModel {
  final String id;
  final String name;
  final String? subsidiaryId;
  final String? subsidiaryName;

  const LocationModel({
    required this.id,
    required this.name,
    this.subsidiaryId,
    this.subsidiaryName,
  });

  static String _nameFromJson(Map<String, dynamic> json) {
    final candidates = [
      json['name'],
      json['locationname'],
      json['locationName'],
      json['fullName'],
      json['entityid'],
      json['altname'],
    ];

    for (final v in candidates) {
      if (v is String && v.trim().isNotEmpty) return v.trim();
      if (v is Map<String, dynamic>) {
        final text = (v['text'] ?? v['value'])?.toString();
        if (text != null && text.trim().isNotEmpty) return text.trim();
      }
    }

    final id = json['id']?.toString();
    if (id != null && id.isNotEmpty) return 'Location $id';
    return 'Unknown';
  }

  static String? _readRel(dynamic value) {
    if (value == null) return null;
    if (value is Map<String, dynamic>) {
      final v = (value['id'] ?? value['value'])?.toString();
      return (v == null || v.trim().isEmpty) ? null : v.trim();
    }
    final s = value.toString().trim();
    return s.isEmpty ? null : s;
  }

  factory LocationModel.fromJson(Map<String, dynamic> json) => LocationModel(
        id: json['id'].toString(),
        name: _nameFromJson(json),
        subsidiaryId: _readRel(json['subsidiary']),
        subsidiaryName: (json['subsidiaryName'] ?? '').toString().trim().isEmpty
            ? null
            : (json['subsidiaryName']).toString().trim(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'subsidiaryId': subsidiaryId,
        'subsidiaryName': subsidiaryName,
      };
}

class AdjustmentAccountModel {
  final String id;
  final String name;

  const AdjustmentAccountModel({required this.id, required this.name});
}

class CountSession {
  final String id;
  final String locationId;
  final String locationName;
  final String status; // in_progress/completed
  final DateTime createdAt;

  const CountSession({
    required this.id,
    required this.locationId,
    required this.locationName,
    required this.status,
    required this.createdAt,
  });
}

class InventoryItemModel {
  final String id;
  final String name;
  final String upc;

  const InventoryItemModel({
    required this.id,
    required this.name,
    required this.upc,
  });

  static String _readString(dynamic v) {
    if (v == null) return '';
    if (v is String) return v.trim();
    if (v is Map<String, dynamic>) {
      return (v['text'] ?? v['value'] ?? '').toString().trim();
    }
    return v.toString().trim();
  }

  factory InventoryItemModel.fromJson(Map<String, dynamic> json) {
    final id = _readString(json['id']);
    final nameCandidates = [
      json['itemId'],
      json['itemid'],
      json['displayName'],
      json['displayname'],
      json['salesDescription'],
      json['name'],
    ];
    final upcCandidates = [
      json['upcCode'],
      json['upccode'],
      json['upc'],
      json['ean'],
      json['ean13'],
      json['barcode'],
    ];

    String name = '';
    for (final c in nameCandidates) {
      name = _readString(c);
      if (name.isNotEmpty) break;
    }

    String upc = '';
    for (final c in upcCandidates) {
      upc = _readString(c);
      if (upc.isNotEmpty) break;
    }

    return InventoryItemModel(
      id: id,
      name: name.isEmpty ? 'Item $id' : name,
      upc: upc,
    );
  }
}

class ScannedItem {
  final String itemId;
  final String upc;
  final String name;
  final int qty;

  const ScannedItem({
    required this.itemId,
    required this.upc,
    required this.name,
    required this.qty,
  });

  ScannedItem copyWith({int? qty}) => ScannedItem(
        itemId: itemId,
        upc: upc,
        name: name,
        qty: qty ?? this.qty,
      );
}
