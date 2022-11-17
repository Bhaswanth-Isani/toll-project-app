import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:isar/isar.dart';

import '../collections/parking/parking.dart';
import '../collections/payment/payment.dart';
import '../collections/user/user.dart';
import '../collections/vehicles/vehicle.dart';

final isarRepositoryProvider =
    Provider<IsarRepository>((ref) => IsarRepository());

class IsarRepository {
  late Isar isar;

  IsarRepository() {
    isar = openDB();
  }

  void storeUser({required User user}) {
    isar.writeTxnSync(() => isar.users.putSync(user));
  }

  String getToken() {
    return isar.users.getSync(1)?.token ?? "";
  }

  void storeVehicles({required List<Vehicle> vehicles}) {
    isar.writeTxnSync(() {
      for (var element in vehicles) {
        isar.vehicles.putSync(element);
      }
    });
  }

  void storePayments({required List<Payment> payments}) {
    isar.writeTxnSync(() {
      for (var element in payments) {
        isar.payments.putSync(element);
      }
    });
  }

  void storeParkingLots({required List<ParkingLot> parkingLots}) {
    isar.writeTxnSync(() {
      for (var element in parkingLots) {
        isar.parkingLots.putSync(element);
      }
    });
  }

  void updatePayment({required Payment payment}) {
    final databasePayment = isar.payments
        .filter()
        .databaseIdEqualTo(payment.databaseId)
        .findFirstSync();

    if (databasePayment != null) {
      payment.id = databasePayment.id;
      isar.writeTxnSync(() => isar.payments.putSync(payment));
    } else {
      isar.writeTxnSync(() => isar.payments.putSync(payment));
    }
  }

  void updateVehicle({required Vehicle vehicle}) {
    final databaseVehicle = isar.vehicles
        .filter()
        .databaseIdEqualTo(vehicle.databaseId)
        .findFirstSync();

    if (databaseVehicle != null) {
      isar.writeTxnSync(
          () => isar.vehicles.putSync(vehicle..id = databaseVehicle.id));
    } else {
      isar.writeTxnSync(() => isar.vehicles.putSync(vehicle));
    }
  }

  Isar openDB() {
    if (Isar.instanceNames.isEmpty) {
      return Isar.openSync(
        [UserSchema, VehicleSchema, PaymentSchema, ParkingLotSchema],
        inspector: true,
      );
    }
    return Isar.getInstance()!;
  }
}
