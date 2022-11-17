import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import '../repositories/payment_repository.dart';
import '../repositories/vehicle_repository.dart';

import '../collections/payment/payment.dart';
import '../constants/theme.dart';

class PaymentPage extends ConsumerWidget {
  const PaymentPage({Key? key, required this.payment}) : super(key: key);

  final Payment payment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xffffc0b8),
        iconTheme: const IconThemeData(color: primaryTextColor),
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Positioned(
                child: Container(
                  padding: const EdgeInsets.only(top: 10, bottom: 70),
                  width: double.infinity,
                  color: const Color(0xffffc0b8),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "₹${payment.amount}",
                          style: GoogleFonts.poppins(
                            color: Colors.redAccent,
                            fontSize: 36,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          payment.parking.name,
                          style: GoogleFonts.poppins(
                            color: Colors.redAccent,
                            fontSize: 16,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -50,
                child: Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 70,
              right: 14,
              left: 14,
            ),
            child: Column(
              children: [
                Text(
                  "Transaction Details",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                InformationTile(
                  title: "Date",
                  info: DateFormat.yMMMd().format(
                    DateTime.fromMillisecondsSinceEpoch(
                      int.parse(payment.updatedAt),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 6,
                ),
                InformationTile(title: "Payment", info: payment.payment),
                const SizedBox(
                  height: 6,
                ),
                InformationTile(
                  title: "Vehicle",
                  info: ref
                      .read(vehicleRepositoryProvider.notifier)
                      .getCertainVehicle(vehicleId: payment.vehicle)
                      .licensePlate,
                ),
                const SizedBox(
                  height: 6,
                ),
                InformationTile(
                    title: "Parking Lot", info: payment.parking.name),
                const SizedBox(
                  height: 6,
                ),
                InformationTile(title: "Payment ID", info: payment.databaseId),
              ],
            ),
          ),
          const SizedBox(
            height: 24,
          ),
          const Spacer(),
          if (payment.payment == "INITIATED")
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                  ),
                  onPressed: () {
                    ref
                        .read(paymentRepositoryProvider.notifier)
                        .payPayment(paymentId: payment.databaseId);
                    AutoRouter.of(context).pop();
                  },
                  child: Text(
                    "PAY",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class InformationTile extends StatelessWidget {
  const InformationTile({
    Key? key,
    required this.title,
    required this.info,
  }) : super(key: key);

  final String title;
  final String info;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: GoogleFonts.poppins()),
        Text(
          info,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
