import 'package:bar_bros_user/features/category/domain/entities/category.dart';

class CategoryModel extends Category {
  const CategoryModel({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required super.modifiedAt,
    super.createdBy,
    super.modifiedBy,
    required super.isDeleted,
    required super.name,
    required super.img,
    required super.categoryType,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      modifiedAt: json['modified_at'] as String,
      createdBy: json['created_by'] as String?,
      modifiedBy: json['modified_by'] as String?,
      isDeleted: json['is_deleted'] as bool,
      name: json['name'] as String,
      img: json['img'] as String,
      categoryType: json['categoryType'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'modified_at': modifiedAt,
      'created_by': createdBy,
      'modified_by': modifiedBy,
      'is_deleted': isDeleted,
      'name': name,
      'img': img,
      'categoryType': categoryType,
    };
  }
}