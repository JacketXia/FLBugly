import 'dart:async';
import 'fl_bugly_interface.dart';
import 'fl_bugly_config.dart';
import 'package:flutter/foundation.dart';

abstract class FlBugly {
  /// 捕获异常
  ///
  /// [debugUpload] 是否在调试模式也上报。默认debug不上报
  ///
  /// [errorCallback] 向外回调
  static void catchedException({
    bool debugUpload = false,
    void Function(String exception, String stack)? errorCallback,
  }) {
    /// 上报错误
    void reportErrorAndLog(FlutterErrorDetails details) {
      // 控制台打印
      FlutterError.dumpErrorToConsole(details);
      if (kDebugMode && !debugUpload) {
        // debug环境且debug不上报，直接return
        return;
      }

      errorCallback?.call(
          details.exceptionAsString(), details.stack.toString());

      FlBuglyInterface.report(details);
    }

    /// 类型转换
    FlutterErrorDetails makeDetails(Object error, StackTrace stackTrace) {
      // 构建错误信息
      return FlutterErrorDetails(stack: stackTrace, exception: error);
    }

    /// 捕捉主线程报错
    var onError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      // 执行默认方法
      onError?.call(details);
      // 获取 widget build 过程中出现的异常错误
      reportErrorAndLog(details);
    };

    /// 捕捉异步任务报错
    PlatformDispatcher.instance.onError = (error, stack) {
      FlutterErrorDetails details = makeDetails(error, stack);
      reportErrorAndLog(details);
      return true;
    };
  }

  /// 初始化Bugly,使用默认BuglyConfigs
  ///
  /// 如果采用flutter_module使用的，可以不使用这个方法，由原生自己进行初始化
  ///
  /// [iOSAppId] 注册Bugly分配的iOS应用唯一标识
  ///
  /// [andriodAppId] 注册Bugly分配的安卓应用唯一标识
  ///
  /// [config] 传入配置的 BuglyConfig
  static void startWithAppId({
    required String iOSAppId,
    required String andriodAppId,
    FLBuglyConfig? config,
  }) {
    Map<String, dynamic> arguments = {
      'iOSAppId': iOSAppId,
      'andriodAppId': andriodAppId,
      'config': config?.toJson()
    };
    FlBuglyInterface.send('startWithAppId', arguments);
  }

  ///  设置用户标识
  ///
  ///  [userId] 用户标识
  static void setUserIdentifier(String userId) {
    FlBuglyInterface.send('setUserIdentifier', userId);
  }

  ///  设置关键数据，随崩溃信息上报
  ///
  ///  [key] KEY
  ///
  ///  [value] VALUE
  static void setUserKeyAndValue(String key, String value) {
    Map<String, String> arguments = {
      'key': key,
      'value': value,
    };
    FlBuglyInterface.send('setUserValueAndKey', arguments);
  }

  ///  设置标签
  ///
  ///  [tag] 标签ID，可在网站生成
  static void setTag(int tag) {
    FlBuglyInterface.send('setTag', tag);
  }
}
