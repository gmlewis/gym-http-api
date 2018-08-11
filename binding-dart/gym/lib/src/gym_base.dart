// -*- compile-command: "dartfmt -w . && dart gym_base.dart"; -*-

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

const _defaultBaseURL = "http://localhost:5000";

/// Creates a Model Object from the JSON [input]
typedef T JSONConverter<S, T>(S input);

JSONConverter<Map<String, dynamic>, Map<String, String>> FieldMap(
    String fieldName) {
  return (Map<String, dynamic> json) {
    final Map<String, dynamic> value = json[fieldName];
    return value.map((String key, dynamic val) => MapEntry(key, val as String));
  };
}

JSONConverter<Map<String, dynamic>, String> FieldString(String fieldName) {
  return (Map<String, dynamic> json) {
    final dynamic value = json[fieldName];
    return value as String;
  };
}

class GymClient {
  GymClient({this.baseURL = _defaultBaseURL, http.Client client})
      : this.client = client == null ? http.Client() : client {
    if (this.baseURL.endsWith('/')) {
      this.baseURL = this.baseURL.substring(0, this.baseURL.length - 1);
    }
  }

  String baseURL;
  final http.Client client;

  dispose() {
    client.close();
  }

  Future<Map<String, String>> listAll() {
    return getJSON('/v1/envs/', convert: FieldMap('all_envs')).then((resp) {
      print('resp=$resp');
      return resp;
    });
  }

  Future<String> create(String envID) {
    return postJSON('/v1/envs/', {'env_id': envID},
            convert: FieldString('instance_id'))
        .then((resp) {
      print('resp=$resp');
      return resp;
    });
  }

  @visibleForTesting
  Future<T> getJSON<S, T>(
    String path, {
    Map<String, String> headers,
    Map<String, String> params,
    JSONConverter<S, T> convert,
  }) {
    return _request("GET", path, headers: headers, params: params)
        .then((response) {
      print('response=$response');

      final json = jsonDecode(response.body);
      print('json=$json');
      convert ??= (input) => input as T;
      final result = convert(json);
      print('result=$result');
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
    // final url = _buildURL(path, params);
    body = jsonEncode(body);
    headers ??= {};
    headers['content-type'] = 'application/json';
    print('postJSON: headers=$headers, body=$body');
    // return http.post(url, headers: headers, body: body)
    return _request("POST", path, headers: headers, params: params, body: body)
        .then((response) {
      print('response=$response');

      final json = jsonDecode(response.body);
      print('json=$json');
      convert ??= (input) => input as T;
      final result = convert(json);
      print('result=$result');
      return result;
    });
  }

  Future<http.Response> _request(String method, String path,
      {Map<String, String> headers,
      Map<String, dynamic> params,
      String body}) async {
    headers ??= {};
    if (method == "PUT" && body == null) {
      headers.putIfAbsent("Content-Length", () => "0");
    }

    final url = _buildURL(path, params);

    print('_request: method=$method, url=$url');
    var request = http.Request(method, Uri.parse(url));
    request.headers.addAll(headers);
    if (body != null) {
      request.body = body;
      print('request.body=${request.body}');
    }

    var streamedResponse = await client.send(request);

    var response = await http.Response.fromStream(streamedResponse);

    return response;
  }

  String _buildURL(String path, Map<String, String> params) {
    var queryString = "";

    if (params != null) {
      queryString = _buildQueryString(params);
    }

    var url = StringBuffer();

    if (!path.startsWith("http")) {
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
  if (q.length > 0) {
    return '?' + q;
  }

  return '';
}
