import Flutter
import UIKit
import CoreLocation

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterStreamHandler, CLLocationManagerDelegate {

  // 位置管理器
  private let locationManager = CLLocationManager()

  // 事件接收器
  private var eventSink: FlutterEventSink?

  // 最后一次位置
  private var lastLocation: CLLocation?

  // 位置精度级别
  private var accuracyLevel: Int = 2

  // 权限请求回调
  private var permissionCallback: FlutterResult?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller = window?.rootViewController as! FlutterViewController

    // 注册方法通道
    let methodChannel = FlutterMethodChannel(name: "cn.geopin.geopin/location_method",
                                           binaryMessenger: controller.binaryMessenger)
    methodChannel.setMethodCallHandler { [weak self] (call, result) in
      guard let self = self else { return }

      switch call.method {
      case "initLocationService":
        // 初始化位置服务
        self.initLocationManager()
        result(true)

      case "stopLocationService":
        // 停止位置服务
        self.locationManager.stopUpdatingLocation()
        result(true)

      case "setLocationAccuracy":
        // 设置位置精度
        if let args = call.arguments as? [String: Any],
           let accuracy = args["accuracy"] as? Int {
          self.setAccuracyLevel(level: accuracy)
          result(true)
        } else {
          result(FlutterError(code: "INVALID_ARGUMENT",
                             message: "精度参数无效",
                             details: nil))
        }

      case "getLastLocation":
        // 获取最后一次位置
        if let location = self.lastLocation {
          result(self.locationToDictionary(location))
        } else {
          result(nil)
        }

      case "checkLocationPermission":
        // 检查位置权限
        let status = self.checkLocationPermission()
        result(status)

      case "requestLocationPermission":
        // 请求位置权限
        self.permissionCallback = result
        self.requestLocationPermission()

      default:
        result(FlutterMethodNotImplemented)
      }
    }

    // 注册事件通道
    let eventChannel = FlutterEventChannel(name: "cn.geopin.geopin/location_event",
                                         binaryMessenger: controller.binaryMessenger)
    eventChannel.setStreamHandler(self)

    // 初始化位置管理器
    locationManager.delegate = self

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // 检查位置权限
  private func checkLocationPermission() -> Bool {
    if #available(iOS 14.0, *) {
      let status = locationManager.authorizationStatus
      return status == .authorizedWhenInUse || status == .authorizedAlways
    } else {
      let status = CLLocationManager.authorizationStatus()
      return status == .authorizedWhenInUse || status == .authorizedAlways
    }
  }

  // 请求位置权限
  private func requestLocationPermission() {
    locationManager.requestWhenInUseAuthorization()
    // 权限结果将在 locationManagerDidChangeAuthorization 或 didChangeAuthorizationStatus 中处理
  }

  // 初始化位置管理器
  private func initLocationManager() {
    locationManager.distanceFilter = kCLDistanceFilterNone
    setAccuracyLevel(level: accuracyLevel)

    // 如果已经有权限，直接开始更新位置
    if checkLocationPermission() {
      locationManager.startUpdatingLocation()
    }
  }

  // 设置位置精度
  private func setAccuracyLevel(level: Int) {
    accuracyLevel = level

    switch level {
    case 0: // 低精度
      locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
    case 1: // 平衡精度
      locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    default: // 高精度
      locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
    }
  }

  // 位置更新回调
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let location = locations.last else { return }

    lastLocation = location
    let locationDict = locationToDictionary(location)
    eventSink?(locationDict)
  }

  // 位置错误回调
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    eventSink?(FlutterError(code: "LOCATION_ERROR",
                           message: "位置获取失败: \(error.localizedDescription)",
                           details: nil))
  }

  // 将位置转换为字典
  private func locationToDictionary(_ location: CLLocation) -> [String: Any] {
    var locationDict: [String: Any] = [
      "latitude": location.coordinate.latitude,
      "longitude": location.coordinate.longitude,
      "altitude": location.altitude,
      "accuracy": location.horizontalAccuracy,
      "verticalAccuracy": location.verticalAccuracy,
      "speed": location.speed,
      "bearing": location.course,
      "time": location.timestamp.timeIntervalSince1970 * 1000,
      "provider": "gps"
    ]

    if #available(iOS 13.4, *) {
      locationDict["speedAccuracy"] = location.speedAccuracy
      locationDict["bearingAccuracy"] = location.courseAccuracy
    } else {
      locationDict["speedAccuracy"] = 0.0
      locationDict["bearingAccuracy"] = 0.0
    }

    return locationDict
  }

  // MARK: - FlutterStreamHandler

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    eventSink = events
    locationManager.startUpdatingLocation()
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    locationManager.stopUpdatingLocation()
    eventSink = nil
    return nil
  }

  // 处理权限状态变化 (iOS 14+)
  @available(iOS 14.0, *)
  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    let status = manager.authorizationStatus

    // 处理权限回调
    if let callback = permissionCallback {
      let granted = status == .authorizedWhenInUse || status == .authorizedAlways
      callback(granted)
      permissionCallback = nil
    }

    if status == .authorizedWhenInUse || status == .authorizedAlways {
      // 获得权限后开始更新位置
      locationManager.startUpdatingLocation()
    } else if status == .denied || status == .restricted {
      // 权限被拒绝，通知Flutter端
      eventSink?(FlutterError(code: "PERMISSION_DENIED",
                             message: "位置权限被拒绝",
                             details: nil))
    }
  }

  // 处理权限状态变化 (iOS 14以下)
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    // 处理权限回调
    if let callback = permissionCallback {
      let granted = status == .authorizedWhenInUse || status == .authorizedAlways
      callback(granted)
      permissionCallback = nil
    }

    if status == .authorizedWhenInUse || status == .authorizedAlways {
      // 获得权限后开始更新位置
      locationManager.startUpdatingLocation()
    } else if status == .denied || status == .restricted {
      // 权限被拒绝，通知Flutter端
      eventSink?(FlutterError(code: "PERMISSION_DENIED",
                             message: "位置权限被拒绝",
                             details: nil))
    }
  }
}
