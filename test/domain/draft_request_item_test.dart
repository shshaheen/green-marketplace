import 'package:flutter_test/flutter_test.dart';
import 'package:green_marketplace/domain/entities/draft_request_item.dart';
import 'package:green_marketplace/domain/entities/money.dart';
import 'package:green_marketplace/domain/entities/plant.dart';
import 'package:green_marketplace/domain/enums/plant_enums.dart';

const _jade = Plant(
  id: 'p1',
  name: 'Jade Plant',
  slug: 'jade-plant',
  price: Money(25000),
  priceUnit: PriceUnit.perPot,
  minOrderQty: 10,
  availability: Availability.outOfStock,
  image: PlantImage(id: 'i1', url: 'https://img.test/jade.png'),
);

void main() {
  group('DraftRequestItem', () {
    test('starts at the minimum order quantity and copies plant details', () {
      final item = DraftRequestItem.fromPlant(_jade);
      expect(item.quantity, 10);
      expect(item.imageUrl, 'https://img.test/jade.png');
      expect(item.lineTotal, const Money(250000));
    });

    test('out-of-stock plants can be added and are flagged', () {
      final item = DraftRequestItem.fromPlant(_jade);
      expect(item.isUnavailable, isTrue);
    });

    test('quantity is clamped between the MOQ and the maximum', () {
      expect(DraftRequestItem.fromPlant(_jade, quantity: 3).quantity, 10);
      expect(DraftRequestItem.fromPlant(_jade, quantity: 500000).quantity, maxQuantityPerItem);
      final item = DraftRequestItem.fromPlant(_jade).copyWith(quantity: 2);
      expect(item.quantity, 10);
      expect(DraftRequestItem.clampQuantity(0, 0), 1);
    });

    test('draftTotal sums line totals', () {
      final items = [
        DraftRequestItem.fromPlant(_jade, quantity: 20),
        DraftRequestItem.fromPlant(_jade),
      ];
      expect(draftTotal(items), const Money(750000));
      expect(draftTotal(const []), Money.zero);
    });

    test('value equality', () {
      expect(DraftRequestItem.fromPlant(_jade), DraftRequestItem.fromPlant(_jade));
      expect(
        DraftRequestItem.fromPlant(_jade),
        isNot(DraftRequestItem.fromPlant(_jade, quantity: 11)),
      );
    });
  });

  group('Money', () {
    test('arithmetic and equality', () {
      expect(const Money(100) + const Money(50), const Money(150));
      expect(const Money(250) * 4, const Money(1000));
      expect(const Money(1), isNot(const Money(1, currency: 'USD')));
    });
  });
}
