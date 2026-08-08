import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/product_provider.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ProductProvider(),
        ),

        ChangeNotifierProvider(
          create: (_) => CartProvider(),
        ),

        ChangeNotifierProxyProvider<CartProvider, AuthProvider>(
          create: (context) {
            return AuthProvider(
              context.read<CartProvider>(),
            );
          },

          update: (context, cartProvider, authProvider) {
            return authProvider ??
                AuthProvider(cartProvider);
          },
        ),
      ],

      child: MaterialApp(
        title: 'ShopFlutter',

        debugShowCheckedModeBanner: false,

        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
          ),

          useMaterial3: true,

          scaffoldBackgroundColor:
              Colors.white,

          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            elevation: 0,
          ),
        ),

        home: const StartupGate(),
      ),
    );
  }
}

class StartupGate extends StatefulWidget {
  const StartupGate({super.key});

  @override
  State<StartupGate> createState() =>
      _StartupGateState();
}

class _StartupGateState extends State<StartupGate> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _initialize(),
    );
  }

  Future<void> _initialize() async {
    final auth = context.read<AuthProvider>();

    await auth.restoreSession();
  }

  @override
  Widget build(BuildContext context) {
    final authStatus =
        context.watch<AuthProvider>().status;

    if (authStatus == AuthStatus.unknown) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (authStatus ==
        AuthStatus.authenticated) {
      return const HomeScreen();
    }

    return const LoginScreen();
  }
}