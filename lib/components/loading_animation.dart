import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LoadingAnimation extends StatelessWidget {
  const LoadingAnimation({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      // child: CircularProgressIndicator(),
      child: LoadingAnimationWidget.staggeredDotsWave(
        color: Color.fromARGB(255, 49, 131, 198),
        size: 50.0,
      ),
    );
  }
}
