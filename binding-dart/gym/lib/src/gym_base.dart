// -*- compile-command: "dartfmt -w . && dart gym_base.dart"; -*-

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

const _defaultBaseURL = 'http://localhost:5000';

/// Creates a Model Object from the JSON [input]
typedef T JSONConverter<S, T>(S input);

// StepResult is the resulting return value of a step operation.
class StepResult {
  StepResult({this.observation, this.reward, this.done, this.info});

  final dynamic observation; // Typically, int or List<double>.
  final double reward;
  final bool done;
  final dynamic info; // Debug information from OpenAI Gym.

  String toString() {
    return 'StepResult(observation: $observation, reward: $reward, done: $done, info: $info)';
  }
}

// Space stores information about an action space or an
// observation space.
class Space {
  Space(
      {this.name,
      this.shape,
      this.low,
      this.high,
      this.n,
      this.numRows,
      this.matrix});

  // Name is the name of the space, such as 'Box', 'HighLow',
  // or 'Discrete'.
  final String name;

  // Properties for Box spaces.
  List<int> shape;
  List<double> low;
  List<double> high;

  // Properties for Discrete spaces.
  int n;

  // Properties for HighLow spaces.
  int numRows;
  List<double> matrix;

  String toString() {
    return 'Space(name: $name, shape: $shape, low: $low, high: $high, n: $n, numRows: $numRows, matrix: $matrix)';
  }
}

Space convertSpaceResult(Map<String, dynamic> json) {
  final info = json['info'];
  return Space(
    name: info['name'] as String,
    shape: info.containsKey('shape') ? List<int>.from(info['shape']) : null,
    low: info.containsKey('low') ? List<double>.from(info['low']) : null,
    high: info.containsKey('high') ? List<double>.from(info['high']) : null,
    n: info['n'] as int,
    numRows: info['numRows'] as int,
    matrix:
        info.containsKey('matrix') ? List<double>.from(info['matrix']) : null,
  );
}

StepResult convertStepResult(Map<String, dynamic> json) {
  return StepResult(
    observation: json['observation'],
    reward: json['reward'] as double,
    done: (json['done'] as bool) ?? false,
    info: json['info'],
  );
}

JSONConverter<Map<String, dynamic>, bool> fieldBool(String fieldName) {
  return (Map<String, dynamic> json) {
    final dynamic value = json[fieldName];
    return value as bool;
  };
}

JSONConverter<Map<String, dynamic>, dynamic> fieldDynamic(String fieldName) {
  return (Map<String, dynamic> json) {
    final dynamic value = json[fieldName];
    return value;
  };
}

JSONConverter<Map<String, dynamic>, Map<String, String>> fieldMap(
    String fieldName) {
  return (Map<String, dynamic> json) {
    final Map<String, dynamic> value = json[fieldName];
    return value.map((String key, dynamic val) => MapEntry(key, val as String));
  };
}

JSONConverter<Map<String, dynamic>, String> fieldString(String fieldName) {
  return (Map<String, dynamic> json) {
    final dynamic value = json[fieldName];
    return value as String;
  };
}

class GymClient {
  GymClient({this.baseURL = _defaultBaseURL, this.debug = true}) {
    if (this.baseURL.endsWith('/')) {
      // Strip trailing slash.
      this.baseURL = this.baseURL.substring(0, this.baseURL.length - 1);
    }
  }

  String baseURL;
  bool debug;

  /// listAll lists all instantiated environments.
  /// The result maps between instance IDs and environment
  /// IDs.
  Future<Map<String, String>> listAll() {
    return getJSON('/v1/envs/', convert: fieldMap('all_envs')).then((resp) {
      if (debug) print('listAll: resp=$resp');
      return resp;
    });
  }

  /// create creates a new instance of an environment.
  Future<String> create(String envID) {
    return postJSON('/v1/envs/', {'env_id': envID},
            convert: fieldString('instance_id'))
        .then((resp) {
      if (debug) print('create: resp=$resp');
      return resp;
    });
  }

  // reset resets the environment instance.
  //
  // The resulting observation type may vary.
  // For discrete spaces, it is an int.
  // For vector spaces, it is a List<double>.
  Future<dynamic> reset(String id) {
    return postJSON('/v1/envs/$id/reset/', {},
            convert: fieldDynamic('observation'))
        .then((resp) {
      if (debug) print('reset: resp=$resp');
      return resp;
    });
  }

  /// step takes a step in the environment.
  ///
  /// The action type may vary.
  /// For discrete spaces, it should be an int.
  /// For vector spaces, it should be a List<double>.
  ///
  /// See reset for information on the observation type.
  Future<StepResult> step(String id, dynamic action, {render = false}) {
    return postJSON(
            '/v1/envs/$id/step/',
            {
              'action': action,
              'render': render,
            },
            convert: convertStepResult)
        .then((resp) {
      if (debug) print('step: resp=$resp');
      return resp;
    });
  }

  /// actionSpace fetches the action space.
  Future<Space> actionSpace(String id) {
    return getJSON('/v1/envs/$id/action_space/', convert: convertSpaceResult)
        .then((resp) {
      if (debug) print('actionSpace: resp=$resp');
      return resp;
    });
  }

  /// observationSpace fetches the observation space.
  Future<Space> observationSpace(String id) {
    return getJSON('/v1/envs/$id/observation_space/',
            convert: convertSpaceResult)
        .then((resp) {
      if (debug) print('observationSpace: resp=$resp');
      return resp;
    });
  }

  /// sampleAction samples an action uniformly.
  Future<dynamic> sampleAction(String id) {
    return getJSON('/v1/envs/$id/action_space/sample',
            convert: fieldDynamic('action'))
        .then((resp) {
      if (debug) print('sampleAction: resp=$resp');
      return resp;
    });
  }

  /// containsAction checks if an action is contained in the
  /// action space.
  ///
  /// Currently, only int action types are supported.
  Future<bool> containsAction(String id, dynamic action) {
    return getJSON('/v1/envs/$id/action_space/contains/$action',
            convert: fieldBool('member'))
        .then((resp) {
      if (debug) print('containsAction: resp=$resp');
      return resp;
    });
  }

  /// close closes the environment instance.
  Future<void> close(String id) {
    return postJSON('/v1/envs/$id/close/', {}).then((resp) {
      if (debug) print('close: resp=$resp');
    });
  }

  /// startMonitor starts monitoring the environment.
  Future<void> startMonitor(String id, String dir,
      {bool force = true, bool resume = false, bool videoCallable = false}) {
    return postJSON('/v1/envs/$id/monitor/start/', {
      'directory': dir,
      'force': force,
      'resume': resume,
      'video_callable': videoCallable,
    }).then((resp) {
      if (debug) print('startMonitor: resp=$resp');
    });
  }

  /// closeMonitor stops monitoring the environment.
  Future<void> closeMonitor(String id) {
    return postJSON('/v1/envs/$id/monitor/close/', {}).then((resp) {
      if (debug) print('closeMonitor: resp=$resp');
    });
  }

  /// upload uploads the monitor results from the directory
  /// to the Gym website.
  ///
  /// If apiKey is '', then the 'OPENAI_GYM_API_KEY'
  /// environment variable is used.
  Future<void> upload(String dir,
      {String apiKey = '', String algorithmID = ''}) {
    // TODO: Get apiKey from ENV if ''.
    var body = {'training_dir': dir, 'api_key': apiKey};
    if (algorithmID != '') body['algorithm_id'] = algorithmID;
    return postJSON('/v1/upload/', body).then((resp) {
      if (debug) print('upload: resp=$resp');
    });
  }

  /// shutdown stops the server.
  Future<void> shutdown() {
    return postJSON('/v1/upload/', {}).then((resp) {
      if (debug) print('shutdown: resp=$resp');
    });
  }

  @visibleForTesting
  Future<T> getJSON<S, T>(
    String path, {
    Map<String, String> headers,
    Map<String, String> params,
    JSONConverter<S, T> convert,
  }) {
    final url = _buildURL(path, params);
    return http.get(url, headers: headers).then((response) {
      final json = jsonDecode(response.body);
      if (debug) print('json=$json');
      convert ??= (input) => input as T;
      final result = convert(json);
      if (debug) print('result=$result');
      return result;
    });
  }

  @visibleForTesting
  Future<T> postJSON<S, T>(
    String path,
    dynamic body, {
    Map<String, String> headers,
    Map<String, String> params,
    JSONConverter<S, T> convert,
  }) {
    final url = _buildURL(path, params);
    body = json.encode(body);
    headers ??= {};
    headers['content-type'] = 'application/json';
    return http.post(url, headers: headers, body: body).then((response) {
      if (response.body == null || response.body.length == 0) return null;
      final json = jsonDecode(response.body);
      if (debug) print('json=$json');
      convert ??= (input) => input as T;
      final result = convert(json);
      if (debug) print('result=$result');
      return result;
    });
  }

  String _buildURL(String path, Map<String, String> params) {
    var queryString = '';
    if (params != null) {
      queryString = _buildQueryString(params);
    }

    var url = StringBuffer();
    if (!path.startsWith('http')) {
      url.write(baseURL);
      if (!path.startsWith('/')) {
        url.write('/');
      }
    }
    url.write(path);
    url.write(queryString);

    return url.toString();
  }
}

String _buildQueryString(Map<String, dynamic> params) {
  List<String> parts = [];
  for (var key in params.keys) {
    if (params[key] == null) {
      continue;
    }
    parts.add('$key=${Uri.encodeComponent(params[key].toString())}');
  }

  final q = parts.join('&');
  if (q.length == 0) {
    return '';
  }
  return '?' + q;
}
