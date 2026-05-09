import 'package:bonded_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../services/shared_prefs_service.dart';
import '../core/constants/app_endpoints.dart';
import '../core/routes/app_routes.dart';

class SocketService extends GetxService {
  static SocketService get to => Get.find();

  IO.Socket? _socket;
  final RxBool isConnected = false.obs;

  @override
  void onInit() {
    super.onInit();
    debugPrint('SOCKET_DEBUG: SocketService Initializing...');
    initSocket();
  }

  void initSocket({String? token}) {
    final authToken = token ?? SharedPrefsService.getString('accessToken');
    if (authToken == null) {
      debugPrint('SOCKET_DEBUG: No access token found. Waiting for login...');
      return;
    }

    if (_socket != null) {
      debugPrint('SOCKET_DEBUG: Disposing existing socket connection.');
      _socket?.dispose();
    }

    final socketUrl = AppUrls.socket;

    debugPrint('SOCKET_DEBUG: Connecting to $socketUrl');
    debugPrint('SOCKET_DEBUG: Token: ${authToken.substring(0, 10)}...');

    _socket = IO.io(
      socketUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': authToken})
          .enableAutoConnect()
          .build(),
    );

    _socket?.onConnect((_) {
      debugPrint('SOCKET_DEBUG: Connected successfully to server');
      isConnected.value = true;
    });

    _socket?.onDisconnect((_) {
      debugPrint('SOCKET_DEBUG: Disconnected from server');
      isConnected.value = false;
    });

    _socket?.onConnectError((err) {
      debugPrint('SOCKET_DEBUG: Connection Error: $err');
      isConnected.value = false;

      // If unauthorized, redirect to login
      if (err.toString().toLowerCase().contains('unauthorized')) {
        if (!ApiService.isNavigatingToLogin &&
            Get.currentRoute != AppRoutes.LOGIN) {
          ApiService.isNavigatingToLogin = true;
          SharedPrefsService.delete('accessToken');
          SharedPrefsService.delete('refreshToken');
          Get.offAllNamed(AppRoutes.LOGIN);

          Future.delayed(const Duration(seconds: 2), () {
            ApiService.isNavigatingToLogin = false;
          });
        }
      }
    });

    _socket?.onError((err) {
      debugPrint('SOCKET_DEBUG: Socket Error: $err');
    });

    _socket?.onAny((event, data) {
      debugPrint('SOCKET_DEBUG: Event Received: $event');
    });
  }

  void connect() {
    if (_socket == null) {
      initSocket();
    } else if (!_socket!.connected) {
      debugPrint('SOCKET_DEBUG: Manually connecting socket...');
      _socket!.connect();
    }
  }

  void disconnect() {
    debugPrint('SOCKET_DEBUG: Manually disconnecting socket...');
    _socket?.disconnect();
  }

  void emit(String event, dynamic data, {Function(dynamic)? ack}) {
    if (_socket != null && _socket!.connected) {
      debugPrint('SOCKET_DEBUG: Emitting Event: $event');
      if (ack != null) {
        _socket!.emitWithAck(event, data, ack: ack);
      } else {
        _socket!.emit(event, data);
      }
    } else {
      debugPrint('SOCKET_DEBUG: Cannot emit $event. Socket not connected.');
    }
  }

  void on(String event, Function(dynamic) handler) {
    _socket?.on(event, handler);
  }

  void off(String event, [dynamic handler]) {
    if (handler != null) {
      _socket?.off(event, handler);
    } else {
      _socket?.off(event);
    }
  }
}
