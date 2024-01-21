import 'package:flutter/material.dart';

import 'category.dart';
import 'colored_circle.dart';

class CategoryCard extends StatelessWidget {
  final Category? category;
  final Function()? onDelete;
  final Function()? onEdit;

  const CategoryCard({
    super.key,
    this.category,
    this.onDelete,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: <Widget>[
            Text(category?.name ?? "Category"),
            const Spacer(),
            onDelete != null
                ? IconButton(icon: const Icon(Icons.edit), onPressed: onEdit)
                : const SizedBox.shrink(),
            onEdit != null
                ? IconButton(
                    icon: const Icon(Icons.delete), onPressed: onDelete)
                : const SizedBox.shrink(),
            category != null
                ? ColoredCircle(color: Color(category!.color))
                : const Spacer(),
          ],
        ),
      ),
    );
  }
}
