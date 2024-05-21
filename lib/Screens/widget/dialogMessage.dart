import 'package:flutter/material.dart';
import 'package:overlay_progress_indicator/overlay_progress_indicator.dart';

dialogPrograss(BuildContext context) async {
  OverlayProgressIndicator.show(
    context: context,
    backgroundColor: Colors.black45,
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(
            height: 10,
          ),
          const Text(
            'Loading',
          ),
          GestureDetector(
              onTap: () {
                OverlayProgressIndicator.hide();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.blue),
              ))
        ],
      ),
    ),
  );
}
