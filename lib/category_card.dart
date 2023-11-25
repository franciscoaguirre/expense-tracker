import 'package:flutter/material.dart';

import 'category.dart';
import 'colored_circle.dart';

class CategoryCard extends StatelessWidget {
  final Category? category;

  const CategoryCard({
    super.key,
    this.category,
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
            category != null
                ? ColoredCircle(color: Color(category!.color))
                : const Spacer(),
          ],
        ),
      ),
    );
  }
}
