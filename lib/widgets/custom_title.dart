import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/theme.dart';

class CustomTitle extends StatelessWidget {
  const CustomTitle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Recent Transactions",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: primaryTextColor,
            ),
          ),
          Text(
            "See all",
            style: GoogleFonts.poppins(color: secondaryTextColor),
          ),
        ],
      ),
    );
  }
}
