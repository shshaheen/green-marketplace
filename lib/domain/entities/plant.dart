import '../enums/plant_enums.dart';
import 'money.dart';

/// Minimal reference to a category, as embedded in a plant.
class CategoryRef {
  const CategoryRef({required this.id, required this.name, this.slug});

  final String id;
  final String name;
  final String? slug;

  @override
  bool operator ==(Object other) => other is CategoryRef && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

class PlantImage {
  const PlantImage({required this.id, required this.url, this.width, this.height});

  final String id;
  final String url;
  final int? width;
  final int? height;
}

class HeightRange {
  const HeightRange({required this.min, required this.max, required this.unit});

  final double min;
  final double max;
  final HeightUnit unit;
}

class PlantAttributes {
  const PlantAttributes({this.height, this.sunlight, this.watering});

  static const PlantAttributes empty = PlantAttributes();

  final HeightRange? height;
  final Sunlight? sunlight;
  final String? watering;

  bool get isEmpty => height == null && sunlight == null && watering == null;
}

/// A plant in the catalogue. List responses carry only the main [image];
/// detail responses also carry [description], [images] and [attributes].
/// Admin responses add [isActive] and [deletedAt].
class Plant {
  const Plant({
    required this.id,
    required this.name,
    required this.slug,
    required this.price,
    required this.priceUnit,
    required this.minOrderQty,
    required this.availability,
    this.image,
    this.category,
    this.subcategory,
    this.description,
    this.images = const [],
    this.attributes = PlantAttributes.empty,
    this.isActive,
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String slug;

  /// Indicative price only; the final price is agreed offline.
  final Money price;
  final PriceUnit priceUnit;
  final int minOrderQty;
  final Availability availability;
  final PlantImage? image;
  final CategoryRef? category;
  final CategoryRef? subcategory;
  final String? description;
  final List<PlantImage> images;
  final PlantAttributes attributes;

  // Admin-only fields.
  final bool? isActive;
  final DateTime? deletedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  String? get mainImageUrl => image?.url ?? (images.isEmpty ? null : images.first.url);
}
