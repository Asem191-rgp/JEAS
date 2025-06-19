// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Get Help'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Need Help?',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.lightBlue),
              onPressed: () {
                _launchPhoneCall('0796144780');
              },
              child: const Text(
                'Call Us',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 20.0),
            const Text(
              'Or send us an email:',
              style: TextStyle(fontSize: 18.0),
            ),
            const SizedBox(height: 10.0),
            ElevatedButton(
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.lightBlue),
              onPressed: () {
                _sendEmail();
              },
              child: const Text(
                'Send Email',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _launchPhoneCall(String phoneNumber) async {
    String url = 'tel:$phoneNumber';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _sendEmail() async {
    String emailAddress = 'graduationprojectjeas@gmail.com';
    String subject = 'Help Request';
    String body = 'Hello,\n\nI need assistance.';

    String mailtoUrl = 'mailto:$emailAddress?subject=$subject&body=$body';
    if (await canLaunch(mailtoUrl)) {
      await launch(mailtoUrl);
    } else {
      throw 'Could not launch $mailtoUrl';
    }
  }
}
