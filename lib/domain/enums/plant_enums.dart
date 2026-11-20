T _fromApi<T extends Enum>(
  List<T> values,
  String Function(T) apiValue,
  String value,
  String what,
) => values.firstWhere(
  (item) => apiValue(item) == value,
  orElse: () => throw FormatException('Unknown $what: $value'),
);

enum Availability {
  inStock('in_stock', 'In stock'),
  limited('limited', 'Limited stock'),
  outOfStock('out_of_stock', 'Unavailable');

  const Availability(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static Availability fromApi(String value) =>
      _fromApi(values, (a) => a.apiValue, value, 'availability');

  /// Out-of-stock plants stay visible and can still be added to an Order Request.
  bool get isUnavailable => this == outOfStock;
}

enum PriceUnit {
  perPlant('per_plant', 'per plant'),
  perPot('per_pot', 'per pot'),
  perBag('per_bag', 'per bag'),
  perDozen('per_dozen', 'per dozen');

  const PriceUnit(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static PriceUnit fromApi(String value) =>
      _fromApi(values, (u) => u.apiValue, value, 'price unit');
}

enum Sunlight {
  fullSun('full_sun', 'Full sun'),
  partialShade('partial_shade', 'Partial shade'),
  fullShade('full_shade', 'Full shade'),
  indirectLight('indirect_light', 'Indirect light');

  const Sunlight(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static Sunlight fromApi(String value) => _fromApi(values, (s) => s.apiValue, value, 'sunlight');
}

enum HeightUnit {
  cm('cm'),
  inch('in'),
  ft('ft');

  const HeightUnit(this.apiValue);

  final String apiValue;

  static HeightUnit fromApi(String value) =>
      _fromApi(values, (h) => h.apiValue, value, 'height unit');
}

/// Sort options supported by the plant list endpoints.
enum PlantSort {
  newest('-createdAt', 'Newest'),
  oldest('createdAt', 'Oldest'),
  priceLowToHigh('price', 'Price: low to high'),
  priceHighToLow('-price', 'Price: high to low'),
  nameAToZ('name', 'Name: A to Z'),
  nameZToA('-name', 'Name: Z to A');

  const PlantSort(this.apiValue, this.label);

  final String apiValue;
  final String label;
}
