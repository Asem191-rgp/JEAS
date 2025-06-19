import 'package:flutter/material.dart';

class LoadingPage extends StatelessWidget {
  final dynamic Function() function;

  const LoadingPage({
    required this.function,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FutureBuilder(
          future: function(),
          builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            Navigator.pop(context);
            return const Text("Done");
          },
        ),
      ),
    );
  }
}
