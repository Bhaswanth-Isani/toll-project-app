import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../constants/theme.dart';
import '../repositories/vehicle_repository.dart';
import '../routes/router.gr.dart';
import '../widgets/registration_text_input.dart';

class RegisterVehiclePage extends HookConsumerWidget {
  RegisterVehiclePage({Key? key, required this.initial}) : super(key: key);

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final bool initial;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextEditingController licensePlateController =
        useTextEditingController();
    final TextEditingController rfidController = useTextEditingController();

    final ValueNotifier<String> vehicleType = useState("Car");

    final ValueNotifier<bool> buttonPressed = useState<bool>(false);
    final ValueNotifier<bool> licensePlateError = useState<bool>(false);
    final ValueNotifier<bool> rfidError = useState<bool>(false);
    final ValueNotifier<bool> loading = useState<bool>(false);

    ref.listen(vehicleRepositoryProvider, (previous, next) {
      if (next.vehicles != null || next.vehicles != []) {
        AutoRouter.of(context).replaceAll([const RoutingRoute()]);
      } else if (next.error != null) {
        loading.value = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              next.error ?? "An error occurred",
              style: GoogleFonts.poppins(),
            ),
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      initial
                          ? "Register your first vehicle"
                          : "Register your next vehicle",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 24),
                    RegistrationTextInput(
                      loading: loading.value,
                      errorText: "Enter a valid license plate number",
                      error: licensePlateError.value,
                      textEditingController: licensePlateController,
                      label: "LICENSE PLATE NUMBER",
                      type: TextInputType.text,
                      password: false,
                      onChanged: (value) {
                        if (licensePlateController.value.text.trim() == "" &&
                            !licensePlateError.value &&
                            buttonPressed.value) {
                          licensePlateError.value = true;
                        } else if (licensePlateController.value.text.trim() !=
                                "" &&
                            licensePlateError.value &&
                            buttonPressed.value) {
                          licensePlateError.value = false;
                        }
                      },
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    RegistrationTextInput(
                      loading: loading.value,
                      errorText: "Enter you vehicle's RFID",
                      error: rfidError.value,
                      textEditingController: rfidController,
                      label: "RFID",
                      type: TextInputType.text,
                      password: false,
                      onChanged: (value) {
                        if (rfidController.value.text.trim() == "" &&
                            !rfidError.value &&
                            buttonPressed.value) {
                          rfidError.value = true;
                        } else if (rfidController.value.text.trim() != "" &&
                            rfidError.value &&
                            buttonPressed.value) {
                          rfidError.value = false;
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "VEHICLE TYPE",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xffbdbdbd),
                      ),
                    ),
                    DropdownButton(
                        borderRadius: BorderRadius.circular(4),
                        style: GoogleFonts.poppins(
                          color: primaryTextColor,
                          fontWeight: FontWeight.w500,
                        ),
                        isExpanded: true,
                        value: vehicleType.value,
                        icon: const Icon(FeatherIcons.chevronDown),
                        items: const [
                          DropdownMenuItem(
                            value: "Car",
                            child: Text(
                              "CAR",
                            ),
                          ),
                          DropdownMenuItem(
                            value: "Truck",
                            child: Text(
                              "TRUCK",
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          vehicleType.value = value!;
                        }),
                    const SizedBox(
                      height: 40,
                    ),
                    SizedBox(
                      height: 60,
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                        ),
                        onPressed: loading.value
                            ? null
                            : () {
                                if (!buttonPressed.value) {
                                  buttonPressed.value = true;

                                  if (licensePlateController.value.text
                                          .trim() ==
                                      "") {
                                    licensePlateError.value = true;
                                  }

                                  if (rfidController.value.text.trim() == "") {
                                    rfidError.value = true;
                                  }
                                }

                                if (buttonPressed.value &&
                                    !licensePlateError.value &&
                                    !rfidError.value) {
                                  loading.value = true;
                                  ref
                                      .read(vehicleRepositoryProvider.notifier)
                                      .registerVehicle(
                                        rfid: rfidController.text,
                                        licensePlate:
                                            licensePlateController.text,
                                        vehicleType: vehicleType.value,
                                      );
                                }
                              },
                        child: loading.value
                            ? const CircularProgressIndicator()
                            : Text(
                                "REGISTER",
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
