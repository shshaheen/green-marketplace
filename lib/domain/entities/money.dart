/// An amount in whole paise (₹1 = 100 paise). Never use doubles for money.
class Money {
  const Money(this.paise, {this.currency = 'INR'}) : assert(paise >= 0, 'Money cannot be negative');

  static const Money zero = Money(0);

  final int paise;
  final String currency;

  Money operator +(Money other) => Money(paise + other.paise, currency: currency);

  Money operator *(int quantity) => Money(paise * quantity, currency: currency);

  @override
  bool operator ==(Object other) =>
      other is Money && other.paise == paise && other.currency == currency;

  @override
  int get hashCode => Object.hash(paise, currency);

  @override
  String toString() => 'Money($paise $currency)';
}
