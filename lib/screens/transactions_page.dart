import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../constants/theme.dart';
import '../repositories/payment_repository.dart';
import '../widgets/payment_tile.dart';

class TransactionsPage extends ConsumerStatefulWidget {
  const TransactionsPage({Key? key}) : super(key: key);

  @override
  TransactionsPageState createState() => TransactionsPageState();
}

class TransactionsPageState extends ConsumerState<TransactionsPage> {
  @override
  void initState() {
    super.initState();
    ref.read(paymentRepositoryProvider.notifier).getPayments();
  }

  @override
  Widget build(BuildContext context) {
    final paymentsList = ref.watch(paymentRepositoryProvider);

    return paymentsList.payments != null
        ? Container(
            color: scaffoldBackgroundColor,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
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
            ),
          )
        : Container(
            color: scaffoldBackgroundColor,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
  }
}
