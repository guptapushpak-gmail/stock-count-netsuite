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
  final String memo;
  final int skuCount;    // distinct SKUs scanned
  final int totalQty;    // sum of all quantities

  const CountSession({
    required this.id,
    required this.locationId,
    required this.locationName,
    required this.status,
    required this.createdAt,
    this.memo = '',
    this.skuCount = 0,
    this.totalQty = 0,
  });

  CountSession copyWith({int? skuCount, int? totalQty, String? status}) => CountSession(
        id: id,
        locationId: locationId,
        locationName: locationName,
        status: status ?? this.status,
        createdAt: createdAt,
        memo: memo,
        skuCount: skuCount ?? this.skuCount,
        totalQty: totalQty ?? this.totalQty,
      );
}

class LotSerialAssignment {
  final String number;
  final int qty;
  const LotSerialAssignment({required this.number, required this.qty});

  Map<String, dynamic> toJson() => {'number': number, 'qty': qty};

  factory LotSerialAssignment.fromJson(Map<String, dynamic> json) =>
      LotSerialAssignment(
        number: json['number'] as String,
        qty: json['qty'] as int,
      );
}

class InventoryItemModel {
  final String id;
  final String name;
  final String upc;
  final bool isLotItem;
  final bool isSerialItem;

  const InventoryItemModel({
    required this.id,
    required this.name,
    required this.upc,
    this.isLotItem = false,
    this.isSerialItem = false,
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
  final bool isLotItem;
  final bool isSerialItem;
  final List<LotSerialAssignment> lotSerialAssignments;

  const ScannedItem({
    required this.itemId,
    required this.upc,
    required this.name,
    required this.qty,
    this.isLotItem = false,
    this.isSerialItem = false,
    this.lotSerialAssignments = const [],
  });

  bool get needsLotSerialDetail =>
      (isLotItem || isSerialItem) && lotSerialAssignments.isEmpty;

  ScannedItem copyWith({
    int? qty,
    List<LotSerialAssignment>? lotSerialAssignments,
  }) =>
      ScannedItem(
        itemId: itemId,
        upc: upc,
        name: name,
        qty: qty ?? this.qty,
        isLotItem: isLotItem,
        isSerialItem: isSerialItem,
        lotSerialAssignments: lotSerialAssignments ?? this.lotSerialAssignments,
      );

  static String? encodeLotSerial(List<LotSerialAssignment> assignments) {
    if (assignments.isEmpty) return null;
    return '[${assignments.map((a) => '{"number":"${a.number}","qty":${a.qty}}').join(',')}]';
  }

  static List<LotSerialAssignment> decodeLotSerial(String? data) {
    if (data == null || data.isEmpty) return const [];
    try {
      // Simple JSON parse without dart:convert dependency
      final cleaned = data.trim();
      if (!cleaned.startsWith('[')) return const [];
      final inner = cleaned.substring(1, cleaned.length - 1).trim();
      if (inner.isEmpty) return const [];
      final result = <LotSerialAssignment>[];
      // Split by },{
      final entries = inner.split('},{');
      for (final entry in entries) {
        final clean = entry.replaceAll('{', '').replaceAll('}', '');
        String? number;
        int? qty;
        for (final part in clean.split(',')) {
          final kv = part.split(':');
          if (kv.length < 2) continue;
          final key = kv[0].replaceAll('"', '').trim();
          final val = kv.sublist(1).join(':').replaceAll('"', '').trim();
          if (key == 'number') number = val;
          if (key == 'qty') qty = int.tryParse(val);
        }
        if (number != null && qty != null) {
          result.add(LotSerialAssignment(number: number, qty: qty));
        }
      }
      return result;
    } catch (_) {
      return const [];
    }
  }
}
