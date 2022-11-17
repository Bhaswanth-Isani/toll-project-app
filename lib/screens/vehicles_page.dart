import 'package:auto_route/auto_route.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../routes/router.gr.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../constants/theme.dart';
import '../repositories/vehicle_repository.dart';
import '../widgets/registration_text_input.dart';

class VehiclesPage extends StatefulHookConsumerWidget {
  const VehiclesPage({Key? key}) : super(key: key);

  @override
  VehiclesPageState createState() => VehiclesPageState();
}

class VehiclesPageState extends ConsumerState<VehiclesPage> {
  @override
  void initState() {
    super.initState();
    ref.read(vehicleRepositoryProvider.notifier).getVehicles();
  }

  @override
  Widget build(BuildContext context) {
    final vehiclesList = ref.watch(vehicleRepositoryProvider);

    final amountController = useTextEditingController();

    Widget popupBuilder(BuildContext context, String vehicleId) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        title: Text(
          "Add Amount",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: RegistrationTextInput(
          textEditingController: amountController,
          error: false,
          errorText: "Add some amount",
          label: "AMOUNT",
          loading: false,
          password: false,
          type: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () {
              AutoRouter.of(context).pop();
              amountController.clear();
            },
            child: Text(
              "CANCEL",
              style: GoogleFonts.poppins(
                color: errorColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
            ),
            onPressed: () {
              ref.read(vehicleRepositoryProvider.notifier).addAmount(
                    vehicleId: vehicleId,
                    amount: int.parse(
                      amountController.text,
                    ),
                  );

              AutoRouter.of(context).pop();
              amountController.clear();
            },
            child: Text(
              "ADD",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      );
    }

    return Container(
      color: scaffoldBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.only(
          right: 20,
          left: 20,
          top: 10,
        ),
        child: ListView.separated(
            physics: const BouncingScrollPhysics(),
            itemCount: vehiclesList.vehicles!.length,
            separatorBuilder: (context, index) {
              return const SizedBox(
                height: 16,
              );
            },
            itemBuilder: (context, index) {
              if (index == vehiclesList.vehicles!.length - 1) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    VehicleTile(
                      vehiclesList: vehiclesList,
                      index: index,
                      ref: ref,
                      popupBuilder: popupBuilder,
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    GestureDetector(
                      onTap: () {
                        AutoRouter.of(context)
                            .push(RegisterVehicleRoute(initial: false));
                      },
                      child: DottedBorder(
                        borderType: BorderType.RRect,
                        radius: const Radius.circular(8),
                        dashPattern: const [10, 10, 10, 10],
                        strokeCap: StrokeCap.round,
                        strokeWidth: 2,
                        child: Container(
                          height: 230,
                          width: double.infinity,
                          alignment: Alignment.center,
                          child: const Center(
                            child: Icon(
                              FeatherIcons.plusCircle,
                              size: 48,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                  ],
                );
              }

              return VehicleTile(
                vehiclesList: vehiclesList,
                index: index,
                ref: ref,
                popupBuilder: popupBuilder,
              );
            }),
      ),
    );
  }
}

class VehicleTile extends StatelessWidget {
  const VehicleTile({
    Key? key,
    required this.vehiclesList,
    required this.index,
    required this.ref,
    required this.popupBuilder,
  }) : super(key: key);

  final VehicleOutput vehiclesList;
  final int index;
  final WidgetRef ref;
  final Widget Function(BuildContext context, String vehicleId) popupBuilder;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 230,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
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
                          vehicleId: vehiclesList.vehicles![index].databaseId,
                        ),
                    child: Icon(
                      vehiclesList.vehicles?[index].paymentType == "SINGLE"
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
                          vehicleId: vehiclesList.vehicles![index].databaseId,
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
                  context: context,
                  builder: (BuildContext context) => popupBuilder(
                      context, vehiclesList.vehicles![index].databaseId),
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
  }
}
