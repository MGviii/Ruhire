import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'config.dart';

class RealtimeClient {
  final AppConfig config;
  WebSocketChannel? _channel;
  Stream<dynamic>? _stream;

  RealtimeClient(this.config);

  Stream<dynamic> connect() {
    _channel = WebSocketChannel.connect(Uri.parse(config.websocketUrl));
    _stream = _channel!.stream;
    return _stream!;
  }

  void send(dynamic data) => _channel?.sink.add(data);
  Future<void> close() async => _channel?.sink.close();
}
