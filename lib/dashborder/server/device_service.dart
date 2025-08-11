import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' if (dart.library.io) 'dart:io';  // استيراد مشروط
class DeviceService {
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  Future<Map<String, dynamic>> getDeviceInf() async {
    try {
      if (kIsWeb) {
      } else if (Platform.isAndroid) {  // Platform هنا تأتي من dart:io
        return _getAndroidDeviceInfo();
      } else if (Platform.isIOS) {
        return _getIosDeviceInfo();
      }
      return {'platform': 'unknown'};
    } catch (e) {
      return {'error': 'Failed to get device info: $e'};
    }
  }



  String _getWebDeviceName(String userAgent) {
    if (userAgent.contains('Mobile')) {
      return 'Mobile Device';
    } else if (userAgent.contains('Tablet')) {
      return 'Tablet';
    } else {
      return 'Desktop';
    }
  }

  String _getBrowserName(String userAgent) {
    userAgent = userAgent.toLowerCase();
    if (userAgent.contains('chrome')) return 'Chrome';
    if (userAgent.contains('firefox')) return 'Firefox';
    if (userAgent.contains('safari')) return 'Safari';
    if (userAgent.contains('edge')) return 'Edge';
    return 'Unknown Browser';
  }
  // دالة للحصول على معلومات الجهاز بشكل عام
  Future<Map<String, dynamic>> getDeviceInfo() async {
    try {
      if (Platform.isAndroid) {
        return _getAndroidDeviceInfo();
      } else if (Platform.isIOS) {
        return _getIosDeviceInfo();
      } else if (Platform.isWindows) {
        return _getWindowsDeviceInfo();
      } else if (Platform.isMacOS) {
        return _getMacOsDeviceInfo();
      } else if (Platform.isLinux) {
        return _getLinuxDeviceInfo();
      } else {
        return {'error': 'Platform not supported'};
      }
    } catch (e) {
      return {'error': 'Failed to get device info: $e'};
    }
  }

  Future<Map<String, dynamic>> _getAndroidDeviceInfo() async {
    AndroidDeviceInfo androidInfo = await _deviceInfo.androidInfo;
    return {
      'platform': 'Android',
      'model': androidInfo.model,
      'brand': androidInfo.brand,
      'device': androidInfo.device,
      'id': androidInfo.id,
      'version': androidInfo.version.release,
      'sdkVersion': androidInfo.version.sdkInt,
      'manufacturer': androidInfo.manufacturer,
      'isPhysicalDevice': androidInfo.isPhysicalDevice,
      'fingerprint': androidInfo.fingerprint,
    };
  }

  Future<Map<String, dynamic>> _getIosDeviceInfo() async {
    IosDeviceInfo iosInfo = await _deviceInfo.iosInfo;
    return {
      'platform': 'iOS',
      'name': iosInfo.name,
      'systemName': iosInfo.systemName,
      'systemVersion': iosInfo.systemVersion,
      'model': iosInfo.model,
      'localizedModel': iosInfo.localizedModel,
      'identifierForVendor': iosInfo.identifierForVendor,
      'isPhysicalDevice': iosInfo.isPhysicalDevice,
      'utsname': {
        'sysname': iosInfo.utsname.sysname,
        'nodename': iosInfo.utsname.nodename,
        'release': iosInfo.utsname.release,
        'version': iosInfo.utsname.version,
        'machine': iosInfo.utsname.machine,
      },
    };
  }

  Future<Map<String, dynamic>> _getWindowsDeviceInfo() async {
    WindowsDeviceInfo windowsInfo = await _deviceInfo.windowsInfo;
    return {
      'platform': 'Windows',
      'computerName': windowsInfo.computerName,
      'numberOfCores': windowsInfo.numberOfCores,
      'systemMemoryInMegabytes': windowsInfo.systemMemoryInMegabytes,
      'userName': windowsInfo.userName,
    };
  }

  Future<Map<String, dynamic>> _getMacOsDeviceInfo() async {
    MacOsDeviceInfo macOsInfo = await _deviceInfo.macOsInfo;
    return {
      'platform': 'macOS',
      'computerName': macOsInfo.computerName,
      'hostName': macOsInfo.hostName,
      'arch': macOsInfo.arch,
      'model': macOsInfo.model,
      'kernelVersion': macOsInfo.kernelVersion,
      'osRelease': macOsInfo.osRelease,
      'activeCPUs': macOsInfo.activeCPUs,
      'memorySize': macOsInfo.memorySize,
      'cpuFrequency': macOsInfo.cpuFrequency,
    };
  }

  Future<Map<String, dynamic>> _getLinuxDeviceInfo() async {
    LinuxDeviceInfo linuxInfo = await _deviceInfo.linuxInfo;
    return {
      'platform': 'Linux',
      'name': linuxInfo.name,
      'version': linuxInfo.version,
      'id': linuxInfo.id,
      'idLike': linuxInfo.idLike,
      'versionCodename': linuxInfo.versionCodename,
      'versionId': linuxInfo.versionId,
      'prettyName': linuxInfo.prettyName,
      'buildId': linuxInfo.buildId,
      'variant': linuxInfo.variant,
      'variantId': linuxInfo.variantId,
      'machineId': linuxInfo.machineId,
    };
  }
}