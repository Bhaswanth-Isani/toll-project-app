import 'package:isar/isar.dart';

part 'vehicle.g.dart';

@collection
class Vehicle {
  Id? id = Isar.autoIncrement;

  @Index(unique: true)
  late String databaseId;

  @Index(unique: true)
  late String rfid;

  @Index(unique: true)
  late String licensePlate;

  late int amount;
  late bool block;
  late String paymentType;
  late String user;
}
