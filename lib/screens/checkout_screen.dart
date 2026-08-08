import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});
  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _addressController = TextEditingController();

  bool _isPlacingOrder = false;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder(CartProvider cart) async {
    // Validate the form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Make sure the cart isn't empty
    if (cart.itemList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your cart is empty.'),
        ),
      );
      return;
    }

    setState(() {
      _isPlacingOrder = true;
    });

    // Simulate placing an order
    await Future.delayed(
      const Duration(seconds: 2),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isPlacingOrder = false;
    });

    // Clear only the current user's cart
    await cart.clearCart();

    if (!mounted) {
      return;
    }

    // Show success message
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Order Placed!'),

          content: const Text(
            'Your order has been placed successfully.\n\n'
            'This is a demo checkout — no real payment was processed.',
          ),

          actions: [
            TextButton(
              onPressed: () {
                // Close dialog
                Navigator.of(dialogContext).pop();

                // Go back to the first screen
                Navigator.of(context).popUntil(
                  (route) => route.isFirst,
                );
              },

              child: const Text('Back to Shop'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Form(
          key: _formKey,

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              // ==================================================
              // SHIPPING DETAILS
              // ==================================================

              const Text(
                'Shipping Details',

                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              // ==================================================
              // NAME
              // ==================================================

              TextFormField(
                controller: _nameController,

                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),

                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Please enter your name';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              // ==================================================
              // ADDRESS
              // ==================================================

              TextFormField(
                controller: _addressController,

                maxLines: 3,

                decoration: const InputDecoration(
                  labelText: 'Delivery Address',
                  border: OutlineInputBorder(),
                ),

                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Please enter your delivery address';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 28),

              // ==================================================
              // ORDER SUMMARY
              // ==================================================

              const Text(
                'Order Summary',

                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              ...cart.itemList.map(
                (item) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 6,
                    ),

                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,

                      children: [
                        Expanded(
                          child: Text(
                            '${item.product.title} x${item.quantity}',

                            maxLines: 1,

                            overflow:
                                TextOverflow.ellipsis,
                          ),
                        ),

                        const SizedBox(width: 12),

                        Text(
                          '\$${item.subtotal.toStringAsFixed(2)}',

                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const Divider(
                height: 32,
              ),

              // ==================================================
              // TOTAL
              // ==================================================

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,

                children: [
                  const Text(
                    'Total',

                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text(
                    '\$${cart.totalPrice.toStringAsFixed(2)}',

                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // ==================================================
              // PLACE ORDER BUTTON
              // ==================================================

              SizedBox(
                width: double.infinity,
                height: 50,

                child: ElevatedButton(
                  onPressed:
                      _isPlacingOrder ||
                              cart.itemList.isEmpty
                          ? null
                          : () {
                              _placeOrder(cart);
                            },

                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.deepPurple,

                    foregroundColor:
                        Colors.white,
                  ),

                  child: _isPlacingOrder
                      ? const SizedBox(
                          width: 22,
                          height: 22,

                          child:
                              CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Place Order',

                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}