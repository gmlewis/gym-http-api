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

  group('toString', () {
    // StepResult

    test('StepResult.toString shows no args', () {
      var stepResult = StepResult().toString();
      expect(stepResult, 'StepResult()');
    });

    test('StepResult.toString shows observation', () {
      var stepResult = StepResult(observation: [0, 1, 2]).toString();
      expect(stepResult, 'StepResult(observation: [0, 1, 2])');
    });

    test('StepResult.toString shows reward', () {
      var stepResult = StepResult(reward: 1.0).toString();
      expect(stepResult, 'StepResult(reward: 1.0)');
    });

    test('StepResult.toString shows done', () {
      var stepResult = StepResult(done: false).toString();
      expect(stepResult, 'StepResult(done: false)');
    });

    test('StepResult.toString shows info', () {
      var stepResult = StepResult(info: [0, 'done']).toString();
      expect(stepResult, 'StepResult(info: [0, done])');
    });

    test('StepResult.toString shows all fields', () {
      var stepResult = StepResult(
        observation: [0, 1, 2],
        reward: -1.0,
        done: true,
        info: [0, 'done'],
      ).toString();
      expect(stepResult,
          'StepResult(observation: [0, 1, 2], reward: -1.0, done: true, info: [0, done])');
    });

    // Space

    test('Space.toString shows no args', () {
      var space = Space().toString();
      expect(space, 'Space()');
    });

    test('Space.toString shows name', () {
      var space = Space(name: 'Discreet').toString();
      expect(space, 'Space(name: Discreet)');
    });

    test('Space.toString shows shape', () {
      var space = Space(shape: [0, 1, 2]).toString();
      expect(space, 'Space(shape: [0, 1, 2])');
    });

    test('Space.toString shows low', () {
      var space = Space(low: [-1.0, 1.0]).toString();
      expect(space, 'Space(low: [-1.0, 1.0])');
    });

    test('Space.toString shows high', () {
      var space = Space(high: [-1.0, 1.0]).toString();
      expect(space, 'Space(high: [-1.0, 1.0])');
    });

    test('Space.toString shows n', () {
      var space = Space(n: 6).toString();
      expect(space, 'Space(n: 6)');
    });

    test('Space.toString shows numRows', () {
      var space = Space(numRows: 3).toString();
      expect(space, 'Space(numRows: 3)');
    });

    test('Space.toString shows matrix', () {
      var space = Space(matrix: [0.0, 1.0, 1.0, 0.0]).toString();
      expect(space, 'Space(matrix: [0.0, 1.0, 1.0, 0.0])');
    });

    test('Space.toString shows all fields', () {
      var space = Space(
        name: 'Box',
        shape: [0, 1, 2],
        low: [-1.0, 1.0],
        high: [-1.0, 1.0],
        n: 5,
        numRows: 3,
        matrix: [1.0, 0.0, 0.0, 1.0],
      ).toString();
      expect(space,
          'Space(name: Box, shape: [0, 1, 2], low: [-1.0, 1.0], high: [-1.0, 1.0], n: 5, numRows: 3, matrix: [1.0, 0.0, 0.0, 1.0])');
    });
  });
}
