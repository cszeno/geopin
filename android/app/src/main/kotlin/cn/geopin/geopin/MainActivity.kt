package cn.geopin.geopin

import android.Manifest
import android.content.pm.PackageManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    // 方法通道名称
    private val METHOD_CHANNEL = "cn.geopin.geopin/location_method"
    // 事件通道名称
    private val EVENT_CHANNEL = "cn.geopin.geopin/location_event"
    // 权限请求码
    private val LOCATION_PERMISSION_REQUEST_CODE = 1001

    // 位置服务实例
    private lateinit var locationService: LocationService

    // 权限结果回调
    private var permissionResultCallback: ((Boolean) -> Unit)? = null

    /**
     * 配置Flutter引擎
     * 注册方法通道和事件通道
     */
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // 初始化位置服务
        locationService = LocationService(applicationContext)

        // 注册方法通道
        val methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL)
        methodChannel.setMethodCallHandler { call, result ->
            if (call.method == "requestLocationPermission") {
                // 处理权限请求
                requestLocationPermission { granted ->
                    result.success(granted)
                }
            } else {
                // 其他方法交给位置服务处理
                locationService.onMethodCall(call, result)
            }
        }

        // 注册事件通道
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL)
            .setStreamHandler(locationService)
    }

    /**
     * 请求位置权限
     */
    private fun requestLocationPermission(callback: (Boolean) -> Unit) {
        // 检查是否已有权限
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED) {
            callback(true)
            return
        }

        // 保存回调
        permissionResultCallback = callback

        // 请求权限
        ActivityCompat.requestPermissions(
            this,
            arrayOf(
                Manifest.permission.ACCESS_FINE_LOCATION,
                Manifest.permission.ACCESS_COARSE_LOCATION
            ),
            LOCATION_PERMISSION_REQUEST_CODE
        )
    }

    /**
     * 处理权限请求结果
     */
    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)

        if (requestCode == LOCATION_PERMISSION_REQUEST_CODE) {
            val granted = grantResults.isNotEmpty() &&
                    grantResults[0] == PackageManager.PERMISSION_GRANTED

            permissionResultCallback?.invoke(granted)
            permissionResultCallback = null
        }
    }
}
