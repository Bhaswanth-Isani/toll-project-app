import 'package:isar/isar.dart';

part 'payment.g.dart';

@collection
class Payment {
  Id? id = Isar.autoIncrement;

  @Index(unique: true)
  late String databaseId;

  late String vehicle;
  late Parking parking;
  late bool active;
  late String payment;
  late int amount;
  late String createdAt;
  late String updatedAt;
}

@embedded
class Parking {
  late String databaseId;
  late String name;
  late int electricityCharge;
  late int parkingCharge;
}