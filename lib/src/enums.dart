///Enum for Star Port type
enum StarPortType {
  /// checks all ports
  All,

  /// Checks lan or wifi
  LAN,

  /// Checks bluetooth port
  Bluetooth,

  /// Checks USB port
  USB,
}

///Converts enum to String
extension ExtendedPortype on StarPortType {
  String get text {
    return this.toString().split('.').last;
  }
}

///Enum for Emulation
enum StarEmulation {
  StarPRNT,
  StarPRNTL,
  StarLine,
  StarGraphic,
  EscPos,
  EscPosMobile,
  StarDotImpact,
}

///Converts enum to String
extension ExtendedEmulation on StarEmulation {
  String get text {
    return this.toString().split('.').last;
  }
}

///Enum for Encoding
enum StarEncoding {
  USASCII,
  Windows1252,
  ShiftJIS,
  Windows1251,
  GB2312,
  Big5,
  UTF8
}

///Converts enum to String
extension ExtendedEncoding on StarEncoding {
  String? get text => const {
        StarEncoding.USASCII: "US-ASCII",
        StarEncoding.Windows1252: "Windows-1252",
        StarEncoding.ShiftJIS: "Shift-JIS",
        StarEncoding.Windows1251: "Windows-1251",
        StarEncoding.GB2312: "GB2312",
        StarEncoding.Big5: "Big5",
        StarEncoding.UTF8: "UTF-8",
      }[this];
}

///Enum for CodePageType
enum StarCodePageType {
  CP737,
  CP772,
  CP774,
  CP851,
  CP852,
  CP855,
  CP857,
  CP858,
  CP860,
  CP861,
  CP862,
  CP863,
  CP864,
  CP865,
  CP869,
  CP874,
  CP928,
  CP932,
  CP999,
  CP1001,
  CP1250,
  CP1251,
  CP1252,
  CP2001,
  CP3001,
  CP3002,
  CP3011,
  CP3012,
  CP3021,
  CP3041,
  CP3840,
  CP3841,
  CP3843,
  CP3845,
  CP3846,
  CP3847,
  CP3848,
  UTF8,
  Blank,
}

///Converts enum to String
extension ExtendedCodePageType on StarCodePageType {
  String get text {
    return this.toString().split('.').last;
  }
}

///Constant for possible International character mode possible
enum StarInternationalType {
  /// UK character mode
  UK,

  /// USA character mode
  USA,

  /// French character mode
  France,

  /// German character mode
  Germany,

  /// German character mode
  Denmark,

  /// Sweden character mode

  Sweden,

  /// Italy character mode
  Italy,

  /// Spain character mode
  Spain,

  /// Japan character mode
  Japan,

  /// Norway character mode
  Norway,

  /// Denmark2 character mode
  Denmark2,

  /// Spain2 character mode
  Spain2,

  /// LatinAmerica character mode
  LatinAmerica,

  /// Korea character mode
  Korea,

  /// Ireland character mode
  Ireland,

  /// Legal character mode
  Legal,
}

///Converts enum to String
extension ExtendedStarInternationalType on StarInternationalType {
  String get text {
    return this.toString().split('.').last;
  }
}

///Constant for possible FontStyleType
enum StarFontStyleType {
  ///Font-A (12 x 24 dots) / Specify 7 x 9 font (half dots)
  A,

  ///Font-B (9 x 24 dots) / Specify 5 x 9 font (2P-1)
  B,
}

///Converts enum to String
extension ExtendedStarFontStyleType on StarFontStyleType {
  String get text {
    return this.toString().split('.').last;
  }
}

///Constant for possible CutPaperAction
enum StarCutPaperAction {
  /// Full cut
  FullCut,

  /// Full cut with feed
  FullCutWithFeed,

  /// Partial cut
  PartialCut,

  /// Partial cut with feed
  PartialCutWithFeed,
}

///Converts enum to String
extension ExtendedStarCutPaperAction on StarCutPaperAction {
  String get text {
    return this.toString().split('.').last;
  }
}

///Constant for possible BlackMarkType
enum StarBlackMarkType {
  Valid,
  Invalid,
  ValidWithDetection,
}

///Converts enum to String
extension ExtendedStarBlackMarkType on StarBlackMarkType {
  String get text {
    return this.toString().split('.').last;
  }
}

///Constant for possible AlignmentPosition
enum StarAlignmentPosition {
  /// Left alignment
  Left,

  /// Center alignment
  Center,

  /// Right alignment
  Right,
}

///Converts enum to String
extension ExtendedStarAlignmentPosition on StarAlignmentPosition {
  String get text {
    return this.toString().split('.').last;
  }
}

///Constant for possible LogoSize
enum StarLogoSize {
  Normal,
  DoubleWidth,
  DoubleHeight,
  DoubleWidthDoubleHeight,
}

///Converts enum to String
extension ExtendedStarLogoSize on StarLogoSize {
  String get text {
    return this.toString().split('.').last;
  }
}

///Constant for possible BarcodeSymbology
enum StarBarcodeSymbology {
  Code128,
  Code39,
  Code93,
  ITF,
  JAN8,
  JAN13,
  NW7,
  UPCA,
  UPCE,
}

///Converts enum to String
extension ExtendedStarBarcodeSymbology on StarBarcodeSymbology {
  String get text {
    return this.toString().split('.').last;
  }
}

///Constant for possible BarcodeWidth
enum StarBarcodeWidth {
  Mode1,
  Mode2,
  Mode3,
  Mode4,
  Mode5,
  Mode6,
  Mode7,
  Mode8,
  Mode9,
}

///Converts enum to String
extension ExtendedStarBarcodeWidth on StarBarcodeWidth {
  String get text {
    return this.toString().split('.').last;
  }
}

///Constant for possible QrCodeModel
enum StarQrCodeModel {
  No1,
  No2,
}

///Converts enum to String
extension ExtendedStarQrCodeModel on StarQrCodeModel {
  String get text {
    return this.toString().split('.').last;
  }
}

///Constant for possible QrCodeLevel
enum StarQrCodeLevel {
  H,
  L,
  M,
  Q,
}

///Converts enum to String
extension ExtendedStarQrCodeLevel on StarQrCodeLevel {
  String get text {
    return this.toString().split('.').last;
  }
}

///Constant for possible BitmapConverterRotation
enum StarBitmapConverterRotation {
  Normal,
  Left90,
  Right90,
  Rotate180,
}

///Converts enum to String
extension ExtendedStarBitmapConverterRotation on StarBitmapConverterRotation {
  String get text {
    return this.toString().split('.').last;
  }
}
