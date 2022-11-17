import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/theme.dart';

class RegistrationTextInput extends StatelessWidget {
  const RegistrationTextInput({
    Key? key,
    required this.label,
    required this.type,
    required this.password,
    required this.textEditingController,
    required this.error,
    required this.errorText,
    required this.loading,
    this.onChanged,
  }) : super(key: key);

  final String label;
  final TextInputType type;
  final bool password;
  final TextEditingController textEditingController;
  final bool error;
  final String errorText;
  final Function(String)? onChanged;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: const Color(0xffbdbdbd),
          ),
        ),
        TextFormField(
          enabled: !loading,
          controller: textEditingController,
          onChanged: onChanged,
          keyboardType: type,
          obscureText: password,
          cursorColor: primaryColor.withOpacity(0.6),
          decoration: InputDecoration(
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(
                color: errorColor.withOpacity(0.6),
                width: 2,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(
                color: error
                    ? errorColor.withOpacity(0.6)
                    : primaryColor.withOpacity(0.6),
                width: 2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(
                color: error ? errorColor : primaryColor,
                width: 2,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(
                color: error
                    ? errorColor.withOpacity(0.6)
                    : primaryColor.withOpacity(0.6),
                width: 2,
              ),
            ),
          ),
          style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        ),
        error
            ? Text(
                errorText,
                style: GoogleFonts.poppins(color: errorColor),
              )
            : Text(
                "",
                style: GoogleFonts.poppins(color: errorColor),
              )
      ],
    );
  }
}
