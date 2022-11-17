import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../constants/theme.dart';
import '../repositories/parking_repository.dart';

class ParkingLotsPage extends ConsumerStatefulWidget {
  const ParkingLotsPage({Key? key}) : super(key: key);

  @override
  ParkingLotsPageState createState() => ParkingLotsPageState();
}

class ParkingLotsPageState extends ConsumerState<ParkingLotsPage> {
  @override
  void initState() {
    super.initState();
    ref.read(parkingLotRepositoryProvider.notifier).getParkingLots();
  }

  @override
  Widget build(BuildContext context) {
    final parkingLotsList = ref.watch(parkingLotRepositoryProvider);

    if (parkingLotsList.parking == null) {
      ref.read(parkingLotRepositoryProvider.notifier).getParkingLots();
    }

    return parkingLotsList.parking != null
        ? Container(
            color: scaffoldBackgroundColor,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              child: ListView.builder(
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          parkingLotsList.parking![index].name,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "Parking: ",
                                      style: GoogleFonts.poppins(
                                        color: secondaryTextColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    TextSpan(
                                      text: parkingLotsList
                                          .parking![index].parkingCharge
                                          .toString(),
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    TextSpan(
                                      text: " Rs/min",
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "Charging: ",
                                      style: GoogleFonts.poppins(
                                        color: secondaryTextColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    TextSpan(
                                      text: parkingLotsList
                                          .parking![index].electricityCharge
                                          .toString(),
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    TextSpan(
                                      text: " Rs/percent",
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "Parking: ",
                                      style: GoogleFonts.poppins(
                                        color: secondaryTextColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    TextSpan(
                                      text: parkingLotsList
                                          .parking![index].occupied
                                          .toString(),
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "Total Lots: ",
                                      style: GoogleFonts.poppins(
                                        color: secondaryTextColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    TextSpan(
                                      text: parkingLotsList.parking![index].lots
                                          .toString(),
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
                itemCount: parkingLotsList.parking!.length,
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
