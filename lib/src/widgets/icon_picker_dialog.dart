import 'package:flutter/material.dart';

class IconPickerDialog extends StatelessWidget {
  final List<IconData> icons = [
    Icons.restaurant,
    Icons.shopping_cart,
    Icons.home,
    Icons.car_rental,
    Icons.school,
    Icons.local_grocery_store,
    Icons.local_hospital,
    Icons.local_offer,
    Icons.local_pizza,
    Icons.local_play,
    // Add more icons as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 1,
        ),
        itemCount: icons.length,
        itemBuilder: (context, index) {
          return IconButton(
            icon: Icon(icons[index]),
            onPressed: () {
              Navigator.of(context).pop(icons[index]);
            },
          );
        },
      ),
    );
  }
}
