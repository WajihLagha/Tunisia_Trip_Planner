import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

Widget nextButton() {
  return Container(
    width: double.infinity,
    decoration: BoxDecoration(
      color: HexColor("#56AB91"), // Mint Green
      borderRadius: BorderRadius.circular(40),
      boxShadow: [
        BoxShadow(
          color: HexColor("#99E2B4").withValues(alpha: 0.5),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(40),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                "Next",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 8),
              Icon(
                Icons.arrow_right_alt,
                color: Colors.white,
                size: 30,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
