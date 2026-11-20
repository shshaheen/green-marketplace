import '../entities/category.dart';
import '../entities/paginated.dart';
import '../entities/plant.dart';
import '../enums/plant_enums.dart';

/// Filters for plant lists. Prices are in paise.
class PlantQuery {
  const PlantQuery({
    this.page = 1,
    this.limit = 20,
    this.search,
    this.categoryId,
    this.subcategoryId,
    this.availability,
    this.minPricePaise,
    this.maxPricePaise,
    this.sort = PlantSort.newest,
  });

  final int page;
  final int limit;
  final String? search;
  final String? categoryId;
  final String? subcategoryId;
  final Availability? availability;
  final int? minPricePaise;
  final int? maxPricePaise;
  final PlantSort sort;

  PlantQuery copyWith({
    int? page,
    String? Function()? search,
    String? Function()? categoryId,
    String? Function()? subcategoryId,
    Availability? Function()? availability,
    int? Function()? minPricePaise,
    int? Function()? maxPricePaise,
    PlantSort? sort,
  }) => PlantQuery(
    page: page ?? this.page,
    limit: limit,
    search: search != null ? search() : this.search,
    categoryId: categoryId != null ? categoryId() : this.categoryId,
    subcategoryId: subcategoryId != null ? subcategoryId() : this.subcategoryId,
    availability: availability != null ? availability() : this.availability,
    minPricePaise: minPricePaise != null ? minPricePaise() : this.minPricePaise,
    maxPricePaise: maxPricePaise != null ? maxPricePaise() : this.maxPricePaise,
    sort: sort ?? this.sort,
  );

  @override
  bool operator ==(Object other) =>
      other is PlantQuery &&
      other.page == page &&
      other.limit == limit &&
      other.search == search &&
      other.categoryId == categoryId &&
      other.subcategoryId == subcategoryId &&
      other.availability == availability &&
      other.minPricePaise == minPricePaise &&
      other.maxPricePaise == maxPricePaise &&
      other.sort == sort;

  @override
  int get hashCode => Object.hash(
    page,
    limit,
    search,
    categoryId,
    subcategoryId,
    availability,
    minPricePaise,
    maxPricePaise,
    sort,
  );
}

/// Public catalogue, available without login. Throws `AppFailure` on error.
abstract interface class CatalogueRepository {
  /// Active categories, each with its active subcategories.
  Future<List<Category>> getCategoryTree();

  Future<Paginated<Plant>> getPlants(PlantQuery query);

  Future<Plant> getPlant(String idOrSlug);
}
