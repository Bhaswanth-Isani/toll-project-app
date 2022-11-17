import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../constants/theme.dart';
import '../repositories/vehicle_repository.dart';

class VehicleCardSwiper extends ConsumerWidget {
  const VehicleCardSwiper({
    required this.popupBuilder,
    required this.higherContext,
    Key? key,
  }) : super(key: key);

  final Widget Function(BuildContext, String) popupBuilder;
  final BuildContext higherContext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiclesList = ref.watch(vehicleRepositoryProvider);

    if (vehiclesList.vehicles == null) {
      ref.read(vehicleRepositoryProvider.notifier).getVehicles();
    }

    return vehiclesList.vehicles != null
        ? Swiper(
            itemCount: vehiclesList.vehicles!.length,
            itemBuilder: (context, index) {
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: cardColor,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              vehiclesList.vehicles?[index].rfid ?? "",
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: scaffoldBackgroundColor,
                              ),
                            ),
                            Text(
                              vehiclesList.vehicles?[index].licensePlate ?? "",
                              style: GoogleFonts.poppins(
                                color: secondaryTextColor,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          ],
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => ref
                                  .read(vehicleRepositoryProvider.notifier)
                                  .updateType(
                                    vehicleId: vehiclesList
                                        .vehicles![index].databaseId,
                                  ),
                              child: Icon(
                                vehiclesList.vehicles?[index].paymentType ==
                                        "SINGLE"
                                    ? FeatherIcons.chevronDown
                                    : FeatherIcons.chevronsDown,
                                color: Colors.greenAccent,
                              ),
                            ),
                            const SizedBox(
                              width: 16,
                            ),
                            GestureDetector(
                              onTap: () => ref
                                  .read(vehicleRepositoryProvider.notifier)
                                  .updateBlock(
                                    vehicleId: vehiclesList
                                        .vehicles![index].databaseId,
                                  ),
                              child: Icon(
                                FeatherIcons.zap,
                                color: vehiclesList.vehicles![index].block
                                    ? secondaryTextColor
                                    : Colors.greenAccent,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "BALANCE",
                          style: GoogleFonts.poppins(
                            color: secondaryTextColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => showDialog(
                            context: higherContext,
                            builder: (BuildContext context) => popupBuilder(
                                context,
                                vehiclesList.vehicles![index].databaseId),
                          ),
                          child: Text(
                            "₹${vehiclesList.vehicles?[index].amount}",
                            style: GoogleFonts.poppins(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: scaffoldBackgroundColor,
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              );
            },
            itemHeight: 230,
            itemWidth: double.infinity,
            layout: SwiperLayout.TINDER,
          )
        : const SizedBox(
            height: 230,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
  }
}
