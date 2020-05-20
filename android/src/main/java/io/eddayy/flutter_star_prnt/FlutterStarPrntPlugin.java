package io.eddayy.flutter_star_prnt;

import android.content.ContentResolver;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Paint;
import android.graphics.Canvas;
import android.graphics.Typeface;
import android.graphics.Rect;
import android.graphics.Color;
import android.provider.MediaStore;
import android.text.TextPaint;
import android.net.Uri;
import android.provider.MediaStore;
import android.support.annotation.Nullable;
import android.text.StaticLayout;
import android.text.Layout;
import android.util.Base64;
import android.graphics.BitmapFactory;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.nio.charset.Charset;
import java.nio.charset.UnsupportedCharsetException;
import java.util.Locale;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import com.starmicronics.stario.PortInfo;
import com.starmicronics.stario.StarIOPort;
import com.starmicronics.stario.StarIOPortException;
import com.starmicronics.stario.StarPrinterStatus;
import com.starmicronics.starioextension.IConnectionCallback;
import com.starmicronics.starioextension.StarIoExt;
import com.starmicronics.starioextension.StarIoExt.Emulation;
import com.starmicronics.starioextension.ICommandBuilder;
import com.starmicronics.starioextension.ICommandBuilder.CutPaperAction;
import com.starmicronics.starioextension.ICommandBuilder.CodePageType;
import com.starmicronics.starioextension.StarIoExtManager;
import com.starmicronics.starioextension.StarIoExtManagerListener;

import org.json.JSONArray;
import org.json.JSONObject;
import org.json.JSONException;

import androidx.annotation.NonNull;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** FlutterStarPrntPlugin */
public class FlutterStarPrntPlugin implements FlutterPlugin, MethodCallHandler {
  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    final MethodChannel channel = new MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(),
        "flutter_star_prnt");
    channel.setMethodCallHandler(new FlutterStarPrntPlugin());
  }

  // This static function is optional and equivalent to onAttachedToEngine. It
  // supports the old
  // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
  // plugin registration via this function while apps migrate to use the new
  // Android APIs
  // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
  //
  // It is encouraged to share logic between onAttachedToEngine and registerWith
  // to keep
  // them functionally equivalent. Only one of onAttachedToEngine or registerWith
  // will be called
  // depending on the user's project. onAttachedToEngine or registerWith must both
  // be defined
  // in the same class.
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "flutter_star_prnt");
    channel.setMethodCallHandler(new FlutterStarPrntPlugin());
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    // native method here
    if (call.method.equals("getPlatformVersion")) {
      result.success("Android " + android.os.Build.VERSION.RELEASE);
    } else if (call.method.equals("portDiscovery")) {
      String type = call.argument < String > ("type");
      Promise promise = call.argument < Promise > ("callback");

      WritableArray response = new WritableNativeArray();
      try {
        if (type.equals("LAN")) {
          response = getPortDiscovery("LAN");
        } else if (strInterface.equals("Bluetooth")) {
          response = getPortDiscovery("Bluetooth");
        } else if (strInterface.equals("USB")) {
          response = getPortDiscovery("USB");
        } else {
          response = getPortDiscovery("All");
        }

      } catch (StarIOPortException exception) {
        result.success(promise.reject("PORT_DISCOVERY_ERROR", exception));

      } finally {
        result.success(promise.resolve(response));

      }
    } else {
      result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
  }

  // Methods from react-native-star-prnt
  public void portDiscovery(final String strInterface, final Promise promise) {
    new Thread(new Runnable() {
      public void run() {

        WritableArray result = new WritableNativeArray();
        try {

          if (strInterface.equals("LAN")) {
            result = getPortDiscovery("LAN");
          } else if (strInterface.equals("Bluetooth")) {
            result = getPortDiscovery("Bluetooth");
          } else if (strInterface.equals("USB")) {
            result = getPortDiscovery("USB");
          } else {
            result = getPortDiscovery("All");
          }

        } catch (StarIOPortException exception) {
          promise.reject("PORT_DISCOVERY_ERROR", exception);

        } finally {
          promise.resolve(result);
        }

      }
    }).start();
  }

  private WritableArray getPortDiscovery(String interfaceName) throws StarIOPortException {
    List<PortInfo> BTPortList;
    List<PortInfo> TCPPortList;
    List<PortInfo> USBPortList;

    final ArrayList<PortInfo> arrayDiscovery = new ArrayList<PortInfo>();

    WritableArray arrayPorts = new WritableNativeArray();

    if (interfaceName.equals("Bluetooth") || interfaceName.equals("All")) {
      BTPortList = StarIOPort.searchPrinter("BT:");

      for (PortInfo portInfo : BTPortList) {
        arrayDiscovery.add(portInfo);
      }
    }
    if (interfaceName.equals("LAN") || interfaceName.equals("All")) {
      TCPPortList = StarIOPort.searchPrinter("TCP:");

      for (PortInfo portInfo : TCPPortList) {
        arrayDiscovery.add(portInfo);
      }
    }
    if (interfaceName.equals("USB") || interfaceName.equals("All")) {
      try {
        USBPortList = StarIOPort.searchPrinter("USB:", geApplicationContext());
      } catch (StarIOPortException e) {
        USBPortList = new ArrayList<PortInfo>();
      }
      for (PortInfo portInfo : USBPortList) {
        arrayDiscovery.add(portInfo);
      }
    }

    for (PortInfo discovery : arrayDiscovery) {
      String portName;

      WritableMap port = new WritableNativeMap();
      if (discovery.getPortName().startsWith("BT:"))
        port.putString("portName", "BT:" + discovery.getMacAddress());
      else
        port.putString("portName", discovery.getPortName());

      if (!discovery.getMacAddress().equals("")) {

        port.putString("macAddress", discovery.getMacAddress());

        if (discovery.getPortName().startsWith("BT:")) {
          port.putString("modelName", discovery.getPortName());
        } else if (!discovery.getModelName().equals("")) {
          port.putString("modelName", discovery.getModelName());
        }
      } else if (interfaceName.equals("USB") || interfaceName.equals("All")) {
        if (!discovery.getModelName().equals("")) {
          port.putString("modelName", discovery.getModelName());
        }
        if (!discovery.getUSBSerialNumber().equals(" SN:")) {
          port.putString("USBSerialNumber", discovery.getUSBSerialNumber());
        }
      }

      arrayPorts.pushMap(port);
    }

    return arrayPorts;
  }
}
