import 'package:product/domain/entities/category.dart';

class CategoryModel extends Category {
  CategoryModel({
    required super.id,
    required super.name,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: (json['id'] ?? ''),
      name: (json['name'] ?? json['categoryName'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
    'id': int,
    'categoryName': name,
    };
  }
}