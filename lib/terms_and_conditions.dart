import 'package:flutter/material.dart';

class TermsAndConditionsPage extends StatefulWidget {
  const TermsAndConditionsPage({super.key});

  @override
  State<TermsAndConditionsPage> createState() => _TermsAndConditionsPageState();
}

class _TermsAndConditionsPageState extends State<TermsAndConditionsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Terms and Conditions',
          style: TextStyle(
            color: Colors.white, // Set the title color
            fontSize: 20, // Adjust the font size
          ),
        ),
        backgroundColor: Colors.blueAccent, // Set the AppBar background color
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Corrected padding here
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 20),
              const Text(
                'Welcome to JEAS App, a platform designed to connect service providers with clients seeking specific services. By accessing and using JEAS App, you agree to be bound by the following terms and conditions (the "Terms"). Please read these Terms carefully before using our services.'
                '\n\n1. Acceptance of Terms:\n'
                '  By registering, accessing, or using our services, you agree to be bound by these Terms and all terms incorporated by reference. If you do not agree to these Terms, you may not access or use JEAS App.'
                '\n\n 2. Modification of Terms:\n'
                'University of Jordan reserves the right to modify these Terms at any time. We will notify you of changes by updating the date at the top of these Terms and, if significant changes are made, by providing additional notice such as adding a statement to our homepage or sending you a notification. Your continued use of JEAS App after such modifications will constitute your acceptance of the revised Terms.'
                '\n\n3. Eligibility:\n'
                'You must be at least 18 years of age to use JEAS App. By agreeing to these Terms, you represent and warrant that you are of legal age and meet all of the foregoing eligibility requirements.'
                '\n\n4. Account Registration and Use:\n'
                'To access and use certain features of the app, you must register for an account. You are responsible for maintaining the confidentiality of your account and password and for all activities that occur under your account. You agree to immediately notify us of any unauthorized use of your account or password, or any other breach of security.'
                '\n\n5. Services Description:\n'
                'JEAS App provides a platform for users seeking job opportunities and services to connect with service providers. We do not provide these services directly; our role is solely to facilitate the connections between the users and service providers.'
                '\n\n6. User Conduct:\n'
                'You agree not to engage in any of the following prohibited activities: (i) copying, distributing, or disclosing any part of the app in any medium, including without limitation by any automated or non-automated “scraping”; (ii) using any automated system, including without limitation “robots,” “spiders,” “offline readers,” etc., to access the app in a manner that sends more request messages to the JEAS App servers than a human can reasonably produce in the same period by using a conventional online web browser; etc.'
                '\n\n7. Intellectual Property:\n'
                'All intellectual property rights in the app, its content, and the services are owned by University of Jordan or its licensors. You may not use such content without our prior written permission.'
                '\n\n8. Termination:\n'
                'We may terminate or suspend your account immediately, without prior notice or liability, for any reason whatsoever, including without limitation if you breach the Terms.'
                '\n\n9. Limitation of Liability:\n'
                'In no event will University of Jordan be liable for any indirect, incidental, special, consequential or punitive damages resulting from your access to or use of, or inability to access or use, the services or any content on the services, whether based on warranty, contract, tort (including negligence) or any other legal theory, whether or not University of Jordan has been informed of the possibility of such damage.'
                '\n\n10. Governing Law:\n'
                'These Terms shall be governed by and construed in accordance with the laws of Jordan, without regard to its conflict of law provisions.'
                '\n\n11. Dispute Resolution:\n'
                'Any disputes arising from these Terms or your use of the app will be resolved through final and binding arbitration, rather than in court.',
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('DONE'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
