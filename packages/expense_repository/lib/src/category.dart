part of 'package:expense_repository/expense_repository.dart';

class Category extends Equatable {
  final String categoryId;
  final String name;
  final String icon;
  final int color;

  const Category({
    required this.categoryId,
    required this.name,
    required this.icon,
    required this.color,
  });

  static const Category empty = Category(
    categoryId: '',
    name: '',
    icon: '',
    color: 0xFFFFFFFF,
  );

  Category copyWith({
    String? categoryId,
    String? name,
    String? icon,
    int? color,
  }) {
    return Category(
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
    );
  }

  @override
  List<Object> get props => [categoryId, name, icon, color];
}
