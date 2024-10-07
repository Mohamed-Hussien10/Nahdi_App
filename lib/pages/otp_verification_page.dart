// ignore_for_file: must_be_immutable

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nahdy/components/build_otp_field.dart';

class OtpVerificationPage extends StatefulWidget {
  OtpVerificationPage(this.email, {super.key});
  late String email;

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  // Create a TextEditingController for each digit.
  final TextEditingController _otpController1 = TextEditingController();
  final TextEditingController _otpController2 = TextEditingController();
  final TextEditingController _otpController3 = TextEditingController();
  final TextEditingController _otpController4 = TextEditingController();

  // This function retrieves the OTP input
  String getOtp() {
    return _otpController1.text +
        _otpController2.text +
        _otpController3.text +
        _otpController4.text;
  }

  @override
  void dispose() {
    // Dispose controllers when not needed
    _otpController1.dispose();
    _otpController2.dispose();
    _otpController3.dispose();
    _otpController4.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 100),
            const Text(
              'OTP Verification',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'We sent your code to ${widget.email}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
            const Text(
              'This code will expired in 01:00',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 35),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildOtpField(context, _otpController1, autoFocus: true),
                  buildOtpField(context, _otpController2),
                  buildOtpField(context, _otpController3),
                  buildOtpField(context, _otpController4),
                ],
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                String otp = getOtp();
                if (kDebugMode) {
                  print("Entered OTP: $otp");
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: const BorderSide(color: Colors.grey),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                child: Text(
                  'Verify',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Didn\'t receive OTP? ',
                ),
                InkWell(
                  onTap: () {},
                  child: const Text(
                    'Resend',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
