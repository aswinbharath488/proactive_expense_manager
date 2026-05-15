import 'package:equatable/equatable.dart';

class CategoryEntity extends Equatable {
  const CategoryEntity({
    required this.id,
    required this.name,
    required this.isSynced,
    required this.isDeleted,
  });

  final String id;
  final String name;
  final bool isSynced;
  final bool isDeleted;

  CategoryEntity copyWith({
    String? id,
    String? name,
    bool? isSynced,
    bool? isDeleted,
  }) {
    return CategoryEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  factory CategoryEntity.fromMap(Map<String, Object?> map) {
    return CategoryEntity(
      id: map['id']! as String,
      name: map['name']! as String,
      isSynced: (map['is_synced'] as int) == 1,
      isDeleted: (map['is_deleted'] as int) == 1,
    );
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'name': name,
        'is_synced': isSynced ? 1 : 0,
        'is_deleted': isDeleted ? 1 : 0,
      };

  @override
  List<Object?> get props => [id, name, isSynced, isDeleted];
}
