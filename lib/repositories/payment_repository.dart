import 'package:ferry/ferry.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:isar/isar.dart';

import '../collections/payment/payment.dart';
import '../graphql/get_payment/__generated__/get_payment.req.gql.dart';
import '../graphql/payment/__generated__/payment.req.gql.dart';
import '../providers/graphql_provider.dart';
import 'isar_repository.dart';

class PaymentOutput {
  final List<Payment>? payments;
  final Payment? newPayment;
  final String? error;

  PaymentOutput(
      {required this.payments, required this.newPayment, required this.error});
}

abstract class BasePaymentRepository {
  Future<void> getPayments();

  Future<void> payPayment({required String paymentId});

  Future<void> signOut();
}

final paymentRepositoryProvider =
    StateNotifierProvider<PaymentRepository, PaymentOutput>(
        (ref) => PaymentRepository(ref));

class PaymentRepository extends StateNotifier<PaymentOutput>
    implements BasePaymentRepository {
  final Ref _ref;

  PaymentRepository(this._ref)
      : super(PaymentOutput(payments: null, newPayment: null, error: null));

  @override
  Future<void> getPayments() async {
    final getPaymentsReq = GGetPaymentReq(
      (req) => req
        ..fetchPolicy = FetchPolicy.NetworkOnly
        ..vars.token = _ref.read(isarRepositoryProvider).getToken(),
    );

    final paymentsResponse = await _ref
        .read(clientProvider)
        .request(getPaymentsReq)
        .firstWhere((element) => element.dataSource != DataSource.Optimistic);

    final payments = paymentsResponse.data?.getPayments;

    if (payments != null) {
      List<Payment> returnPayments = [];

      payments.asList().forEach(
        (element) {
          final parking = Parking()
            ..name = element.parking.name
            ..databaseId = element.parking.id
            ..electricityCharge = element.parking.electricityCharge
            ..parkingCharge = element.parking.parkingCharge;

          returnPayments.add(
            Payment()
              ..databaseId = element.id
              ..vehicle = element.vehicle
              ..amount = element.amount
              ..active = element.active
              ..createdAt = element.createdAt
              ..updatedAt = element.updatedAt
              ..payment = element.payment
              ..parking = parking,
          );
        },
      );

      await signOut();

      _ref.read(isarRepositoryProvider).storePayments(payments: returnPayments);

      state = PaymentOutput(
        payments: returnPayments,
        newPayment: state.newPayment,
        error: null,
      );
    } else if (paymentsResponse.graphqlErrors != null) {
      state = PaymentOutput(
          payments: state.payments,
          newPayment: state.newPayment,
          error: paymentsResponse.graphqlErrors?[0].message);
    }
  }

  @override
  Future<void> payPayment({required String paymentId}) async {
    final payPaymentReq = GParkingPaymentReq(
      (req) => req
        ..fetchPolicy = FetchPolicy.NetworkOnly
        ..vars.token = _ref.read(isarRepositoryProvider).getToken()
        ..vars.paymentId = paymentId,
    );

    final payPaymentResponse = await _ref
        .read(clientProvider)
        .request(payPaymentReq)
        .firstWhere((element) => element.dataSource != DataSource.Optimistic);

    final payment = payPaymentResponse.data?.parkingPayment;

    if (payment != null && payment.payment == "DONE") {
      final returnPayment = _ref
          .read(isarRepositoryProvider)
          .isar
          .payments
          .filter()
          .paymentEqualTo("INITIATED")
          .findFirstSync();

      if (returnPayment != null) {
        _ref
            .read(isarRepositoryProvider)
            .updatePayment(payment: returnPayment..payment = "DONE");

        final List<Payment> paymentsList = state.payments!.map((e) {
          if (e.databaseId == returnPayment.databaseId) {
            return Payment()
              ..databaseId = e.databaseId
              ..payment = returnPayment.payment
              ..parking = e.parking
              ..vehicle = e.vehicle
              ..amount = e.amount
              ..updatedAt = e.updatedAt
              ..createdAt = e.createdAt
              ..id = e.id
              ..active = e.active;
          } else {
            return e;
          }
        }).toList();

        state = PaymentOutput(
            payments: paymentsList, newPayment: null, error: null);
      }
    } else if (payPaymentResponse.graphqlErrors != null) {
      state = PaymentOutput(
          payments: state.payments,
          newPayment: state.newPayment,
          error: payPaymentResponse.graphqlErrors?[0].message);
    }
  }

  @override
  Future<void> signOut() async {
    final Isar isar = _ref.read(isarRepositoryProvider).isar;

    final payments = await isar.payments.where().idProperty().findAll();

    await isar.writeTxn(() async => await isar.payments.deleteAll(payments));
    state = PaymentOutput(payments: null, newPayment: null, error: null);
  }
}
