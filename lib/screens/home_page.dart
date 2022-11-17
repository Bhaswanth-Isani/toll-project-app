import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

import '../constants/theme.dart';
import '../repositories/auth_repository.dart';
import '../repositories/payment_repository.dart';
import '../repositories/vehicle_repository.dart';
import '../routes/router.gr.dart';
import '../widgets/custom_title.dart';
import '../widgets/payment_list.dart';
import '../widgets/registration_text_input.dart';
import '../widgets/vehicle_card_swiper.dart';
import 'parking_lots_page.dart';
import 'transactions_page.dart';
import 'vehicles_page.dart';

class HomePage extends HookConsumerWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextEditingController amountController = useTextEditingController();
    Widget buildPopupDialog(BuildContext context, String vehicleId) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        title: Text(
          "Add Amount",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: RegistrationTextInput(
          textEditingController: amountController,
          error: false,
          errorText: "Add some amount",
          label: "AMOUNT",
          loading: false,
          password: false,
          type: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () {
              AutoRouter.of(context).pop();
              amountController.clear();
            },
            child: Text(
              "CANCEL",
              style: GoogleFonts.poppins(
                color: errorColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
            ),
            onPressed: () {
              ref.read(vehicleRepositoryProvider.notifier).addAmount(
                    vehicleId: vehicleId,
                    amount: int.parse(
                      amountController.text,
                    ),
                  );

              AutoRouter.of(context).pop();
              amountController.clear();
            },
            child: Text(
              "ADD",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      );
    }

    return Container(
      color: scaffoldBackgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          VehicleCardSwiper(
            popupBuilder: buildPopupDialog,
            higherContext: context,
          ),
          const SizedBox(
            height: 24,
          ),
          const CustomTitle(),
          const SizedBox(
            height: 16,
          ),
          const Expanded(
            child: PaymentList(),
          ),
        ],
      ),
    );
  }
}

class RoutingPage extends HookConsumerWidget {
  const RoutingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabIndex = useState<int>(0);

    final user = ref.watch(authRepositoryProvider);

    if (user.user == null) {
      AutoRouter.of(context).replaceAll([LoginRoute()]);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: scaffoldBackgroundColor,
        title: Text(
          "Your Wallet",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: primaryTextColor,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: GestureDetector(
              onTap: () {
                ref.read(paymentRepositoryProvider.notifier).signOut();
                ref.read(vehicleRepositoryProvider.notifier).signOut();
                ref.read(authRepositoryProvider.notifier).signOut();
                tabIndex.value = 0;
              },
              child: const Icon(
                FeatherIcons.logOut,
                color: errorColor,
              ),
            ),
          )
        ],
        centerTitle: false,
        elevation: 0,
      ),
      body: tabIndex.value == 0
          ? const HomePage()
          : tabIndex.value == 1
              ? const VehiclesPage()
              : tabIndex.value == 2
                  ? const ParkingLotsPage()
                  : const TransactionsPage(),
      bottomNavigationBar: SalomonBottomBar(
        margin: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        currentIndex: tabIndex.value,
        onTap: (index) {
          tabIndex.value = index;
        },
        items: [
          SalomonBottomBarItem(
            icon: const Icon(FeatherIcons.home),
            title: Text(
              "Home",
              style: GoogleFonts.poppins(),
            ),
            selectedColor: Colors.purple,
          ),
          SalomonBottomBarItem(
            icon: const Icon(FeatherIcons.truck),
            title: Text(
              "Vehicles",
              style: GoogleFonts.poppins(),
            ),
            selectedColor: Colors.pink,
          ),
          SalomonBottomBarItem(
            icon: const Icon(FeatherIcons.film),
            title: Text(
              "Parking",
              style: GoogleFonts.poppins(),
            ),
            selectedColor: Colors.orange,
          ),
          SalomonBottomBarItem(
            icon: const Icon(FeatherIcons.creditCard),
            title: Text(
              "Transactions",
              style: GoogleFonts.poppins(),
            ),
            selectedColor: Colors.teal,
          ),
        ],
      ),
    );
  }
}
