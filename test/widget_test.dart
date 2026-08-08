import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:ecommerce_app/providers/auth_provider.dart';
import 'package:ecommerce_app/providers/cart_provider.dart';
import 'package:ecommerce_app/screens/login_screen.dart';

void main() {
  testWidgets(
    'Login screen displays correctly',
    (WidgetTester tester) async {
      // Create the providers that AuthProvider needs.
      final cartProvider = CartProvider();
      final authProvider = AuthProvider(cartProvider);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<CartProvider>.value(
              value: cartProvider,
            ),

            ChangeNotifierProvider<AuthProvider>.value(
              value: authProvider,
            ),
          ],

          child: const MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      // Check that the login screen appears.
      expect(
        find.text('ShopFlutter'),
        findsOneWidget,
      );

      expect(
        find.text('Username'),
        findsOneWidget,
      );

      expect(
        find.text('Password'),
        findsOneWidget,
      );

      expect(
        find.text('Login'),
        findsOneWidget,
      );
    },
  );
}