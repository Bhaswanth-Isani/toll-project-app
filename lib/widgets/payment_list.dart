import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../repositories/payment_repository.dart';
import 'payment_tile.dart';

class PaymentList extends ConsumerWidget {
  const PaymentList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentsList = ref.watch(paymentRepositoryProvider);

    if (paymentsList.payments == null) {
      ref.read(paymentRepositoryProvider.notifier).getPayments();
    }

    return paymentsList.payments != null
        ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ListView.builder(
              itemBuilder: (context, index) {
                return PaymentTile(
                  paymentsList: paymentsList,
                  index: index,
                );
              },
              itemCount: paymentsList.payments!.length,
              physics: const NeverScrollableScrollPhysics(),
            ),
          )
        : const Center(
            child: CircularProgressIndicator(),
          );
  }
}
