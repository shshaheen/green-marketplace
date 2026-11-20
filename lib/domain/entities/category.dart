import 'plant.dart';

/// A category or subcategory (two levels). The public tree fills [subcategories];
/// admin responses fill [parent], [isActive] and [deletedAt].
class Category {
  const Category({
    required this.id,
    required this.name,
    required this.slug,
    this.description = '',
    this.sortOrder = 0,
    this.parent,
    this.subcategories = const [],
    this.isActive,
    this.deletedAt,
  });

  final String id;
  final String name;
  final String slug;
  final String description;
  final int sortOrder;

  /// Null for a top-level category.
  final CategoryRef? parent;
  final List<Category> subcategories;

  // Admin-only fields.
  final bool? isActive;
  final DateTime? deletedAt;

  bool get isTopLevel => parent == null;

  CategoryRef toRef() => CategoryRef(id: id, name: name, slug: slug);
}
