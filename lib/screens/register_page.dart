import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../constants/theme.dart';
import '../repositories/auth_repository.dart';
import '../routes/router.gr.dart';
import '../widgets/registration_text_input.dart';

class RegisterPage extends HookConsumerWidget {
  RegisterPage({Key? key}) : super(key: key);

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextEditingController fullNameController = useTextEditingController();
    final TextEditingController emailController = useTextEditingController();
    final TextEditingController passwordController = useTextEditingController();

    final ValueNotifier<bool> buttonPressed = useState<bool>(false);
    final ValueNotifier<bool> fullNameError = useState<bool>(false);
    final ValueNotifier<bool> emailError = useState<bool>(false);
    final ValueNotifier<bool> passwordError = useState<bool>(false);
    final ValueNotifier<bool> loading = useState<bool>(false);

    ref.listen(authRepositoryProvider, (previous, next) {
      if (next.user != null) {
        AutoRouter.of(context).replace(RegisterVehicleRoute(initial: true));
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

    final user = ref.read(authRepositoryProvider.notifier).getUser();

    if (user != null) {
      AutoRouter.of(context).replace(const HomeRoute());
    }

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
                      "Create new account",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 24),
                    RegistrationTextInput(
                      loading: loading.value,
                      errorText: "Enter your name",
                      error: fullNameError.value,
                      textEditingController: fullNameController,
                      label: "FULL NAME",
                      type: TextInputType.text,
                      password: false,
                      onChanged: (value) {
                        if (value.trim() == "" &&
                            !fullNameError.value &&
                            buttonPressed.value) {
                          fullNameError.value = true;
                        } else if (value.trim() != "" &&
                            fullNameError.value &&
                            buttonPressed.value) {
                          fullNameError.value = false;
                        }
                      },
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    RegistrationTextInput(
                      loading: loading.value,
                      errorText: "Enter a valid email",
                      error: emailError.value,
                      textEditingController: emailController,
                      label: "E-MAIL",
                      type: TextInputType.emailAddress,
                      password: false,
                      onChanged: (value) {
                        if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                .hasMatch(value) &&
                            !emailError.value &&
                            buttonPressed.value) {
                          emailError.value = true;
                        } else if (RegExp(
                                    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                .hasMatch(value) &&
                            emailError.value &&
                            buttonPressed.value) {
                          emailError.value = false;
                        }
                      },
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    RegistrationTextInput(
                      loading: loading.value,
                      errorText: "Enter a password",
                      error: passwordError.value,
                      textEditingController: passwordController,
                      label: "PASSWORD",
                      type: TextInputType.text,
                      password: true,
                      onChanged: (value) {
                        if (value.trim() == "" &&
                            !passwordError.value &&
                            buttonPressed.value) {
                          passwordError.value = true;
                        } else if (value.trim() != "" &&
                            passwordError.value &&
                            buttonPressed.value) {
                          passwordError.value = false;
                        }
                      },
                    ),
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

                                  if (fullNameController.value.text.trim() ==
                                      "") {
                                    fullNameError.value = true;
                                  }

                                  if (!RegExp(
                                          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                      .hasMatch(emailController.value.text)) {
                                    emailError.value = true;
                                  }

                                  if (passwordController.value.text.trim() ==
                                      "") {
                                    passwordError.value = true;
                                  }
                                }

                                if (buttonPressed.value &&
                                    !emailError.value &&
                                    !passwordError.value &&
                                    !fullNameError.value) {
                                  loading.value = true;
                                  ref
                                      .read(authRepositoryProvider.notifier)
                                      .registerUser(
                                        email: emailController.text,
                                        password: passwordController.text,
                                        fullName: fullNameController.text,
                                      );
                                }
                              },
                        child: loading.value
                            ? const CircularProgressIndicator()
                            : Text(
                                "NEXT",
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          "Already have an account?",
                          style: GoogleFonts.poppins(),
                        ),
                        TextButton(
                          onPressed: () =>
                              AutoRouter.of(context).replace(LoginRoute()),
                          child: Text(
                            "Login",
                            style: GoogleFonts.poppins(color: primaryColor),
                          ),
                        ),
                      ],
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
