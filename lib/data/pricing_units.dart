import 'package:home_cleaning_app/models/service_model.dart';

class PricingUnitPreset {
  const PricingUnitPreset({
    required this.id,
    required this.label,
    required this.shortLabel,
    this.allowDecimal = true,
    this.defaultStep = 1,
    this.allowedCategories = const {ServiceCategory.cleaning, ServiceCategory.landscaping},
  });

  final String id;
  final String label;
  final String shortLabel;
  final bool allowDecimal;
  final double defaultStep;
  final Set<ServiceCategory> allowedCategories;

  bool supports(ServiceCategory? category) {
    if (category == null) return true;
    return allowedCategories.contains(category);
  }

  static final PricingUnitPreset customPreset = PricingUnitPreset(
    id: 'custom',
    label: 'Custom unit',
    shortLabel: 'custom',
    allowedCategories: const {
      ServiceCategory.cleaning,
      ServiceCategory.landscaping,
    },
  );

  static final List<PricingUnitPreset> presets = [
    PricingUnitPreset(
      id: 'hour',
      label: 'Hour',
      shortLabel: 'hour',
      allowDecimal: false,
      defaultStep: 1,
      allowedCategories: const {ServiceCategory.cleaning},
    ),
    PricingUnitPreset(
      id: 'room',
      label: 'Room',
      shortLabel: 'room',
      allowDecimal: false,
      allowedCategories: const {ServiceCategory.cleaning},
    ),
    PricingUnitPreset(
      id: 'bathroom',
      label: 'Bathroom',
      shortLabel: 'bath',
      allowDecimal: false,
      allowedCategories: const {ServiceCategory.cleaning},
    ),
    PricingUnitPreset(
      id: 'sqft',
      label: 'Square Feet',
      shortLabel: 'sq ft',
      allowedCategories: const {
        ServiceCategory.cleaning,
        ServiceCategory.landscaping,
      },
    ),
    PricingUnitPreset(
      id: 'sqm',
      label: 'Square Meter',
      shortLabel: 'sq m',
      allowedCategories: const {
        ServiceCategory.cleaning,
        ServiceCategory.landscaping,
      },
    ),
    PricingUnitPreset(
      id: 'acre',
      label: 'Acre',
      shortLabel: 'acre',
      allowDecimal: false,
      allowedCategories: const {ServiceCategory.landscaping},
    ),
    PricingUnitPreset(
      id: 'yard',
      label: 'Yard',
      shortLabel: 'yard',
      allowDecimal: false,
      allowedCategories: const {ServiceCategory.landscaping},
    ),
    PricingUnitPreset(
      id: 'tree',
      label: 'Tree',
      shortLabel: 'tree',
      allowDecimal: false,
      allowedCategories: const {ServiceCategory.landscaping},
    ),
    PricingUnitPreset(
      id: 'session',
      label: 'Session/Visit',
      shortLabel: 'session',
      allowDecimal: false,
      allowedCategories: const {ServiceCategory.landscaping},
    ),
    PricingUnitPreset(
      id: 'custom',
      label: 'Custom unit',
      shortLabel: 'custom',
      allowedCategories: const {
        ServiceCategory.cleaning,
        ServiceCategory.landscaping,
      },
    ),
  ];

  static PricingUnitPreset findById(String id) {
    return presets.firstWhere(
      (preset) => preset.id == id,
      orElse: () => customPreset,
    );
  }

  static List<PricingUnitPreset> presetsFor(ServiceCategory? category) {
    if (category == null) return presets;
    return presets.where((preset) => preset.supports(category)).toList();
  }
}

