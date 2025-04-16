import Foundation
import CoreLocation
import Flutter

/**
 * 高精度位置服务类
 * 负责与iOS原生位置API交互，提供高精度位置信息
 */
class LocationService: NSObject, FlutterStreamHandler, CLLocationManagerDelegate {

    // 位置管理器
    private let locationManager = CLLocationManager()

    // 事件接收器
    private var eventSink: FlutterEventSink?

    // 最后一次位置
    private var lastLocation: CLLocation?

    // 位置精度级别 (0-低, 1-平衡, 2-高)
    private var accuracyLevel: Int = 2

    /**
     * 初始化
     */
    override init() {
        super.init()

        // 配置位置管理器
        locationManager.delegate = self
        locationManager.distanceFilter = kCLDistanceFilterNone // 任何距离变化都更新
        setAccuracyLevel(level: accuracyLevel)
    }

    /**
     * 设置位置精度级别
     */
    func setAccuracyLevel(level: Int) {
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

    /**
     * 开始位置更新
     */
    func startLocationUpdates() {
        locationManager.startUpdatingLocation()
    }

    /**
     * 停止位置更新
     */
    func stopLocationUpdates() {
        locationManager.stopUpdatingLocation()
    }

    /**
     * 获取最后一次位置
     */
    func getLastLocation() -> [String: Any]? {
        guard let location = lastLocation else { return nil }
        return locationToDictionary(location)
    }

    /**
     * 位置管理器代理方法 - 位置更新
     */
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        lastLocation = location
        let locationDict = locationToDictionary(location)
        eventSink?(locationDict)
    }

    /**
     * 位置管理器代理方法 - 错误处理
     */
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        eventSink?(FlutterError(code: "LOCATION_ERROR",
                               message: "位置获取失败: \(error.localizedDescription)",
                               details: nil))
    }

    /**
     * 将CLLocation转换为字典
     */
    private func locationToDictionary(_ location: CLLocation) -> [String: Any] {
        var locationDict: [String: Any] = [
            "latitude": location.coordinate.latitude,
            "longitude": location.coordinate.longitude,
            "altitude": location.altitude,
            "accuracy": location.horizontalAccuracy,
            "verticalAccuracy": location.verticalAccuracy,
            "speed": location.speed,
            "bearing": location.course,
            "time": location.timestamp.timeIntervalSince1970 * 1000
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

    /**
     * 开始监听位置流
     */
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        startLocationUpdates()
        return nil
    }

    /**
     * 取消监听位置流
     */
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        stopLocationUpdates()
        eventSink = nil
        return nil
    }
}

/**
 * 位置服务插件
 * 处理方法调用
 */
class LocationServicePlugin: NSObject, FlutterPlugin {

    private let locationService = LocationService()

    static func register(with registrar: FlutterPluginRegistrar) {
        let instance = LocationServicePlugin()

        // 注册方法通道
        let methodChannel = FlutterMethodChannel(name: "cn.geopin.geopin/location_method", binaryMessenger: registrar.messenger())
        registrar.addMethodCallDelegate(instance, channel: methodChannel)

        // 注册事件通道
        let eventChannel = FlutterEventChannel(name: "cn.geopin.geopin/location_event", binaryMessenger: registrar.messenger())
        eventChannel.setStreamHandler(instance.locationService)
    }

    /**
     * 处理方法调用
     */
    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "initLocationService":
            // 初始化位置服务
            result(true)

        case "stopLocationService":
            // 停止位置服务
            locationService.stopLocationUpdates()
            result(true)

        case "setLocationAccuracy":
            // 设置位置精度
            if let args = call.arguments as? [String: Any],
               let accuracy = args["accuracy"] as? Int {
                locationService.setAccuracyLevel(level: accuracy)
                result(true)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT",
                                   message: "精度参数无效",
                                   details: nil))
            }

        case "getLastLocation":
            // 获取最后一次位置
            result(locationService.getLastLocation())

        default:
            result(FlutterMethodNotImplemented)
        }
    }
}