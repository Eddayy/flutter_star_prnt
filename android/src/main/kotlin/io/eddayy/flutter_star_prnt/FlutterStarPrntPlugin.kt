package io.eddayy.flutter_star_prnt

import android.content.Context
import android.graphics.*
import android.net.Uri
import android.os.Handler
import android.os.Looper
import android.provider.MediaStore
import android.text.Layout
import android.text.StaticLayout
import android.text.TextPaint
import android.util.Log
import androidx.annotation.NonNull
import com.starmicronics.stario.PortInfo
import com.starmicronics.stario.StarIOPort
import com.starmicronics.stario.StarPrinterStatus
import com.starmicronics.starioextension.ICommandBuilder
import com.starmicronics.starioextension.ICommandBuilder.*
import com.starmicronics.starioextension.IConnectionCallback
import com.starmicronics.starioextension.StarIoExt
import com.starmicronics.starioextension.StarIoExt.Emulation
import com.starmicronics.starioextension.StarIoExtManager
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import java.io.IOException
import java.nio.charset.Charset
import java.nio.charset.UnsupportedCharsetException
import android.webkit.URLUtil

/** FlutterStarPrntPlugin */
public class FlutterStarPrntPlugin : FlutterPlugin, MethodCallHandler {
  protected var starIoExtManager: StarIoExtManager? = null
  companion object {
    protected lateinit var applicationContext: Context

    @JvmStatic
    fun registerWith(registrar: Registrar) {
      val channel = MethodChannel(registrar.messenger(), "flutter_star_prnt")
      channel.setMethodCallHandler(FlutterStarPrntPlugin())
      FlutterStarPrntPlugin.setupPlugin(registrar.messenger(), registrar.context())
    }
    @JvmStatic
    fun setupPlugin(messenger: BinaryMessenger, context: Context) {
      try {
        applicationContext = context.getApplicationContext()
        val channel = MethodChannel(messenger, "flutter_star_prnt")
        channel.setMethodCallHandler(FlutterStarPrntPlugin())
      } catch (e: Exception) {
          Log.e("FlutterStarPrnt", "Registration failed", e)
      }
    }
  }
  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    val channel = MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "flutter_star_prnt")
    channel.setMethodCallHandler(FlutterStarPrntPlugin())
    setupPlugin(flutterPluginBinding.getFlutterEngine().getDartExecutor(), flutterPluginBinding.getApplicationContext())
  }
  override fun onMethodCall(@NonNull call: MethodCall, @NonNull rawResult: Result) {
    val result: MethodResultWrapper = MethodResultWrapper(rawResult)
    Thread(MethodRunner(call, result)).start()
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {}
  inner class MethodRunner(call: MethodCall, result: Result) : Runnable {
    private val call: MethodCall = call
    private val result: Result = result

    override fun run() {
      when (call.method) {
        "portDiscovery" -> {
          portDiscovery(call, result)
        }
        "checkStatus" -> {
          checkStatus(call, result)
        }
        "print" -> {
          print(call, result)
        }
        else -> result.notImplemented()
      }
    }
  }
  class MethodResultWrapper(methodResult: Result) : Result {

    private val methodResult: Result = methodResult
    private val handler: Handler = Handler(Looper.getMainLooper())

    public override fun success(result: Any?) {
        handler.post(object : Runnable {
          override fun run() {
            methodResult.success(result)
          }
        })
    }

    public override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
        handler.post(object : Runnable {
          override fun run() {
            methodResult.error(errorCode, errorMessage, errorDetails)
          }
        })
    }

    public override fun notImplemented() {
        handler.post(object : Runnable {
          override fun run() {
            methodResult.notImplemented()
          }
        })
    }
  }
  public fun portDiscovery(@NonNull call: MethodCall, @NonNull result: Result) {
    val strInterface: String = call.argument<String>("type") as String
    val response: MutableList<Map<String, String>>
    try {
      if (strInterface == "LAN") {
        response = getPortDiscovery("LAN")
      } else if (strInterface == "Bluetooth") {
        response = getPortDiscovery("Bluetooth")
      } else if (strInterface == "USB") {
        response = getPortDiscovery("USB")
      } else {
        response = getPortDiscovery("All")
      }
      result.success(response)
    } catch (e: Exception) {
      result.error("PORT_DISCOVERY_ERROR", e.message, null)
    }
  }
  public fun checkStatus(@NonNull call: MethodCall, @NonNull result: Result) {
    val portName: String = call.argument<String>("portName") as String
    val emulation: String = call.argument<String>("emulation") as String

    var port: StarIOPort? = null
    try {
      val portSettings: String? = getPortSettingsOption(emulation)

      port = StarIOPort.getPort(portName, portSettings, 10000, applicationContext)

      // A sleep is used to get time for the socket to completely open
      try {
        Thread.sleep(500)
      } catch (e: InterruptedException) {}

      val status: StarPrinterStatus = port.retreiveStatus()


      val json: MutableMap<String, Any?> = mutableMapOf()
      json["is_success"] = true
      json["offline"] = status.offline
      json["coverOpen"] = status.coverOpen
      json["overTemp"] = status.overTemp
      json["cutterError"] = status.cutterError
      json["receiptPaperEmpty"] = status.receiptPaperEmpty
      try {
        val firmwareInformationMap: Map<String, String> = port.firmwareInformation
        json["ModelName"] = firmwareInformationMap["ModelName"]
        json["FirmwareVersion"] = firmwareInformationMap["FirmwareVersion"]
      }catch (e: Exception) {
        json["error_message"] = e.message
      }
      result.success(json)
    } catch (e: Exception) {
      result.error("CHECK_STATUS_ERROR", e.message, null)
    } finally {
      if (port != null) {
        try {
         StarIOPort.releasePort(port)
        } catch (e: Exception) {
          result.error("CHECK_STATUS_ERROR", e.message, null)
        }
      }
    }
  }
  // cant run this on main thread, check this later
  public fun connect(@NonNull call: MethodCall, @NonNull result: Result) {
    val portName: String = call.argument<String>("portName") as String
    val emulation: String = call.argument<String>("emulation") as String
    val hasBarcodeReader: Boolean? = call.argument<Boolean>("hasBarcodeReader") as Boolean

    val portSettings: String? = getPortSettingsOption(emulation)
    try {
      var starIoExtManager = this.starIoExtManager

      if (starIoExtManager?.port != null) {
        starIoExtManager.disconnect(object : IConnectionCallback {
          public override fun onConnected(connectResult: IConnectionCallback.ConnectResult) {
          }

          public override fun onDisconnected() {
            // Do nothing
          }
        })
      }

      starIoExtManager =
          StarIoExtManager(
              if (hasBarcodeReader != null && hasBarcodeReader)
                  StarIoExtManager.Type.WithBarcodeReader
              else StarIoExtManager.Type.Standard,
              portName,
              portSettings,
              10000,
              applicationContext)

      if (starIoExtManager != null)
          starIoExtManager.connect(
              object : IConnectionCallback {

                public override fun onConnected(connectResult: IConnectionCallback.ConnectResult) {
                  if (connectResult == IConnectionCallback.ConnectResult.Success ||
                          connectResult == IConnectionCallback.ConnectResult.AlreadyConnected) {
                    result.success("Printer Connected")
                  } else {
                    result.error("CONNECT_ERROR", "Error Connecting to the printer", null)
                  }
                }

                public override fun onDisconnected() {
                  // Do nothing
                }
              })
    } catch (e: Exception) {
      result.error("CONNECT_ERROR", e.message, e)
    }
  }
  public fun print(@NonNull call: MethodCall, @NonNull result: Result) {
    val portName: String = call.argument<String>("portName") as String
    val emulation: String = call.argument<String>("emulation") as String
    val printCommands: ArrayList<Map<String, Any>> =
        call.argument<ArrayList<Map<String, Any>>>("printCommands") as ArrayList<Map<String, Any>>
    if (printCommands.size < 1) {
      val json: MutableMap<String, Any?> = mutableMapOf()

      json["offline"] = false
      json["coverOpen"] = false
      json["cutterError"] = false
      json["receiptPaperEmpty"] = false
      json["info_message"] = "No dat to print"
      json["is_success"] = true
      result.success(json)
      return
    }
    val builder: ICommandBuilder = StarIoExt.createCommandBuilder(getEmulation(emulation))
    builder.beginDocument()
    appendCommands(builder, printCommands, applicationContext)
    builder.endDocument()
    sendCommand(
        portName,
        getPortSettingsOption(emulation),
        builder.getCommands(),
        applicationContext,
        result)
  }

  private fun getPortDiscovery(@NonNull interfaceName: String): MutableList<Map<String, String>> {
    val arrayDiscovery: MutableList<PortInfo> = mutableListOf<PortInfo>()
    val arrayPorts: MutableList<Map<String, String>> = mutableListOf<Map<String, String>>()

    if (interfaceName == "Bluetooth" || interfaceName == "All") {
      for (portInfo in StarIOPort.searchPrinter("BT:")) {
        arrayDiscovery.add(portInfo)
      }
    }
    if (interfaceName == "LAN" || interfaceName == "All") {
      for (port in StarIOPort.searchPrinter("TCP:")) {
        arrayDiscovery.add(port)
      }
    }
    if (interfaceName == "USB" || interfaceName == "All") {
      try {
        for (port in StarIOPort.searchPrinter("USB:", applicationContext)) {
          arrayDiscovery.add(port)
        }
      } catch (e: Exception) {
        Log.e("FlutterStarPrnt", "usb not conncted", e)
      }
    }
    for (discovery in arrayDiscovery) {
      val port: MutableMap<String, String> = mutableMapOf<String, String>()

      if (discovery.getPortName().startsWith("BT:"))
          port.put("portName", "BT:" + discovery.getMacAddress())
      else port.put("portName", discovery.getPortName())

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

  private fun getPortSettingsOption(
      emulation: String
  ): String { // generate the portsettings depending on the emulation type
    when (emulation) {
      "EscPosMobile" -> return "mini"
      "EscPos" -> return "escpos"
      "StarPRNT", "StarPRNTL" -> return "Portable;l"
      else -> return emulation
    }
  }
  private fun getEmulation(emulation: String?): Emulation {
    when (emulation) {
      "StarPRNT" -> return Emulation.StarPRNT
      "StarPRNTL" -> return Emulation.StarPRNTL
      "StarLine" -> return Emulation.StarLine
      "StarGraphic" -> return Emulation.StarGraphic
      "EscPos" -> return Emulation.EscPos
      "EscPosMobile" -> return Emulation.EscPosMobile
      "StarDotImpact" -> return Emulation.StarDotImpact
      else -> return Emulation.StarLine
    }
  }

  private fun appendCommands(
      builder: ICommandBuilder,
      printCommands: ArrayList<Map<String, Any>>?,
      context: Context
  ) {
    var encoding: Charset = Charset.forName("US-ASCII")

    printCommands?.forEach {
      if (it.containsKey("appendCharacterSpace"))
          builder.appendCharacterSpace((it.get("appendCharacterSpace").toString()).toInt())
      else if (it.containsKey("appendEncoding"))
          encoding = getEncoding(it.get("appendEncoding").toString())
      else if (it.containsKey("appendCodePage"))
          builder.appendCodePage(getCodePageType(it.get("appendCodePage").toString()))
      else if (it.containsKey("append"))
          builder.append(it.get("append").toString().toByteArray(encoding))
      else if (it.containsKey("appendRaw"))
          builder.append(it.get("appendRaw").toString().toByteArray(encoding))
      else if (it.containsKey("appendMultiple"))
          builder.appendMultiple(it.get("appendMultiple").toString().toByteArray(encoding), 2, 2)
      else if (it.containsKey("appendEmphasis"))
          builder.appendEmphasis(it.get("appendEmphasis").toString().toByteArray(encoding))
      else if (it.containsKey("enableEmphasis"))
          builder.appendEmphasis((it.get("enableEmphasis").toString()).toBoolean())
      else if (it.containsKey("appendInvert"))
          builder.appendInvert(it.get("appendInvert").toString().toByteArray(encoding))
      else if (it.containsKey("enableInvert"))
          builder.appendInvert((it.get("enableInvert").toString()).toBoolean())
      else if (it.containsKey("appendUnderline"))
          builder.appendUnderLine(it.get("appendUnderline").toString().toByteArray(encoding))
      else if (it.containsKey("enableUnderline"))
          builder.appendUnderLine((it.get("enableUnderline").toString()).toBoolean())
      else if (it.containsKey("appendInternational"))
          builder.appendInternational(getInternational(it.get("appendInternational").toString()))
      else if (it.containsKey("appendLineFeed"))
          builder.appendLineFeed((it.get("appendLineFeed") as Int))
      else if (it.containsKey("appendUnitFeed"))
          builder.appendUnitFeed((it.get("appendUnitFeed") as Int))
      else if (it.containsKey("appendLineSpace"))
          builder.appendLineSpace((it.get("appendLineSpace") as Int))
      else if (it.containsKey("appendFontStyle"))
          builder.appendFontStyle((getFontStyle(it.get("appendFontStyle") as String)))
      else if (it.containsKey("appendCutPaper"))
          builder.appendCutPaper(getCutPaperAction(it.get("appendCutPaper").toString()))
      else if (it.containsKey("openCashDrawer"))
          builder.appendPeripheral(getPeripheralChannel(it.get("openCashDrawer") as Int))
      else if (it.containsKey("appendBlackMark"))
          builder.appendBlackMark(getBlackMarkType(it.get("appendBlackMark").toString()))
      else if (it.containsKey("appendBytes"))
          builder.append(
              it.get("appendBytes")
                  .toString()
                  .toByteArray(encoding)) // TODO: test this in the future
      else if (it.containsKey("appendRawBytes"))
          builder.appendRaw(
              it.get("appendRawBytes")
                  .toString()
                  .toByteArray(encoding)) // TODO: test this in the future
      else if (it.containsKey("appendAbsolutePosition")) {
        if (it.containsKey("data"))
            builder.appendAbsolutePosition(
                (it.get("data").toString().toByteArray(encoding)),
                (it.get("appendAbsolutePosition").toString()).toInt())
        else builder.appendAbsolutePosition((it.get("appendAbsolutePosition").toString()).toInt())
      } else if (it.containsKey("appendAlignment")) {
        if (it.containsKey("data"))
            builder.appendAlignment(
                (it.get("data").toString().toByteArray(encoding)),
                getAlignment(it.get("appendAlignment").toString()))
        else builder.appendAlignment(getAlignment(it.get("appendAlignment").toString()))
      } else if (it.containsKey("appendHorizontalTabPosition"))
          builder.appendHorizontalTabPosition(
              it.get("appendHorizontalTabPosition") as IntArray) // TODO: test this in the future
      else if (it.containsKey("appendLogo")) {
        if (it.containsKey("logoSize"))
            builder.appendLogo(
                getLogoSize(it.get("logoSize") as String), it.get("appendLogo") as Int)
        else builder.appendLogo(getLogoSize("Normal"), it.get("appendLogo") as Int)
      } else if (it.containsKey("appendBarcode")) {
        val barcodeSymbology: ICommandBuilder.BarcodeSymbology =
            if (it.containsKey("BarcodeSymbology"))
                getBarcodeSymbology(it.get("BarcodeSymbology").toString())
            else getBarcodeSymbology("Code128")
        val barcodeWidth: ICommandBuilder.BarcodeWidth =
            if (it.containsKey("BarcodeWidth")) getBarcodeWidth(it.get("BarcodeWidth").toString())
            else getBarcodeWidth("Mode2")
        val height: Int =
            if (it.containsKey("height")) (it.get("height").toString()).toInt() else 40
        val hri: Boolean =
            if (it.containsKey("hri")) (it.get("hri").toString()).toBoolean() else true

        if (it.containsKey("absolutePosition")) {
          builder.appendBarcodeWithAbsolutePosition(
              it.get("appendBarcode").toString().toByteArray(encoding),
              barcodeSymbology,
              barcodeWidth,
              height,
              hri,
              it.get("absolutePosition") as Int)
        } else if (it.containsKey("alignment")) {
          builder.appendBarcodeWithAlignment(
              it.get("appendBarcode").toString().toByteArray(encoding),
              barcodeSymbology,
              barcodeWidth,
              height,
              hri,
              getAlignment(it.get("alignment").toString()))
        } else
            builder.appendBarcode(
                it.get("appendBarcode").toString().toByteArray(encoding),
                barcodeSymbology,
                barcodeWidth,
                height,
                hri)
      } else if (it.containsKey("appendBitmap")) {
        val diffusion: Boolean =
            if (it.containsKey("diffusion")) (it.get("diffusion").toString()).toBoolean() else true
        val width: Int = if (it.containsKey("width")) (it.get("width").toString()).toInt() else 576
        val bothScale: Boolean =
            if (it.containsKey("bothScale")) (it.get("bothScale").toString()).toBoolean() else true
        val rotation: ICommandBuilder.BitmapConverterRotation =
            if (it.containsKey("rotation")) getConverterRotation(it.get("rotation").toString())
            else getConverterRotation("Normal")
        try {
            var bitmap: Bitmap? = null
            if (URLUtil.isValidUrl(it.get("appendBitmap").toString())) {
              val imageUri: Uri = Uri.parse(it.get("appendBitmap").toString())
              bitmap = MediaStore.Images.Media.getBitmap(context.getContentResolver(), imageUri)
            } else {
              bitmap = BitmapFactory.decodeFile(it.get("appendBitmap").toString())
            }

            if (bitmap != null) {
              if (it.containsKey("absolutePosition")) {
                builder.appendBitmapWithAbsolutePosition(
                    bitmap,
                    diffusion,
                    width,
                    bothScale,
                    rotation,
                    (it.get("absolutePosition").toString()).toInt())
              } else if (it.containsKey("alignment")) {
                builder.appendBitmapWithAlignment(
                    bitmap,
                    diffusion,
                    width,
                    bothScale,
                    rotation,
                    getAlignment(it.get("alignment").toString()))
              } else builder.appendBitmap(bitmap, diffusion, width, bothScale, rotation)
            }
        } catch (e: Exception) {
          Log.e("FlutterStarPrnt", "appendbitmap failed", e)
        }
      } else if (it.containsKey("appendBitmapText")) {
        val fontSize: Float =
            if (it.containsKey("fontSize")) (it.get("fontSize").toString()).toFloat()
            else 25.toFloat()
        val diffusion: Boolean =
            if (it.containsKey("diffusion")) (it.get("diffusion").toString()).toBoolean() else true
        val width: Int = if (it.containsKey("width")) (it.get("width").toString()).toInt() else 576
        val bothScale: Boolean =
            if (it.containsKey("bothScale")) (it.get("bothScale").toString()).toBoolean() else true
        val text: String = it.get("appendBitmapText").toString()
        val typeface: Typeface = Typeface.create(Typeface.MONOSPACE, Typeface.NORMAL)
        val bitmap: Bitmap = createBitmapFromText(text, fontSize, width, typeface)
        val rotation: ICommandBuilder.BitmapConverterRotation =
            if (it.containsKey("rotation")) getConverterRotation(it.get("rotation").toString())
            else getConverterRotation("Normal")
        if (it.containsKey("absolutePosition")) {
          builder.appendBitmapWithAbsolutePosition(
              bitmap, diffusion, width, bothScale, rotation, it.get("absolutePosition") as Int)
        } else if (it.containsKey("alignment")) {
          builder.appendBitmapWithAlignment(
              bitmap,
              diffusion,
              width,
              bothScale,
              rotation,
              getAlignment(it.get("alignment").toString()))
        } else builder.appendBitmap(bitmap, diffusion, width, bothScale, rotation)
      } else if (it.containsKey("appendBitmapByteArray")) {
        val diffusion: Boolean = if (it.containsKey("diffusion")) (it.get("diffusion").toString()).toBoolean() else true
        val width: Int = if (it.containsKey("width")) (it.get("width").toString()).toInt() else 576
        val bothScale: Boolean = if (it.containsKey("bothScale")) (it.get("bothScale").toString()).toBoolean() else true
        val rotation: ICommandBuilder.BitmapConverterRotation = if (it.containsKey("rotation")) getConverterRotation(it.get("rotation").toString()) else getConverterRotation("Normal")
        try {
            val byteArray: ByteArray = it.get("appendBitmapByteArray") as ByteArray
            var bitmap: Bitmap? = null
            bitmap = BitmapFactory.decodeByteArray(byteArray, 0, byteArray.size)
            if (bitmap != null) {
              if (it.containsKey("absolutePosition")) {
                builder.appendBitmapWithAbsolutePosition(bitmap, diffusion, width, bothScale, rotation, (it.get("absolutePosition").toString()).toInt())
              } else if (it.containsKey("alignment")) {
                  builder.appendBitmapWithAlignment(bitmap, diffusion, width, bothScale, rotation, getAlignment(it.get("alignment").toString()))
              } else builder.appendBitmap(bitmap, diffusion, width, bothScale, rotation)
            }
        } catch (e: Exception) {
          Log.e("FlutterStarPrnt", "appendbitmapbyteArray failed", e)
        }}
    }
  }

  private fun getEncoding(encoding: String): Charset {
    if (encoding.equals("US-ASCII")) return Charset.forName("US-ASCII") // English
    else if (encoding.equals("Windows-1252")) {
      try {
        return Charset.forName("Windows-1252"); // French, German, Portuguese, Spanish
      } catch (e: UnsupportedCharsetException) { // not supported using UTF-8 Instead
        return Charset.forName("UTF-8")
      }
    } else if (encoding.equals("Shift-JIS")) {
      try {
        return Charset.forName("Shift-JIS"); // Japanese
      } catch (e: UnsupportedCharsetException) { // not supported using UTF-8 Instead
        return Charset.forName("UTF-8")
      }
    } else if (encoding.equals("Windows-1251")) {
      try {
        return Charset.forName("Windows-1251"); // Russian
      } catch (e: UnsupportedCharsetException) { // not supported using UTF-8 Instead
        return Charset.forName("UTF-8")
      }
    } else if (encoding.equals("GB2312")) {
      try {
        return Charset.forName("GB2312"); // Simplified Chinese
      } catch (e: UnsupportedCharsetException) { // not supported using UTF-8 Instead
        return Charset.forName("UTF-8")
      }
    } else if (encoding.equals("Big5")) {
      try {
        return Charset.forName("Big5"); // Traditional Chinese
      } catch (e: UnsupportedCharsetException) { // not supported using UTF-8 Instead
        return Charset.forName("UTF-8")
      }
    } else if (encoding.equals("UTF-8")) return Charset.forName("UTF-8") // UTF-8
    else return Charset.forName("US-ASCII")
  }
  private fun getCodePageType(codePageType: String): ICommandBuilder.CodePageType {
    if (codePageType.equals("CP437")) return CodePageType.CP437
    else if (codePageType.equals("CP737")) return CodePageType.CP737
    else if (codePageType.equals("CP772")) return CodePageType.CP772
    else if (codePageType.equals("CP774")) return CodePageType.CP774
    else if (codePageType.equals("CP851")) return CodePageType.CP851
    else if (codePageType.equals("CP852")) return CodePageType.CP852
    else if (codePageType.equals("CP855")) return CodePageType.CP855
    else if (codePageType.equals("CP857")) return CodePageType.CP857
    else if (codePageType.equals("CP858")) return CodePageType.CP858
    else if (codePageType.equals("CP860")) return CodePageType.CP860
    else if (codePageType.equals("CP861")) return CodePageType.CP861
    else if (codePageType.equals("CP862")) return CodePageType.CP862
    else if (codePageType.equals("CP863")) return CodePageType.CP863
    else if (codePageType.equals("CP864")) return CodePageType.CP864
    else if (codePageType.equals("CP865")) return CodePageType.CP866
    else if (codePageType.equals("CP869")) return CodePageType.CP869
    else if (codePageType.equals("CP874")) return CodePageType.CP874
    else if (codePageType.equals("CP928")) return CodePageType.CP928
    else if (codePageType.equals("CP932")) return CodePageType.CP932
    else if (codePageType.equals("CP999")) return CodePageType.CP999
    else if (codePageType.equals("CP1001")) return CodePageType.CP1001
    else if (codePageType.equals("CP1250")) return CodePageType.CP1250
    else if (codePageType.equals("CP1251")) return CodePageType.CP1251
    else if (codePageType.equals("CP1252")) return CodePageType.CP1252
    else if (codePageType.equals("CP2001")) return CodePageType.CP2001
    else if (codePageType.equals("CP3001")) return CodePageType.CP3001
    else if (codePageType.equals("CP3002")) return CodePageType.CP3002
    else if (codePageType.equals("CP3011")) return CodePageType.CP3011
    else if (codePageType.equals("CP3012")) return CodePageType.CP3012
    else if (codePageType.equals("CP3021")) return CodePageType.CP3021
    else if (codePageType.equals("CP3041")) return CodePageType.CP3041
    else if (codePageType.equals("CP3840")) return CodePageType.CP3840
    else if (codePageType.equals("CP3841")) return CodePageType.CP3841
    else if (codePageType.equals("CP3843")) return CodePageType.CP3843
    else if (codePageType.equals("CP3845")) return CodePageType.CP3845
    else if (codePageType.equals("CP3846")) return CodePageType.CP3846
    else if (codePageType.equals("CP3847")) return CodePageType.CP3847
    else if (codePageType.equals("CP3848")) return CodePageType.CP3848
    else if (codePageType.equals("UTF8")) return CodePageType.UTF8
    else if (codePageType.equals("Blank")) return CodePageType.Blank else return CodePageType.CP998
  }

  // ICommandBuilder Constant Functions
  private fun getInternational(international: String): ICommandBuilder.InternationalType {
    if (international.equals("UK")) return ICommandBuilder.InternationalType.UK
    else if (international.equals("USA")) return ICommandBuilder.InternationalType.USA
    else if (international.equals("France")) return ICommandBuilder.InternationalType.France
    else if (international.equals("Germany")) return ICommandBuilder.InternationalType.Germany
    else if (international.equals("Denmark")) return ICommandBuilder.InternationalType.Denmark
    else if (international.equals("Sweden")) return ICommandBuilder.InternationalType.Sweden
    else if (international.equals("Italy")) return ICommandBuilder.InternationalType.Italy
    else if (international.equals("Spain")) return ICommandBuilder.InternationalType.Spain
    else if (international.equals("Japan")) return ICommandBuilder.InternationalType.Japan
    else if (international.equals("Norway")) return ICommandBuilder.InternationalType.Norway
    else if (international.equals("Denmark2")) return ICommandBuilder.InternationalType.Denmark2
    else if (international.equals("Spain2")) return ICommandBuilder.InternationalType.Spain2
    else if (international.equals("LatinAmerica"))
        return ICommandBuilder.InternationalType.LatinAmerica
    else if (international.equals("Korea")) return ICommandBuilder.InternationalType.Korea
    else if (international.equals("Ireland")) return ICommandBuilder.InternationalType.Ireland
    else if (international.equals("Legal")) return ICommandBuilder.InternationalType.Legal
    else return ICommandBuilder.InternationalType.USA
  }

  private fun getFontStyle(fontStyle: String): ICommandBuilder.FontStyleType {
    if (fontStyle.equals("A")) return ICommandBuilder.FontStyleType.A
    if (fontStyle.equals("B")) return ICommandBuilder.FontStyleType.B
    return ICommandBuilder.FontStyleType.A
  }
  private fun getCutPaperAction(cutPaperAction: String): ICommandBuilder.CutPaperAction {
    if (cutPaperAction.equals("FullCut")) return CutPaperAction.FullCut
    else if (cutPaperAction.equals("FullCutWithFeed")) return CutPaperAction.FullCutWithFeed
    else if (cutPaperAction.equals("PartialCut")) return CutPaperAction.PartialCut
    else if (cutPaperAction.equals("PartialCutWithFeed")) return CutPaperAction.PartialCutWithFeed
    else return CutPaperAction.PartialCutWithFeed
  }
  private fun getPeripheralChannel(peripheralChannel: Int): ICommandBuilder.PeripheralChannel {
    if (peripheralChannel == 1) return ICommandBuilder.PeripheralChannel.No1
    else if (peripheralChannel == 2) return ICommandBuilder.PeripheralChannel.No2
    else return ICommandBuilder.PeripheralChannel.No1
  }
  private fun getBlackMarkType(blackMarkType: String): ICommandBuilder.BlackMarkType {
    if (blackMarkType.equals("Valid")) return ICommandBuilder.BlackMarkType.Valid
    else if (blackMarkType.equals("Invalid")) return ICommandBuilder.BlackMarkType.Invalid
    else if (blackMarkType.equals("ValidWithDetection"))
        return ICommandBuilder.BlackMarkType.ValidWithDetection
    else return ICommandBuilder.BlackMarkType.Valid
  }
  private fun getAlignment(alignment: String): ICommandBuilder.AlignmentPosition {
    if (alignment.equals("Left")) return ICommandBuilder.AlignmentPosition.Left
    else if (alignment.equals("Center")) return ICommandBuilder.AlignmentPosition.Center
    else if (alignment.equals("Right")) return ICommandBuilder.AlignmentPosition.Right
    else return ICommandBuilder.AlignmentPosition.Left
  }
  private fun getLogoSize(logoSize: String): ICommandBuilder.LogoSize {
    if (logoSize.equals("Normal")) return ICommandBuilder.LogoSize.Normal
    else if (logoSize.equals("DoubleWidth")) return ICommandBuilder.LogoSize.DoubleWidth
    else if (logoSize.equals("DoubleHeight")) return ICommandBuilder.LogoSize.DoubleHeight
    else if (logoSize.equals("DoubleWidthDoubleHeight"))
        return ICommandBuilder.LogoSize.DoubleWidthDoubleHeight
    else return ICommandBuilder.LogoSize.Normal
  }
  private fun getBarcodeSymbology(barcodeSymbology: String): ICommandBuilder.BarcodeSymbology {
    if (barcodeSymbology.equals("Code128")) return ICommandBuilder.BarcodeSymbology.Code128
    else if (barcodeSymbology.equals("Code39")) return ICommandBuilder.BarcodeSymbology.Code39
    else if (barcodeSymbology.equals("Code93")) return ICommandBuilder.BarcodeSymbology.Code93
    else if (barcodeSymbology.equals("ITF")) return ICommandBuilder.BarcodeSymbology.ITF
    else if (barcodeSymbology.equals("JAN8")) return ICommandBuilder.BarcodeSymbology.JAN8
    else if (barcodeSymbology.equals("JAN13")) return ICommandBuilder.BarcodeSymbology.JAN13
    else if (barcodeSymbology.equals("NW7")) return ICommandBuilder.BarcodeSymbology.NW7
    else if (barcodeSymbology.equals("UPCA")) return ICommandBuilder.BarcodeSymbology.UPCA
    else if (barcodeSymbology.equals("UPCE")) return ICommandBuilder.BarcodeSymbology.UPCE
    else return ICommandBuilder.BarcodeSymbology.Code128
  }
  private fun getBarcodeWidth(barcodeWidth: String): ICommandBuilder.BarcodeWidth {
    if (barcodeWidth.equals("Mode1")) return ICommandBuilder.BarcodeWidth.Mode1
    if (barcodeWidth.equals("Mode2")) return ICommandBuilder.BarcodeWidth.Mode2
    if (barcodeWidth.equals("Mode3")) return ICommandBuilder.BarcodeWidth.Mode3
    if (barcodeWidth.equals("Mode4")) return ICommandBuilder.BarcodeWidth.Mode4
    if (barcodeWidth.equals("Mode5")) return ICommandBuilder.BarcodeWidth.Mode5
    if (barcodeWidth.equals("Mode6")) return ICommandBuilder.BarcodeWidth.Mode6
    if (barcodeWidth.equals("Mode7")) return ICommandBuilder.BarcodeWidth.Mode7
    if (barcodeWidth.equals("Mode8")) return ICommandBuilder.BarcodeWidth.Mode8
    if (barcodeWidth.equals("Mode9")) return ICommandBuilder.BarcodeWidth.Mode9
    return ICommandBuilder.BarcodeWidth.Mode2
  }
  private fun getConverterRotation(
      converterRotation: String
  ): ICommandBuilder.BitmapConverterRotation {
    if (converterRotation.equals("Normal")) return ICommandBuilder.BitmapConverterRotation.Normal
    else if (converterRotation.equals("Left90"))
        return ICommandBuilder.BitmapConverterRotation.Left90
    else if (converterRotation.equals("Right90"))
        return ICommandBuilder.BitmapConverterRotation.Right90
    else if (converterRotation.equals("Rotate180"))
        return ICommandBuilder.BitmapConverterRotation.Rotate180
    else return ICommandBuilder.BitmapConverterRotation.Normal
  }
  private fun createBitmapFromText(
      printText: String,
      textSize: Float,
      printWidth: Int,
      typeface: Typeface
  ): Bitmap {
    val paint: Paint = Paint()
    paint.setTextSize(textSize)
    paint.setTypeface(typeface)
    paint.getTextBounds(printText, 0, printText.length, Rect())

    val textPaint: TextPaint = TextPaint(paint)
    val staticLayout: android.text.StaticLayout =
        StaticLayout(
            printText,
            textPaint,
            printWidth,
            Layout.Alignment.ALIGN_NORMAL,
            1.toFloat(),
            0.toFloat(),
            false)

    // Create bitmap
    val bitmap: Bitmap =
        Bitmap.createBitmap(
            staticLayout.getWidth(), staticLayout.getHeight(), Bitmap.Config.ARGB_8888)

    // Create canvas
    val canvas: Canvas = Canvas(bitmap)
    canvas.drawColor(Color.WHITE)
    canvas.translate(0.toFloat(), 0.toFloat())
    staticLayout.draw(canvas)
    return bitmap
  }
  private fun sendCommand(
      portName: String,
      portSettings: String,
      commands: ByteArray,
      context: Context,
      @NonNull result: Result
  ) {
    var port: StarIOPort? = null
    var errorPosSting = ""
    try {
      port = StarIOPort.getPort(portName, portSettings, 10000, applicationContext)
      errorPosSting += "Port Opened,"
      try {
        Thread.sleep(100)
      } catch (e: InterruptedException) {}
      var status: StarPrinterStatus = port.beginCheckedBlock()
      val json: MutableMap<String, Any?> = mutableMapOf()
      errorPosSting += "got status for begin Check,"
      json["offline"] = status.offline
      json["coverOpen"] = status.coverOpen
      json["cutterError"] = status.cutterError
      json["receiptPaperEmpty"] = status.receiptPaperEmpty
      var isSucess = true
      if (status.offline) {
        json["error_message"] = "A printer is offline"
        isSucess = false
      } else if (status.coverOpen) {
        json["error_message"] = "Printer cover is open"
        isSucess = false
      } else if (status.receiptPaperEmpty) {
        json["error_message"] = "Paper empty"
        isSucess = false
      } else if (status.presenterPaperJamError) {
        json["error_message"] = "Paper Jam"
        isSucess = false
      }

      if (status.receiptPaperNearEmptyInner || status.receiptPaperNearEmptyOuter) {
        json["error_message"] = "Paper near empty"
      }
      if (isSucess) {
        errorPosSting += "Writing to port,"
        port.writePort(commands, 0, commands.size)
        errorPosSting += "setting delay End check bock,"
        port.setEndCheckedBlockTimeoutMillis(30000); // Change the timeout time of endCheckedBlock method.
        errorPosSting += "doing End check bock,"
        try {
          status = port.endCheckedBlock()
        }catch (e:Exception){
          errorPosSting += "End check bock exeption ${e.toString()},"
        }

        json["offline"] = status.offline
        json["coverOpen"] = status.coverOpen
        json["cutterError"] = status.cutterError
        json["receiptPaperEmpty"] = status.receiptPaperEmpty
        if (status.offline) {
          json["error_message"] = "A printer is offline"
          isSucess = false
        } else if (status.coverOpen) {
          json["error_message"] = "Printer cover is open"
          isSucess = false
        } else if (status.receiptPaperEmpty) {
          json["error_message"] = "Paper empty"
          isSucess = false
        } else if (status.presenterPaperJamError) {
          json["error_message"] = "Paper Jam"
          isSucess = false
        }
      }
      json["is_success"] = isSucess
      result.success(json)
    } catch (e: Exception) {
      result.error("STARIO_PORT_EXCEPTION", e.message + " Failed After $errorPosSting", null)
    } finally {
      if (port != null) {
        try {
          StarIOPort.releasePort(port)
        } catch (e: Exception) {
          // not calling error becouse error or status is already called from try or catch.. ignoring this exception now
//            result.error("PRINT_ERROR", e.message, null)
        }
      }
    }
  }
}
