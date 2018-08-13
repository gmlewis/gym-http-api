// -*- compile-command: "pushd .. && ./df.sh && popd && dart main.dart"; -*-

import 'package:gym/gym.dart';

main(List<String> arguments) async {
  var client = GymClient(debug: true);

  // Test the API for listing all instances.
  var insts = await client.listAll();
  print('insts=$insts');

  // Close all open instances.
  // insts.forEach((k, v) async {
  //   await client.close(k);
  // });

  // Create environment instance.
  var id = await client.create('CartPole-v0');
  print('id=$id');

  // Test space information APIs.
  var actionSpace = await client.actionSpace(id);
  print('actionSpace=$actionSpace');
  var observationSpace = await client.observationSpace(id);
  print('observationSpace=$observationSpace');

  // Start monitoring to a temp directory.
  await client.startMonitor(id, '/tmp/cartpole-monitor');

  // Run through an episode.
  print('Starting new episode...');
  var obs = await client.reset(id);
  print('First observation: $obs');
  while (true) {
    // Sample a random action to take.
    var action = await client.sampleAction(id);
    print('Taking action: $action');

    // Unnecessary; demonstrates the ContainsAction API.
    var c = await client.containsAction(id, action);
    if (!c) throw ('sampled action not contained in space');

    // Take the action, getting a new observation, a reward,
    // and a flag indicating if the episode is done.
    var stepResult = await client.step(id, action);
    obs = stepResult.observation;
    print('reward: ${stepResult.reward}, -- observation: $obs');
    if (stepResult.done) break;
  }

  await client.closeMonitor(id);
  await client.close(id);
}
