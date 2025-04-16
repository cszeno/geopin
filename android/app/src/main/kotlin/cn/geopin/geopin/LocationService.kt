package cn.geopin.geopin

import android.annotation.SuppressLint
import android.content.Context
import android.content.pm.PackageManager
import android.location.Location
import android.location.LocationListener
import android.location.LocationManager
import android.os.Build
import android.os.Bundle
import android.os.Looper
import androidx.core.app.ActivityCompat
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.ConcurrentHashMap

/**
 * 高精度位置服务类
 * 负责与Android原生位置API交互，提供高精度位置信息
 */
class LocationService(private val context: Context) : MethodChannel.MethodCallHandler, EventChannel.StreamHandler {

    // 位置管理器
    private val locationManager: LocationManager = context.getSystemService(Context.LOCATION_SERVICE) as LocationManager

    // 位置监听器
    private var locationListener: LocationListener? = null

    // 事件接收器
    private var eventSink: EventChannel.EventSink? = null

    // 最后一次位置
    private var lastLocation: Location? = null

    // 位置精度级别 (0-低, 1-平衡, 2-高)
    private var accuracyLevel: Int = 2

    // 位置提供者
    private var currentProvider: String = LocationManager.GPS_PROVIDER

    /**
     * 处理方法调用
     */
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "initLocationService" -> {
                // 初始化位置服务
                val initialized = initLocationService()
                result.success(initialized)
            }
            "stopLocationService" -> {
                // 停止位置服务
                stopLocationUpdates()
                result.success(true)
            }
            "setLocationAccuracy" -> {
                // 设置位置精度
                val accuracy = call.argument<Int>("accuracy")
                if (accuracy != null) {
                    setAccuracyLevel(accuracy)
                    result.success(true)
                } else {
                    result.error("INVALID_ARGUMENT", "精度参数无效", null)
                }
            }
            "getLastLocation" -> {
                // 获取最后一次位置
                val location = getLastLocation()
                result.success(location)
            }
            "checkLocationPermission" -> {
                // 检查位置权限
                val hasPermission = checkLocationPermission()
                result.success(hasPermission)
            }
            "requestLocationPermission" -> {
                // 请求位置权限 - 这个需要在MainActivity中实现
                result.success(false)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    /**
     * 检查位置权限
     */
    private fun checkLocationPermission(): Boolean {
        return ActivityCompat.checkSelfPermission(
            context,
            android.Manifest.permission.ACCESS_FINE_LOCATION
        ) == PackageManager.PERMISSION_GRANTED ||
                ActivityCompat.checkSelfPermission(
                    context,
                    android.Manifest.permission.ACCESS_COARSE_LOCATION
                ) == PackageManager.PERMISSION_GRANTED
    }

    /**
     * 初始化位置服务
     */
    private fun initLocationService(): Boolean {
        // 检查权限
        if (!checkLocationPermission()) {
            eventSink?.error("PERMISSION_DENIED", "位置权限被拒绝", null)
            return false
        }

        // 检查位置服务是否可用
        if (!isLocationEnabled()) {
            eventSink?.error("LOCATION_DISABLED", "位置服务未开启", null)
            return false
        }

        // 设置位置精度
        setAccuracyLevel(accuracyLevel)

        return true
    }

    /**
     * 检查位置服务是否开启
     */
    private fun isLocationEnabled(): Boolean {
        return locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER) ||
                locationManager.isProviderEnabled(LocationManager.NETWORK_PROVIDER)
    }

    /**
     * 设置位置精度级别
     */
    private fun setAccuracyLevel(level: Int) {
        accuracyLevel = level

        when (level) {
            0 -> { // 低精度
                currentProvider = LocationManager.NETWORK_PROVIDER
            }
            1 -> { // 平衡精度
                currentProvider = if (locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER))
                    LocationManager.GPS_PROVIDER else LocationManager.NETWORK_PROVIDER
            }
            else -> { // 高精度
                currentProvider = LocationManager.GPS_PROVIDER
            }
        }
    }

    /**
     * 获取最后一次位置
     */
    @SuppressLint("MissingPermission")
    private fun getLastLocation(): Map<String, Any>? {
        if (!checkLocationPermission()) {
            return null
        }

        // 尝试获取最后已知位置
        val location = lastLocation ?: run {
            val gpsLocation = locationManager.getLastKnownLocation(LocationManager.GPS_PROVIDER)
            val networkLocation = locationManager.getLastKnownLocation(LocationManager.NETWORK_PROVIDER)

            // 选择最新的位置
            if (gpsLocation != null && networkLocation != null) {
                if (gpsLocation.time > networkLocation.time) gpsLocation else networkLocation
            } else {
                gpsLocation ?: networkLocation
            }
        }

        return location?.let { locationToMap(it) }
    }

    /**
     * 开始位置更新
     */
    @SuppressLint("MissingPermission")
    private fun startLocationUpdates() {
        if (!checkLocationPermission()) {
            eventSink?.error("PERMISSION_DENIED", "位置权限被拒绝", null)
            return
        }

        // 创建位置监听器
        locationListener = object : LocationListener {
            override fun onLocationChanged(location: Location) {
                lastLocation = location
                eventSink?.success(locationToMap(location))
            }

            @Deprecated("Deprecated in Java")
            override fun onStatusChanged(provider: String?, status: Int, extras: Bundle?) {}

            override fun onProviderEnabled(provider: String) {}

            override fun onProviderDisabled(provider: String) {
                eventSink?.error("PROVIDER_DISABLED", "位置提供者已禁用: $provider", null)
            }
        }

        // 注册位置监听器
        try {
            // 根据精度级别设置更新间隔
            val minTime = when (accuracyLevel) {
                0 -> 5000L  // 低精度：5秒
                1 -> 2000L  // 平衡精度：2秒
                else -> 1000L  // 高精度：1秒
            }

            // 根据精度级别设置最小距离变化
            val minDistance = when (accuracyLevel) {
                0 -> 10.0f  // 低精度：10米
                1 -> 5.0f   // 平衡精度：5米
                else -> 0.0f  // 高精度：任何变化
            }

            // 请求位置更新
            locationManager.requestLocationUpdates(
                currentProvider,
                minTime,
                minDistance,
                locationListener!!
            )
        } catch (e: Exception) {
            eventSink?.error("LOCATION_ERROR", "开始位置更新失败: ${e.message}", null)
        }
    }

    /**
     * 停止位置更新
     */
    private fun stopLocationUpdates() {
        locationListener?.let {
            locationManager.removeUpdates(it)
            locationListener = null
        }
    }

    /**
     * 将Location对象转换为Map
     */
    private fun locationToMap(location: Location): Map<String, Any> {
        val map = HashMap<String, Any>()

        map["latitude"] = location.latitude
        map["longitude"] = location.longitude
        map["altitude"] = location.altitude
        map["accuracy"] = location.accuracy
        map["bearing"] = location.bearing
        map["speed"] = location.speed
        map["time"] = location.time
        map["provider"] = location.provider ?: "unknown"

        // API 级别相关的值
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            map["verticalAccuracy"] = location.verticalAccuracyMeters
            map["speedAccuracy"] = location.speedAccuracyMetersPerSecond
            map["bearingAccuracy"] = location.bearingAccuracyDegrees
        } else {
            map["verticalAccuracy"] = 0.0f
            map["speedAccuracy"] = 0.0f
            map["bearingAccuracy"] = 0.0f
        }

        return map
    }

    /**
     * 处理事件流监听
     */
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
        startLocationUpdates()
    }

    /**
     * 处理事件流取消
     */
    override fun onCancel(arguments: Any?) {
        stopLocationUpdates()
        eventSink = null
    }
}