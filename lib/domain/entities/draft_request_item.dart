import '../enums/plant_enums.dart';
import 'money.dart';
import 'plant.dart';

/// Maximum quantity for one plant in an Order Request (mirrors the backend).
const int maxQuantityPerItem = 100000;

/// Maximum number of different plants in one Order Request (mirrors the backend).
const int maxItemsPerRequest = 50;

/// A plant the customer has selected but not yet submitted. Keeps enough plant
/// details to show the draft without refetching. Quantity is always kept within
/// [minOrderQty]…[maxQuantityPerItem].
class DraftRequestItem {
  DraftRequestItem({
    required this.plantId,
    required this.plantName,
    required this.price,
    required this.priceUnit,
    required this.minOrderQty,
    required this.availability,
    required int quantity,
    this.imageUrl,
  }) : quantity = clampQuantity(quantity, minOrderQty);

  /// Starts at the plant's minimum order quantity.
  factory DraftRequestItem.fromPlant(Plant plant, {int? quantity}) => DraftRequestItem(
    plantId: plant.id,
    plantName: plant.name,
    price: plant.price,
    priceUnit: plant.priceUnit,
    minOrderQty: plant.minOrderQty,
    availability: plant.availability,
    imageUrl: plant.mainImageUrl,
    quantity: quantity ?? plant.minOrderQty,
  );

  final String plantId;
  final String plantName;
  final Money price;
  final PriceUnit priceUnit;
  final int minOrderQty;
  final Availability availability;
  final int quantity;
  final String? imageUrl;

  /// Indicative only.
  Money get lineTotal => price * quantity;

  bool get isUnavailable => availability.isUnavailable;

  /// Keeps a quantity within the allowed range for a plant.
  static int clampQuantity(int quantity, int minOrderQty) {
    final min = minOrderQty < 1 ? 1 : minOrderQty;
    if (quantity < min) return min;
    if (quantity > maxQuantityPerItem) return maxQuantityPerItem;
    return quantity;
  }

  DraftRequestItem copyWith({int? quantity}) => DraftRequestItem(
    plantId: plantId,
    plantName: plantName,
    price: price,
    priceUnit: priceUnit,
    minOrderQty: minOrderQty,
    availability: availability,
    imageUrl: imageUrl,
    quantity: quantity ?? this.quantity,
  );

  @override
  bool operator ==(Object other) =>
      other is DraftRequestItem &&
      other.plantId == plantId &&
      other.quantity == quantity &&
      other.price == price &&
      other.minOrderQty == minOrderQty &&
      other.availability == availability;

  @override
  int get hashCode => Object.hash(plantId, quantity, price, minOrderQty, availability);
}

/// Sum of all line totals (indicative).
Money draftTotal(Iterable<DraftRequestItem> items) =>
    items.fold(Money.zero, (sum, item) => sum + item.lineTotal);
