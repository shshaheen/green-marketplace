/// Why the customer needs the plants. Required on every Order Request.
enum IntendedUse {
  resort('resort', 'Resort'),
  farmhouse('farmhouse', 'Farmhouse'),
  home('home', 'Home decoration'),
  landscaping('landscaping', 'Landscaping'),
  garden('garden', 'Garden'),
  commercial('commercial', 'Commercial'),
  other('other', 'Other');

  const IntendedUse(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static IntendedUse fromApi(String value) => values.firstWhere(
    (use) => use.apiValue == value,
    orElse: () => throw FormatException('Unknown intended use: $value'),
  );
}
