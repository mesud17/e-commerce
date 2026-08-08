import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';

class CategoryFilter extends StatelessWidget {
  const CategoryFilter({super.key});

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final categories = productProvider.categories;

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == productProvider.selectedCategory;
          return ChoiceChip(
            label: Text(
              category[0].toUpperCase() + category.substring(1),
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontSize: 13,
              ),
            ),
            selected: isSelected,
            selectedColor: Colors.deepPurple,
            backgroundColor: Colors.grey.shade200,
            onSelected: (_) => productProvider.setCategory(category),
          );
        },
      ),
    );
  }
}
