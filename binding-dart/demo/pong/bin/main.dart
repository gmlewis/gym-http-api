// -*- compile-command: "cd .. && ./df.sh"; -*-

import 'package:gym/gym.dart';

main(List<String> arguments) async {
  var client = GymClient(debug: false);

  // Create environment instance.
  var id = await client.create('Pong-v0');
  print('id=$id');

  // Take a few random steps.
  await client.reset(id);
  dynamic lastObservation;
  for (var i = 0; i < 5; i++) {
    var action = await client.sampleAction(id);
    var stepResult = await client.step(id, action);
    lastObservation = stepResult.observation;
  }

  // Produce an image from the last video frame and
  // save it to pong.png.
  writePNG(lastObservation, 'pong.png');

  await client.close(id);
}
