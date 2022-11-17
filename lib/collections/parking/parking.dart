import 'package:isar/isar.dart';

part 'parking.g.dart';

@collection
class ParkingLot {
  Id? id = Isar.autoIncrement;

  @Index(unique: true)
  late String databaseId;

  late String name;
  late int electricityCharge;
  late int parkingCharge;
  late int occupied;
  late int lots;
}
