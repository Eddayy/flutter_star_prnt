package io.eddayy.flutter_star_prnt

import android.os.Handler;
import android.os.Looper;

import androidx.annotation.NonNull
import com.starmicronics.stario.PortInfo
import com.starmicronics.stario.StarIOPort
import com.starmicronics.stario.StarIOPortException
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import kotlin.collections.ArrayList
import kotlin.collections.MutableMap
/** FlutterStarPrntPlugin */
public class FlutterStarPrntPlugin : FlutterPlugin, MethodCallHandler {
  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    val channel = MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "flutter_star_prnt")
    channel.setMethodCallHandler(FlutterStarPrntPlugin())
  }

  // This static function is optional and equivalent to onAttachedToEngine. It supports the old
  // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
  // plugin registration via this function while apps migrate to use the new Android APIs
  // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
  //
  // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
  // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
  // depending on the user's project. onAttachedToEngine or registerWith must both be defined
  // in the same class.
  companion object {
    @JvmStatic
    fun registerWith(registrar: Registrar) {
      val channel = MethodChannel(registrar.messenger(), "flutter_star_prnt")
      channel.setMethodCallHandler(FlutterStarPrntPlugin())
    }
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull rawResult: Result) {
    val result:MethodResultWrapper =  MethodResultWrapper(rawResult);
    Thread(MethodRunner(call, result)).start();
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
  }
  class MethodRunner( call:MethodCall,  result:Result) : Runnable {
    private val call:MethodCall = call;
    private val result:Result = result;
    
    override fun run() {
      try{
        when(call.method) {
          "portDiscovery" -> {
            val type: String? = call.argument<String>("type")
            val response: MutableList<Map<String, String>> 
            response = portDiscovery(type)
            result.success(response)
          }
          else -> result.notImplemented()
        }
      } catch ( e: Exception) {
        result.error("Exception encountered", call.method, e);
      }
    }

    public fun portDiscovery(@NonNull strInterface:String?): MutableList<Map<String, String>>  {
      val response :MutableList<Map<String, String>>
      if (strInterface == "LAN") {
        response = getPortDiscovery("LAN")
      } else if (strInterface == "Bluetooth") {
        response = getPortDiscovery("Bluetooth")
      } else if (strInterface == "USB") {
        response = getPortDiscovery("USB")
      } else {
        response = getPortDiscovery("All")
      }
      return response
    }
  
    private fun getPortDiscovery(@NonNull interfaceName: String): MutableList<Map<String, String>> {
      val BTPortList: ArrayList<PortInfo>
      val USBPortList: ArrayList<PortInfo>
  
      val arrayDiscovery: MutableList<PortInfo> = mutableListOf<PortInfo>()
  
      val arrayPorts: MutableList<Map<String, String>> = mutableListOf<Map<String, String>>()
  
      // if (interfaceName == "Bluetooth" || interfaceName == "All") {
      //   BTPortList = StarIOPort.searchPrinter("BT:")
      //   for (portInfo in BTPortList) {
      //     arrayDiscovery.add(portInfo)
      //   }
      // }
  
      if (interfaceName == "LAN" || interfaceName == "All") {
        val TCPPortList: ArrayList<PortInfo> = StarIOPort.searchPrinter("TCP:")
        for (port in TCPPortList) {
          arrayDiscovery.add(port)
        }
      }
  
      // if (interfaceName.equals("USB") || interfaceName.equals("All")) {
      //   try {
      //     USBPortList = StarIOPort.searchPrinter("USB:", geApplicationContext());
      //   } catch (StarIOPortException e) {
      //     USBPortList = new ArrayList<PortInfo>();
      //   }
      //   for (PortInfo portInfo : USBPortList) {
      //     arrayDiscovery.add(portInfo);
      //   }
      // }
      for (discovery in arrayDiscovery) {
        val port: MutableMap<String, String> = mutableMapOf<String, String>()
        if (discovery.getPortName().startsWith("BT:"))
          port.put("portName", "BT:" + discovery.getMacAddress())
        else
          port.put("portName", discovery.getPortName())
  
        if (!discovery.getMacAddress().equals("")) {
  
          port.put("macAddress", discovery.getMacAddress())
  
          if (discovery.getPortName().startsWith("BT:")) {
            port.put("modelName", discovery.getPortName())
          } else if (!discovery.getModelName().equals("")) {
            port.put("modelName", discovery.getModelName())
          }
        } else if (interfaceName.equals("USB") || interfaceName.equals("All")) {
          if (!discovery.getModelName().equals("")) {
            port.put("modelName", discovery.getModelName())
          }
          if (!discovery.getUSBSerialNumber().equals(" SN:")) {
            port.put("USBSerialNumber", discovery.getUSBSerialNumber())
          }
        }
  
        arrayPorts.add(port)
      }
  
      return arrayPorts
    }
  }
  class MethodResultWrapper(methodResult: Result) : Result {

    private val  methodResult:Result = methodResult
    private val  handler:Handler = Handler(Looper.getMainLooper())

    public override fun success( result: Any?) {
        handler.post(object : Runnable {
          override fun run() {
            methodResult.success(result);
          }
      })
    }

    public override fun error( errorCode: String,  errorMessage: String?,  errorDetails:Any?) {
        handler.post(object : Runnable {
             override fun run() {
                methodResult.error(errorCode, errorMessage, errorDetails);
            }
        });
    }

    public override fun notImplemented() {
        handler.post(object : Runnable {
            override fun run() {
                methodResult.notImplemented();
            }
        });
    }
}
}
