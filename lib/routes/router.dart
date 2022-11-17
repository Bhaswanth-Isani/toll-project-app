import 'package:auto_route/auto_route.dart';

import '../screens/home_page.dart';
import '../screens/login_page.dart';
import '../screens/parking_lots_page.dart';
import '../screens/payment_page.dart';
import '../screens/register_page.dart';
import '../screens/register_vehicle_page.dart';
import '../screens/transactions_page.dart';
import '../screens/vehicles_page.dart';

@AdaptiveAutoRouter(
  replaceInRouteName: 'Page,Route',
  routes: <AutoRoute>[
    AutoRoute(page: LoginPage, initial: true),
    AutoRoute(page: RegisterPage),
    AutoRoute(page: RegisterVehiclePage),
    AutoRoute(page: RoutingPage),
    AutoRoute(page: HomePage),
    AutoRoute(page: ParkingLotsPage),
    AutoRoute(page: TransactionsPage),
    AutoRoute(page: VehiclesPage),
    AutoRoute(page: PaymentPage),
  ],
)
class $AppRouter {}
