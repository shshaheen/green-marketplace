/// One page of results from a list endpoint.
class Paginated<T> {
  const Paginated({
    required this.items,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  const Paginated.empty({this.limit = 20}) : items = const [], page = 1, total = 0, totalPages = 0;

  final List<T> items;
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  bool get hasNextPage => page < totalPages;
}
