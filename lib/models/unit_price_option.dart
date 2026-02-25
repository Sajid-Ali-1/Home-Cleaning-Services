import 'package:uuid/uuid.dart';

class UnitPriceOption {
  UnitPriceOption({
    String? optionId,
    required this.name,
    required this.pricePerUnit,
    required this.unitName,
    this.unitShortLabel,
    this.minQuantity = 1,
    this.maxQuantity,
    this.quantityStep = 1,
    this.allowDecimal = true,
    this.description,
  }) : optionId = optionId ?? const Uuid().v4();

  final String optionId;
  final String name;
  final double pricePerUnit;
  final String unitName;
  final String? unitShortLabel;
  final double minQuantity;
  final double? maxQuantity;
  final double quantityStep;
  final bool allowDecimal;
  final String? description;

  String get unitDisplay => unitShortLabel ?? unitName;

  UnitPriceOption copyWith({
    String? optionId,
    String? name,
    double? pricePerUnit,
    String? unitName,
    String? unitShortLabel,
    double? minQuantity,
    double? maxQuantity,
    double? quantityStep,
    bool? allowDecimal,
    String? description,
  }) {
    return UnitPriceOption(
      optionId: optionId ?? this.optionId,
      name: name ?? this.name,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      unitName: unitName ?? this.unitName,
      unitShortLabel: unitShortLabel ?? this.unitShortLabel,
      minQuantity: minQuantity ?? this.minQuantity,
      maxQuantity: maxQuantity ?? this.maxQuantity,
      quantityStep: quantityStep ?? this.quantityStep,
      allowDecimal: allowDecimal ?? this.allowDecimal,
      description: description ?? this.description,
    );
  }

  double calculateTotal(double quantity) {
    return pricePerUnit * quantity;
  }

  Map<String, dynamic> toMap() {
    return {
      'optionId': optionId,
      'name': name,
      'pricePerUnit': pricePerUnit,
      'unitName': unitName,
      'unitShortLabel': unitShortLabel,
      'minQuantity': minQuantity,
      'maxQuantity': maxQuantity,
      'quantityStep': quantityStep,
      'allowDecimal': allowDecimal,
      'description': description,
    };
  }

  factory UnitPriceOption.fromMap(Map<String, dynamic> map) {
    final bool isLegacy = map.containsKey('duration') &&
        !map.containsKey('unitName') &&
        !map.containsKey('pricePerUnit');
    if (isLegacy) {
      final duration =
          (map['duration'] as num?)?.toDouble() ?? (map['minQuantity'] ?? 1.0);
      final price = (map['price'] as num?)?.toDouble() ?? 0.0;
      final effectiveDuration = duration <= 0 ? 1 : duration;
      final perUnitPrice = effectiveDuration > 0
          ? price / effectiveDuration
          : (map['pricePerUnit'] as num?)?.toDouble() ?? 0.0;
      return UnitPriceOption(
        optionId: map['optionId'] as String? ?? map['id'] as String? ?? '',
        name: map['label'] as String? ?? 'Option',
        pricePerUnit: perUnitPrice,
        unitName: 'hour',
        unitShortLabel: 'hr',
        minQuantity: effectiveDuration,
        quantityStep: 1,
        allowDecimal: false,
      );
    }

    return UnitPriceOption(
      optionId: map['optionId'] as String? ?? map['id'] as String? ?? '',
      name: map['name'] as String? ??
          map['label'] as String? ??
          map['title'] as String? ??
          'Option',
      pricePerUnit: (map['pricePerUnit'] as num?)?.toDouble() ??
          (map['price'] as num?)?.toDouble() ??
          0.0,
      unitName:
          map['unitName'] as String? ?? map['unit'] as String? ?? 'unit',
      unitShortLabel: map['unitShortLabel'] as String? ??
          map['unitAbbreviation'] as String?,
      minQuantity: (map['minQuantity'] as num?)?.toDouble() ??
          (map['minimum'] as num?)?.toDouble() ??
          1.0,
      maxQuantity: (map['maxQuantity'] as num?)?.toDouble(),
      quantityStep: (map['quantityStep'] as num?)?.toDouble() ?? 1.0,
      allowDecimal: map['allowDecimal'] as bool? ?? true,
      description: map['description'] as String?,
    );
  }

  static List<UnitPriceOption> fromList(List<dynamic>? list) {
    if (list == null) return [];
    return list
        .map(
          (item) => UnitPriceOption.fromMap(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
  }

  static List<Map<String, dynamic>> toList(List<UnitPriceOption> options) {
    return options.map((option) => option.toMap()).toList();
  }
}

