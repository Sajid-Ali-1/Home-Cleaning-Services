import 'package:home_cleaning_app/models/unit_price_option.dart';

class SelectedPricingOption {
  SelectedPricingOption({required this.option, required this.quantity});

  final UnitPriceOption option;
  final double quantity;

  double get total => option.calculateTotal(quantity);
}
