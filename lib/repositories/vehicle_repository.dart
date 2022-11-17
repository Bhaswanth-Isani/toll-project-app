import 'package:ferry/ferry.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:toll_project_app/graphql/block/__generated__/block.req.gql.dart';

import '../collections/vehicles/vehicle.dart';
import '../graphql/amount/__generated__/amount.req.gql.dart';
import '../graphql/new_vehicle/__generated__/new_vehicle.req.gql.dart';
import '../graphql/type/__generated__/type.req.gql.dart';
import '../graphql/vehicles/__generated__/vehicles.req.gql.dart';
import '../providers/graphql_provider.dart';
import 'isar_repository.dart';

class VehicleOutput {
  final List<Vehicle>? vehicles;
  final String? error;

  VehicleOutput({required this.vehicles, required this.error});
}

abstract class BaseVehicleRepository {
  Future<void> getVehicles();

  Future<void> registerVehicle({
    required String licensePlate,
    required String rfid,
    required String vehicleType,
  });

  Future<void> addAmount({required String vehicleId, required int amount});

  Vehicle getCertainVehicle({required String vehicleId});

  Future<void> updateBlock({required String vehicleId});

  Future<void> updateType({required String vehicleId});

  void signOut();
}

final vehicleRepositoryProvider =
    StateNotifierProvider<VehicleRepository, VehicleOutput>(
        (ref) => VehicleRepository(ref));

class VehicleRepository extends StateNotifier<VehicleOutput>
    implements BaseVehicleRepository {
  final Ref _ref;

  VehicleRepository(this._ref)
      : super(VehicleOutput(vehicles: null, error: null));

  @override
  Future<void> getVehicles() async {
    final getVehiclesReq = GGetVehiclesReq(
      (req) => req
        ..fetchPolicy = FetchPolicy.NetworkOnly
        ..vars.token = _ref.read(isarRepositoryProvider).getToken(),
    );

    final vehiclesResponse = await _ref
        .read(clientProvider)
        .request(getVehiclesReq)
        .firstWhere((element) => element.dataSource != DataSource.Optimistic);

    final vehicles = vehiclesResponse.data?.getVehicles;

    if (vehicles != null) {
      List<Vehicle> returnVehicles = [];

      vehicles.asList().forEach((element) => returnVehicles.add(Vehicle()
        ..databaseId = element.id
        ..amount = element.amount
        ..licensePlate = element.licensePlate
        ..rfid = element.rfid
        ..block = element.block
        ..paymentType = element.paymentType
        ..user = element.user));

      signOut();

      _ref.read(isarRepositoryProvider).storeVehicles(vehicles: returnVehicles);

      state = VehicleOutput(vehicles: returnVehicles, error: null);
    } else if (vehiclesResponse.graphqlErrors != null) {
      state = VehicleOutput(
          vehicles: state.vehicles,
          error: vehiclesResponse.graphqlErrors?[0].message);
    }
  }

  @override
  Future<void> registerVehicle(
      {required String licensePlate,
      required String rfid,
      required String vehicleType}) async {
    final registerVehicleReq = GRegisterVehicleReq((vehicle) => vehicle.vars
      ..rfid = rfid
      ..licensePlate = licensePlate
      ..type = vehicleType
      ..token = _ref.read(isarRepositoryProvider).getToken());

    final vehicleResponse = await _ref
        .read(clientProvider)
        .request(registerVehicleReq)
        .firstWhere((element) => element.dataSource != DataSource.Optimistic);

    final vehicle = vehicleResponse.data?.registerVehicle;

    if (vehicle != null) {
      final returnVehicle = Vehicle()
        ..databaseId = vehicle.id
        ..amount = vehicle.amount
        ..licensePlate = vehicle.licensePlate
        ..rfid = vehicle.rfid
        ..block = vehicle.block
        ..paymentType = vehicle.paymentType
        ..user = vehicle.user;

      _ref.read(isarRepositoryProvider).updateVehicle(vehicle: returnVehicle);

      state = VehicleOutput(
          vehicles: [...?state.vehicles, returnVehicle], error: null);
    } else if (vehicleResponse.graphqlErrors != null) {
      state = VehicleOutput(
          vehicles: state.vehicles,
          error: vehicleResponse.graphqlErrors?[0].message);
    }
  }

  @override
  Future<void> addAmount(
      {required String vehicleId, required int amount}) async {
    final addAmountReq = GAddAmountReq(
      (addAmount) => addAmount
        ..fetchPolicy = FetchPolicy.NetworkOnly
        ..vars.amount = amount
        ..vars.vehicleId = vehicleId
        ..vars.token = _ref.read(isarRepositoryProvider).getToken(),
    );

    final addAmountResponse = await _ref
        .read(clientProvider)
        .request(addAmountReq)
        .firstWhere((element) => element.dataSource != DataSource.Optimistic);

    final addAmount = addAmountResponse.data?.addAmount;

    if (addAmount != null) {
      final returnVehicle = Vehicle()
        ..databaseId = addAmount.id
        ..amount = addAmount.amount
        ..licensePlate = addAmount.licensePlate
        ..rfid = addAmount.rfid
        ..block = addAmount.block
        ..paymentType = addAmount.paymentType
        ..user = addAmount.user;

      _ref.read(isarRepositoryProvider).updateVehicle(vehicle: returnVehicle);

      final index = state.vehicles?.indexWhere(
          (element) => element.databaseId == returnVehicle.databaseId);

      state.vehicles?[index!] = returnVehicle;
    } else if (addAmountResponse.graphqlErrors != null) {
      state = VehicleOutput(
          vehicles: state.vehicles,
          error: addAmountResponse.graphqlErrors?[0].message);
    }
  }

  @override
  Vehicle getCertainVehicle({required String vehicleId}) {
    return _ref
        .read(isarRepositoryProvider)
        .isar
        .vehicles
        .filter()
        .databaseIdEqualTo(vehicleId)
        .findFirstSync()!;
  }

  @override
  void signOut() {
    final Isar isar = _ref.read(isarRepositoryProvider).isar;

    final vehicles = isar.vehicles.where().idProperty().findAllSync();

    isar.writeTxnSync(() => isar.vehicles.deleteAllSync(vehicles));
    state = VehicleOutput(vehicles: null, error: null);
  }

  @override
  Future<void> updateBlock({required String vehicleId}) async {
    final updateBlockReq =
        GUpdateBlockReq((req) => req.vars..vehicleId = vehicleId);

    final updateBlockResponse = await _ref
        .read(clientProvider)
        .request(updateBlockReq)
        .firstWhere((element) => element.dataSource != DataSource.Optimistic);

    final updateBlock = updateBlockResponse.data?.updateBlock;
    if (updateBlock != null) {
      final index = state.vehicles
          ?.indexWhere((element) => element.databaseId == vehicleId);

      final initialVehicle = state.vehicles![index!];

      final returnVehicle = Vehicle()
        ..id = initialVehicle.id
        ..databaseId = initialVehicle.databaseId
        ..amount = initialVehicle.amount
        ..licensePlate = initialVehicle.licensePlate
        ..block = !initialVehicle.block
        ..paymentType = initialVehicle.paymentType
        ..rfid = initialVehicle.rfid
        ..user = initialVehicle.user;

      _ref.read(isarRepositoryProvider).updateVehicle(vehicle: returnVehicle);

      state.vehicles![index] = returnVehicle;
    } else if (updateBlockResponse.graphqlErrors != null) {
      state = VehicleOutput(
          vehicles: state.vehicles,
          error: updateBlockResponse.graphqlErrors?[0].message);
    }
  }

  @override
  Future<void> updateType({required String vehicleId}) async {
    final updateTypeReq =
        GUpdateTypeReq((req) => req.vars..vehicleId = vehicleId);

    final updateTypeResponse = await _ref
        .read(clientProvider)
        .request(updateTypeReq)
        .firstWhere((element) => element.dataSource != DataSource.Optimistic);

    final updateType = updateTypeResponse.data?.updateType;
    if (updateType != null) {
      final index = state.vehicles
          ?.indexWhere((element) => element.databaseId == vehicleId);

      final initialVehicle = state.vehicles![index!];

      final returnVehicle = Vehicle()
        ..id = initialVehicle.id
        ..databaseId = initialVehicle.databaseId
        ..amount = initialVehicle.amount
        ..licensePlate = initialVehicle.licensePlate
        ..block = initialVehicle.block
        ..paymentType =
            initialVehicle.paymentType == "SINGLE" ? "DOUBLE" : "SINGLE"
        ..rfid = initialVehicle.rfid
        ..user = initialVehicle.user;

      _ref.read(isarRepositoryProvider).updateVehicle(vehicle: returnVehicle);

      state.vehicles![index] = returnVehicle;
    } else if (updateTypeResponse.graphqlErrors != null) {
      state = VehicleOutput(
          vehicles: state.vehicles,
          error: updateTypeResponse.graphqlErrors?[0].message);
    }
  }
}
