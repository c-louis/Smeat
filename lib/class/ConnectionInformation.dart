import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:retry/retry.dart';

/// A class use in all the application to communicate with the server
///
/// [address], [port], [username] must be provide before doing anything
/// Initilisze those before connecting or reading
/// Always close the Connection with [close]
class ConnectionInformation {
  /// The socket handling the connection
  late RawSocket _socket;
  late StreamSubscription<RawSocketEvent> _eventHandler;

  /// Message queue
  final Queue<String> _messages = Queue<String>();

  /// The address the socket should connect to
  late String address;

  /// The port the socket should connect to
  late String port;

  /// The username use to loggin into the Teams server
  late String username;

  /// To be able to reconnect with a different connection
  bool hasConnected = false;

  /// [team], [channel], [thread] are used to identify what the user is doing
  User? user;
  Team? team;
  Channel? channel;
  Thread? thread;

  /// [_cachedTeams] is use to Cache Teams data and avoid spamming requests
  final List<Team> _cachedTeams = List<Team>.empty(growable: true);

  /// [_cachedUsers] is use to Cache Users data and avoid spamming requests
  final List<User> _cachedUsers = List<User>.empty(growable: true);

  /// Getters
  List<User> get cachedUsers => _cachedUsers;

  List<Team> get cachedTeams => _cachedTeams;

  List<Channel> get cachedChannels =>
    team != null ? team!.channels : List<Channel>.empty();
  List<Thread> get cachedThreads =>
      channel != null ? channel!.threads : List<Thread>.empty();

  List<Message> get cachedMessages =>
    thread != null ? thread!.messages : List<Message>.empty();

  /// Setters
  set setTeam(Team t) => team = t;
  set setChannel(Channel c) => channel = c;
  set setThread(Thread t) => thread = t;

  /// Connect the socket to [address] and [port] and loggin with [username]
  Future<bool> connect() async {
    if (hasConnected) {
      await _eventHandler.cancel();
      _messages.clear();
      await _socket.close();
      user = null;
      team = null;
      channel = null;
      thread = null;
    }
    try {
      _socket = await retry(
        () async => await RawSocket.connect(address, int.parse(port)),
        retryIf: (e) => e is SocketException || e is TimeoutException,
        maxDelay: Duration(seconds: 10),
      );
      //await assertResponse("wesh");
    } catch (e) {
      print(e);
      return Future.value(false);
    }

    hasConnected = true;

    sendMessage('TCP LOGIN ' + username);
    var answer = await readMessage();

    if (answer.contains('ERR') == true || answer.contains('MATR') == true) {
      return Future.value(false);
    }

    sendMessage('TCP USET');
    sendMessage('TCP USEC');
    sendMessage('TCP USETR');

    _eventHandler = _socket.listen((RawSocketEvent t) async {
      if (t == RawSocketEvent.read) {
        await loadMessage();
      }
    }, onDone: () {
      print('Connection closed !');
    }, onError: (Object error, StackTrace st) {
      print('Socket Error $error, $st');
    });

    return Future.value(true);
  }

  /// Use to close [_socket]
  void close() {
    _socket.close();
  }

  void processMessage() {
    for (var s in _messages) {
      if (s.contains('TCP EV')) {
        var sub = s.split('"');
        switch (sub[0].trim()) {
          case 'TCP EV1':
            {
              var u = User(sub[1], name: sub[3], status: true);
              if (!_cachedUsers.contains(u)) _cachedUsers.add(u);
            }
            break;
          case 'TCP EV2':
            {
              var u = _cachedUsers.firstWhere(
                  (element) => element.uuid == sub[1],
                  orElse: () => User(sub[1], name: sub[3]));
              u.status = false;
            }
            break;
          case 'TCP EV3':
            {
              var from = _cachedUsers.firstWhere(
                  (element) => element.uuid == sub[1],
                  orElse: () => User(sub[1]));
              var message = sub[3];
              print('Received a message from : ${from.uuid} > $message');
            }
            break;
          case 'TCP EV4':
            {
              /*var t =
                  _cachedTeams.firstWhere((element) => element.uuid == sub[1]);
              // TODO New Reply In Thread !
               */
            }
            break;
          case 'TCP EV5':
            {
              var t = Team(sub[1], sub[3]);
              if (!_cachedTeams.contains(t)) _cachedTeams.add(t);
            }
            break;
          case 'TCP EV8':
            {
              var u = User(sub[1],
                  name: sub[3], status: (sub[5] == '1' ? true : false));
              if (!_cachedUsers.contains(u)) {
                _cachedUsers.add(u);
              }
            }
            break;
          case 'TCP EV9':
            {
              var t = Team(sub[1], sub[3], desc: sub[5]);
              if (!_cachedTeams.contains(t)) {
                _cachedTeams.add(t);
              }
            }
            break;
          case 'TCP EV10':
            {
              var c = Channel(sub[1], sub[3], sub[5]);
              if (!team!.channels.contains(c)) {
                team!.channels.add(c);
              }
            }
            break;
          case 'TCP EV11':
            {
              var u = _cachedUsers.firstWhere(
                  (element) => element.uuid == sub[3],
                  orElse: () => User(sub[3]));
              var thr = Thread(sub[1], u, sub[7], sub[9], sub[5]);
              if (!channel!.threads.contains(thr)) {
                channel!.threads.add(thr);
              }
            }
            break;
          case 'TCP EV12':
            {
              print(s);
              var u = _cachedUsers.firstWhere(
                  (element) => element.uuid == sub[3],
                  orElse: () => User(sub[3]));
              var m = Message(u, sub[5], sub[7]);
              if (!thread!.messages.contains(m)) thread!.messages.add(m);
            }
            break;
          case 'TCP EV13':
            {
              // TODO List of private messages
            }
            break;
          case 'TCP EV20':
            {
              user = User(sub[1], name: sub[3], status: true);
              /// TODO ev20
            }
            break;
          case 'TCP EV24':
            {
              var t = Team(sub[1], sub[3], desc: sub[5]);
              if (!_cachedTeams.contains(t)) {
                _cachedTeams.add(t);
              }
            }
            break;

          /// TCP EV[6, 7, 14, 15, 16, 17, 18, 19, 21, 22, 23] doesn't need to be catch
          default:
            {
              print("Event type not handled : '${sub[0]}' ($s)");
            }
            break;
        }
      } else {
        print('Error : $s');
      }
    }
    _messages.removeFirst();
  }

  Future<void> loadMessage() async {
    var response = StringBuffer();
    await Future.doWhile(() async {
      var endOfResponse = false;
      // Number of bits available to read
      while (_socket.available() > 0) {
        response.writeln((String.fromCharCodes(_socket.read()!)).trim());
        endOfResponse = true;
        await Future.delayed(Duration(milliseconds: 300));
      }
      if (endOfResponse == true) return false;

      await Future.delayed(Duration(milliseconds: 300));
      return true;
    }).timeout(Duration(seconds: 1), onTimeout: () {});

    print('Got a response : ${response.toString()}');
    var lrs = response.toString().split('\n');
    for (var s in lrs) {
      if (s.isNotEmpty) _messages.add(s);
    }
  }

  /// read in [_socket] and return the string or an empty string
  Future<String> readMessage() async {
    if (_messages.isNotEmpty) {
      return _messages.removeFirst();
    }
    await loadMessage();
    return _messages.isNotEmpty ? _messages.removeFirst() : '';
  }

  /// Convert [message] to codec and send in [_socket]
  void sendMessage(String message) {
    print('Sending message $message');
    var toSend = Utf8Codec().encode('$message\n');
    _socket.write(toSend);
  }

  /// Load teams from the server or return [_cachedTeams]
  Future<List<Team>> loadTeams() async {
    sendMessage('TCP LIST');
    await loadMessage();
    processMessage();

    return cachedTeams;
  }

  /// Load Channel from the server accordind to [t]
  Future<List<Channel>> loadChannels(Team? t) async {
    t ??= team!;
    sendMessage('TCP SUB ' + t.uuid);
    sendMessage('TCP USET ' + t.uuid);
    sendMessage('TCP USEC');
    sendMessage('TCP USETR');
    sendMessage('TCP LIST');

    await loadMessage();
    processMessage();

    return t.channels;
  }

  /// Load Thread from the server according [c]
  Future<List<Thread>> loadThreads(Channel? c) async {
    c ??= channel!;
    sendMessage('TCP SUB ' + team!.uuid);
    sendMessage('TCP USET ' + team!.uuid);
    sendMessage('TCP USEC ' + c.uuid);
    sendMessage('TCP USETR');
    sendMessage('TCP LIST');

    await loadMessage();
    processMessage();

    return c.threads;
  }

  Future<List<Message>> loadMessages(Thread? c) async {
    c ??= thread!;
    sendMessage('TCP SUB ' + team!.uuid);
    sendMessage('TCP USET ' + team!.uuid);
    sendMessage('TCP USEC ' + channel!.uuid);
    sendMessage('TCP USETR ' + c.uuid);
    sendMessage('TCP LIST');

    await loadMessage();
    processMessage();

    return c.messages;
  }

  /// Compare answer to [response] return [bool]
  Future<void> assertResponse(String response) async {
    var answer = await readMessage();
    if (answer != response) {
      throw ('Got $answer, Expected $response');
    }
  }
  
  Future<void> addTeam(String name, String desc) async {
    sendMessage('TCP USET');
    sendMessage('TCP CREATE "$name" "$desc"');

    await loadMessage();
    processMessage();
  }

  Future<void> addChannel(String name, String desc) async {
    sendMessage('TCP USET ${team!.uuid}');
    sendMessage('TCP CREATE "$name" "$desc"');

    await loadMessage();
    processMessage();
  }

  Future<void> addThread(String name, String desc) async {
    sendMessage('TCP USET ${team!.uuid}');
    sendMessage('TCP USEC ${channel!.uuid}');
    sendMessage('TCP CREATE "$name" "$desc"');

    await loadMessage();
    processMessage();
  }

  Future<void> addMessage(String message) async {
    sendMessage('TCP USET ${team!.uuid}');
    sendMessage('TCP USEC ${channel!.uuid}');
    sendMessage('TCP USETR ${thread!.uuid}');
    sendMessage('TCP CREATE "$message"');

    await loadMessage();
    processMessage();
  }
}

class Team {
  late final String uuid;
  late final String name;
  late final String desc;
  final List<Channel> channels = List<Channel>.empty(growable: true);

  Team(this.uuid, this.name, {this.desc = ''});

  @override
  bool operator ==(Object other) => other is Team && other.uuid == uuid;

  @override
  int get hashCode => uuid.hashCode;
}

class Channel {
  late final String uuid;
  late final String name;
  late final String description;
  List<Thread> threads = List<Thread>.empty(growable: true);

  Channel(String uuid, String name, String description)
      : uuid = uuid,
        name = name,
        description = description;

  @override
  bool operator ==(Object other) => other is Channel && other.uuid == uuid;

  @override
  int get hashCode => uuid.hashCode;
}

class Thread {
  late final String uuid;
  late final User user;
  late final String title;
  late final String content;
  late final String time;
  List<Message> messages = List<Message>.empty(growable: true);

  Thread(this.uuid, this.user, this.title, this.content, this.time);

  @override
  bool operator ==(Object other) => other is Thread && other.uuid == uuid;

  @override
  int get hashCode => uuid.hashCode;
}

class User {
  late final String uuid;
  late final String name;
  late final bool status;

  User(this.uuid, {this.name = '', this.status = false});

  @override
  bool operator ==(Object other) => other is User && other.uuid == uuid;

  @override
  int get hashCode => uuid.hashCode;
}

class Message {
  late final User user;
  late final String time;
  late final String message;

  Message(this.user, this.time, this.message);

  @override
  bool operator ==(Object other) =>
      other is Message && other.user == user && other.time == time;

  @override
  int get hashCode => user.hashCode;
}
