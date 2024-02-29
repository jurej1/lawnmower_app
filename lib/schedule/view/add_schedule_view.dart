import 'package:flutter/material.dart';

class AddScheduleView extends StatelessWidget {
  const AddScheduleView({super.key});

  static route() {
    return MaterialPageRoute(
      builder: (context) {
        return const AddScheduleView();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
