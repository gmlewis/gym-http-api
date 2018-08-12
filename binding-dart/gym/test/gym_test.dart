// -*- compile-command: "cd .. && ./df.sh"; -*-

import 'package:test/test.dart';

import 'package:gym/gym.dart';

void main() {
  group('step result', () {
    test('done is not null', () {
      var stepResult = convertStepResult({});
      expect(stepResult.done, isNotNull);
    });
  });
}
