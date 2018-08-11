// -*- compile-command: "dart cartpole.dart"; -*-

import 'dart:async';

import 'package:gym/gym.dart';

main() async {
  var client = GymClient();

  // Test the API for listing all instances.
  var insts = await client.listAll();
}
