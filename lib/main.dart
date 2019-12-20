import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Json Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: JsonDemo(title: 'Json Demo'),
    );
  }
}

class JsonDemo extends StatelessWidget {
  JsonDemo({Key key, this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(this.title),
        ),
        body: Center(
          child: FutureBuilder<JsonDemoData>(
            future: fetchJsonDemoData(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Column(children: <Widget>[
                  Text(snapshot.data.string),
                  Text(snapshot.data.integer.toString()),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: snapshot.data.arrayofobjects
                          .map((row) => Text(row.key))
                          .toList()),
                  Text(snapshot.data.object.key),
                ]);
              } else if (snapshot.hasError) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text('An error occured ' + snapshot.error)
                  ],
                );
              }
              return Center(child: CircularProgressIndicator());
            },
          ),
        ));
  }
}

Future<JsonDemoData> fetchJsonDemoData() async {
  try {
    final response = await http
        .get(
            'https://s3-eu-west-1.amazonaws.com/kaleidosstudio.tutorial/flutter/json_example/data.json')
        .timeout(Duration(seconds: 5));

    if (response.statusCode == 200) {
      return compute(parseJsonDemoData, response.body);
    } else {
      throw Exception('Failed to load');
    }
  } on SocketException catch (e) {
    throw Exception('Failed to load');
  }
}

JsonDemoData parseJsonDemoData(String responseBody) {
  final parsed = JsonDemoData.fromJson(json.decode(responseBody));
  return parsed;
}

class JsonDemoData {
  final String string;
  final int integer;
  final List<String> array;
  final List<SingleObjectStruct> arrayofobjects;
  final SingleObjectStruct object;

  JsonDemoData(
      {this.string,
      this.integer,
      this.array,
      this.arrayofobjects,
      this.object});

  factory JsonDemoData.fromJson(Map<String, dynamic> json) {
    return JsonDemoData(
        string: json['string'],
        integer: json['integer'],
        array: new List<String>.from(json['array']),
        arrayofobjects: (json['arrayofobjects'] as List)
            .map((i) => SingleObjectStruct.fromJson(i))
            .toList(),
        object: SingleObjectStruct.fromJson(json['object']));
  }
}

class SingleObjectStruct {
  final String key;

  SingleObjectStruct({this.key});

  factory SingleObjectStruct.fromJson(Map<String, dynamic> json) {
    return SingleObjectStruct(key: json['key']);
  }
}
