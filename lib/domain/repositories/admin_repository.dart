import '../entities/admin_dashboard_summary.dart';
import '../entities/category.dart';
import '../entities/order_request.dart';
import '../entities/paginated.dart';
import '../entities/plant.dart';
import '../enums/order_request_status.dart';
import '../enums/plant_enums.dart';
import 'catalogue_repository.dart';

/// Create or update a category. For updates, null fields are left unchanged; to
/// make a subcategory top-level, set [clearParent].
class CategoryInput {
  const CategoryInput({
    this.name,
    this.description,
    this.parentId,
    this.clearParent = false,
    this.sortOrder,
    this.isActive,
  });

  final String? name;
  final String? description;
  final String? parentId;
  final bool clearParent;
  final int? sortOrder;
  final bool? isActive;
}

/// Create or update a plant. For updates, null fields are left unchanged.
/// Changing [categoryId] requires [subcategoryId] or [clearSubcategory].
/// [attributes], when given, replaces all attributes.
class PlantInput {
  const PlantInput({
    this.name,
    this.description,
    this.categoryId,
    this.subcategoryId,
    this.clearSubcategory = false,
    this.pricePaise,
    this.priceUnit,
    this.minOrderQty,
    this.availability,
    this.attributes,
    this.isActive,
  });

  final String? name;
  final String? description;
  final String? categoryId;
  final String? subcategoryId;
  final bool clearSubcategory;
  final int? pricePaise;
  final PriceUnit? priceUnit;
  final int? minOrderQty;
  final Availability? availability;
  final PlantAttributes? attributes;

  /// Only used when creating; use [AdminRepository.setPlantActive] afterwards.
  final bool? isActive;
}

/// An image file picked on the device, ready to upload.
class ImageUpload {
  const ImageUpload({required this.path, required this.fileName, required this.mimeType});

  final String path;
  final String fileName;

  /// `image/jpeg`, `image/png` or `image/webp`.
  final String mimeType;
}

class AdminPlantQuery {
  const AdminPlantQuery({
    this.filters = const PlantQuery(),
    this.isActive,
    this.includeDeleted = false,
  });

  final PlantQuery filters;
  final bool? isActive;
  final bool includeDeleted;
}

class AdminCategoryQuery {
  const AdminCategoryQuery({
    this.page = 1,
    this.limit = 100,
    this.parentId,
    this.topLevelOnly = false,
    this.isActive,
    this.search,
    this.includeDeleted = false,
  });

  final int page;
  final int limit;
  final String? parentId;
  final bool topLevelOnly;
  final bool? isActive;
  final String? search;
  final bool includeDeleted;
}

/// Everything an admin manages. Requires an admin session; throws `AppFailure` on error.
abstract interface class AdminRepository {
  // Dashboard
  Future<AdminDashboardSummary> getDashboardSummary();

  // Categories
  Future<Paginated<Category>> getCategories(AdminCategoryQuery query);
  Future<Category> getCategory(String id);
  Future<Category> createCategory(CategoryInput input);
  Future<Category> updateCategory(String id, CategoryInput input);
  Future<void> deleteCategory(String id);

  // Plants
  Future<Paginated<Plant>> getPlants(AdminPlantQuery query);
  Future<Plant> getPlant(String id);
  Future<Plant> createPlant(PlantInput input);
  Future<Plant> updatePlant(String id, PlantInput input);
  Future<Plant> setPlantActive(String id, {required bool isActive});
  Future<void> deletePlant(String id);

  // Plant images (uploaded through the backend, which stores them in Cloudinary)
  Future<Plant> uploadPlantImages(String plantId, List<ImageUpload> images);
  Future<Plant> removePlantImage(String plantId, String imageId);

  /// Every image id of the plant in the new order; the first becomes the main image.
  Future<Plant> reorderPlantImages(String plantId, List<String> imageIds);

  // Order Requests
  Future<Paginated<OrderRequestSummary>> getOrderRequests({
    int page = 1,
    int limit = 20,
    OrderRequestStatus? status,
    String? search,
  });
  Future<OrderRequest> getOrderRequest(String id);

  /// [note] is required when cancelling an accepted request.
  Future<OrderRequest> updateOrderRequestStatus(
    String id,
    OrderRequestStatus status, {
    String? note,
  });

  /// Internal notes, never shown to customers. Null clears them.
  Future<OrderRequest> updateAdminNotes(String id, String? adminNotes);
}
