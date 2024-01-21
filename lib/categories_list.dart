import 'package:flutter/material.dart';

import 'category.dart';
import 'category_card.dart';

class CategoriesListView extends StatelessWidget {
  final List<Category> categories;
  final Function(int) onDelete;
  final Function(Category) onEdit;
  final bool isLoading;

  const CategoriesListView({
    super.key,
    required this.categories,
    required this.onDelete,
    required this.onEdit,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (categories.isEmpty) {
      return const Center(child: Text("No categories found"));
    }

    return ListView.builder(
      itemCount: categories.length,
      itemBuilder: (context, index) {
        return CategoryCard(
          category: categories[index],
          onDelete: () {
            onDelete(categories[index].id);
          },
          onEdit: () {
            onEdit(categories[index]);
          },
        );
      },
    );
  }
}
