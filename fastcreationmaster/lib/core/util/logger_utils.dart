
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

enum LogLevel {
  verbose,
  debug,
  info,
  warning,
  error,
  fatal,
}

class LoggerUtils {
  static LoggerUtils? _instance;
  static const String _logDirName = 'app_logs';
  static const int _maxLogFiles = 7; // 最多保留7天日志
  final String _logFileName;
  File? _currentLogFile;
  final StreamController<String> _logStream = StreamController<String>.broadcast();

  // 单例模式
  factory LoggerUtils() {
    _instance ??= LoggerUtils._internal();
    return _instance!;
  }

  LoggerUtils._internal()
      : _logFileName = DateFormat('yyyy-MM-dd').format(DateTime.now()) + '.log' {
    _initLogFile();
    _cleanOldLogs();
  }

  // 初始化日志文件
  Future<void> _initLogFile() async {
    try {
      final directory = await _getLogDirectory();
      _currentLogFile = File('${directory.path}/$_logFileName');

      // 确保文件存在
      if (!await _currentLogFile!.exists()) {
        await _currentLogFile!.create(recursive: true);
      }

      // 写入日志头部信息
      final header = '=== Log started at ${DateTime.now()} ===\n';
      await _currentLogFile!.writeAsString(header, mode: FileMode.append);
    } catch (e) {
      print('Failed to initialize log file: $e');
    }
  }

  // 获取日志目录
  Future<Directory> _getLogDirectory() async {
    final appDocDir = Platform.isAndroid
        ? await getExternalStorageDirectory() // 安卓外部存储
        : await getApplicationDocumentsDirectory(); // iOS应用文档目录

    final logDir = Directory('${appDocDir!.path}/$_logDirName');

    if (!await logDir.exists()) {
      await logDir.create(recursive: true);
    }

    return logDir;
  }

  // 清理旧日志文件
  Future<void> _cleanOldLogs() async {
    try {
      final directory = await _getLogDirectory();
      final files = await directory.list().toList();

      // 过滤出日志文件并按创建时间排序
      final logFiles = files
          .whereType<File>()
          .where((file) => file.path.endsWith('.log'))
          .toList()
        ..sort((a, b) => a.statSync().modified.compareTo(b.statSync().modified));

      // 如果日志文件超过最大数量，删除最旧的
      if (logFiles.length > _maxLogFiles) {
        final filesToDelete = logFiles.sublist(0, logFiles.length - _maxLogFiles);
        for (final file in filesToDelete) {
          await file.delete();
          print('Deleted old log file: ${file.path}');
        }
      }
    } catch (e) {
      print('Failed to clean old logs: $e');
    }
  }

  // 获取日志级别字符串
  String _getLevelString(LogLevel level) {
    switch (level) {
      case LogLevel.verbose:
        return 'VERBOSE';
      case LogLevel.debug:
        return 'DEBUG';
      case LogLevel.info:
        return 'INFO';
      case LogLevel.warning:
        return 'WARNING';
      case LogLevel.error:
        return 'ERROR';
      case LogLevel.fatal:
        return 'FATAL';
    }
  }

  // 打印日志
  void log(
      String message, {
        LogLevel level = LogLevel.debug,
        String? tag,
        StackTrace? stackTrace,
      }) {
    final time = DateFormat('yyyy-MM-dd HH:mm:ss.SSS').format(DateTime.now());
    final levelStr = _getLevelString(level);
    final logTag = tag ?? 'DEFAULT';

    // 构建日志内容
    final logMessage = '[$time] [$levelStr] [$logTag] $message';

    // 输出到控制台
    print(logMessage);
    if (stackTrace != null) {
      print(stackTrace);
    }

    // 添加到流
    _logStream.add(logMessage);

    // 写入文件
    _writeToFile(logMessage, stackTrace);
  }

  // 写入日志到文件
  Future<void> _writeToFile(String message, StackTrace? stackTrace) async {
    if (_currentLogFile == null) {
      await _initLogFile();
      if (_currentLogFile == null) return;
    }

    try {
      // 检查是否需要创建新的日志文件（跨天）
      final currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      if (!_logFileName.startsWith(currentDate)) {
        await _initLogFile();
      }

      // 写入日志内容
      await _currentLogFile!.writeAsString('$message\n', mode: FileMode.append);

      // 如果有堆栈信息，也写入文件
      if (stackTrace != null) {
        await _currentLogFile!.writeAsString('$stackTrace\n', mode: FileMode.append);
      }
    } catch (e) {
      print('Failed to write to log file: $e');
    }
  }

  // 快捷方法
  void v(String message, {String? tag}) => log(message, level: LogLevel.verbose, tag: tag);
  void d(String message, {String? tag}) => log(message, level: LogLevel.debug, tag: tag);
  void i(String message, {String? tag}) => log(message, level: LogLevel.info, tag: tag);
  void w(String message, {String? tag, StackTrace? stackTrace}) =>
      log(message, level: LogLevel.warning, tag: tag, stackTrace: stackTrace);
  void e(String message, {String? tag, StackTrace? stackTrace}) =>
      log(message, level: LogLevel.error, tag: tag, stackTrace: stackTrace);
  void f(String message, {String? tag, StackTrace? stackTrace}) =>
      log(message, level: LogLevel.fatal, tag: tag, stackTrace: stackTrace);

  // 获取所有日志文件
  Future<List<File>> getLogFiles() async {
    final directory = await _getLogDirectory();
    final files = await directory.list().toList();

    return files
        .whereType<File>()
        .where((file) => file.path.endsWith('.log'))
        .toList()
      ..sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));
  }

  // 导出单个日志文件
  Future<File?> exportLogFile(File logFile, String exportPath) async {
    try {
      final exportDir = Directory(exportPath);
      if (!await exportDir.exists()) {
        await exportDir.create(recursive: true);
      }

      final exportFile = File('${exportDir.path}/${logFile.uri.pathSegments.last}');
      return await logFile.copy(exportFile.path);
    } catch (e) {
      print('Failed to export log file: $e');
      return null;
    }
  }

  // 导出所有日志文件为ZIP（需要添加archive依赖）
  // Future<File?> exportAllLogsAsZip(String exportPath) async {
  //   // 实现略，需要使用archive包
  // }

  // 获取日志文件内容
  Future<String> getLogFileContent(File file) async {
    try {
      return await file.readAsString();
    } catch (e) {
      print('Failed to read log file: $e');
      return 'Failed to read log file: $e';
    }
  }

  // 清除所有日志
  Future<void> clearAllLogs() async {
    try {
      final directory = await _getLogDirectory();
      final files = await directory.list().toList();

      for (final file in files) {
        if (file is File && file.path.endsWith('.log')) {
          await file.delete();
        }
      }

      // 重新初始化当前日志文件
      await _initLogFile();
    } catch (e) {
      print('Failed to clear logs: $e');
    }
  }

  // 日志流（可用于实时显示日志）
  Stream<String> get logStream => _logStream.stream;

  // 释放资源
  void dispose() {
    _logStream.close();
    _instance = null;
  }
}
