// -*- compile-command: "dartfmt -w . && dart main.dart"; -*-

import 'package:cartpole/cartpole.dart' as cartpole;
import 'package:gym/gym.dart';

main(List<String> arguments) async {
  var client = GymClient();

  // // Test the API for listing all instances.
  // var insts = await client.listAll();
  // print('insts=$insts');

  var id = await client.create('CartPole-v0');
  print('id=$id');
}

/* BAD:
b'POST /v1/envs/ HTTP/1.1\r\nuser-agent: Dart/2.0 (dart:io)\r\ncontent-type: application/x-www-form-urlencoded; charset=utf-8\r\naccept-encoding: gzip\r\ncontent-length: 18\r\nhost: localhost:5000\r\n\r\n'

GOOD:
b'POST /v1/envs/ HTTP/1.1\r\nHost: localhost:5000\r\nUser-Agent: Go-http-client/1.1\r\nContent-Length: 24\r\nContent-Type: application/json\r\nAccept-Encoding: gzip\r\n\r\n{"env_id":"CartPole-v0"}'
*/
