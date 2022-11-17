import 'package:ferry/ferry.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:isar/isar.dart';
import '../graphql/get_parking_lots/__generated__/get_parking_lots.req.gql.dart';

import '../collections/parking/parking.dart';
import '../providers/graphql_provider.dart';
import 'isar_repository.dart';

class ParkingOutput {
  final List<ParkingLot>? parking;
  final String? error;

  ParkingOutput({required this.parking, required this.error});
}

abstract class BaseParkingRepository {
  Future<void> getParkingLots();
}

final parkingLotRepositoryProvider =
    StateNotifierProvider<ParkingRepository, ParkingOutput>(
        (ref) => ParkingRepository(ref));

class ParkingRepository extends StateNotifier<ParkingOutput>
    implements BaseParkingRepository {
  final Ref _ref;

  ParkingRepository(this._ref)
      : super(ParkingOutput(parking: null, error: null));

  @override
  Future<void> getParkingLots() async {
    final getParkingLotsReq = GGetParkingLotsReq(
      (b) => b..fetchPolicy = FetchPolicy.NetworkOnly,
    );

    final parkingLotsResponse = await _ref
        .read(clientProvider)
        .request(getParkingLotsReq)
        .firstWhere((element) => element.dataSource != DataSource.Optimistic);

    final parkingLots = parkingLotsResponse.data?.getParkingLots;

    if (parkingLots != null) {
      List<ParkingLot> returnParkingLots = [];

      for (var element in parkingLots) {
        final parking = ParkingLot()
          ..databaseId = element.id
          ..name = element.name
          ..electricityCharge = element.electricityCharge
          ..parkingCharge = element.parkingCharge
          ..occupied = element.occupied
          ..lots = element.lots;

        returnParkingLots.add(parking);
      }

      signOut();

      _ref
          .read(isarRepositoryProvider)
          .storeParkingLots(parkingLots: returnParkingLots);

      state = ParkingOutput(parking: returnParkingLots, error: null);
    } else if (parkingLotsResponse.graphqlErrors != null) {
      state = ParkingOutput(
        parking: state.parking,
        error: parkingLotsResponse.graphqlErrors?[0].message,
      );
    }
  }

  void signOut() {
    final Isar isar = _ref.read(isarRepositoryProvider).isar;

    final parkingLots = isar.parkingLots.where().idProperty().findAllSync();

    isar.writeTxnSync(() => isar.parkingLots.deleteAllSync(parkingLots));
    state = ParkingOutput(parking: null, error: null);
  }
}
