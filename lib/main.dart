import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:inbound/presentation/bloc/purchase_order/purchase_order_bloc.dart';
import 'package:mobile/presentation/bloc/navigation_bloc.dart';
import 'package:mobile/presentation/pages/main_page.dart';
import 'package:product/presentation/bloc/product_bloc.dart';
import 'package:zone/presentation/bloc/zone_bloc.dart';

import 'injector.dart';
import 'route_observer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await setupInjector();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<NavigationBloc>(create: (context) => NavigationBloc()),
        BlocProvider<PurchaseOrderBloc>(
          create: (context) => getIt<PurchaseOrderBloc>(),
        ),
        BlocProvider<ProductBloc>(create: (context) => getIt<ProductBloc>()),
        BlocProvider<ZoneBloc>(create: (context) => getIt<ZoneBloc>()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'WareHaus Mobile',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          scaffoldBackgroundColor: Colors.white,
        ),
        navigatorObservers: [routeObserver],
        home: const MainPage(),
      ),
    );
  }
}
