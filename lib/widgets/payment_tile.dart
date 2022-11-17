import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../constants/theme.dart';
import '../repositories/payment_repository.dart';
import '../routes/router.gr.dart';

class PaymentTile extends StatelessWidget {
  const PaymentTile({
    Key? key,
    required this.paymentsList,
    required this.index,
  }) : super(key: key);

  final PaymentOutput paymentsList;
  final int index;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => AutoRouter.of(context).push(
        PaymentRoute(
          payment: paymentsList.payments![index],
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        width: double.infinity,
        height: 80,
        decoration: BoxDecoration(
          color: listCardColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              height: 56,
              width: 56,
              decoration: BoxDecoration(
                color: const Color(0xff5fd068),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  paymentsList.payments![index].parking.name,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  DateFormat.yMMMd().format(DateTime.fromMillisecondsSinceEpoch(
                      int.parse(paymentsList.payments![index].updatedAt))),
                  style: GoogleFonts.poppins(),
                )
              ],
            ),
            const Spacer(),
            Text(
              "₹${paymentsList.payments![index].amount.toString()}",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
