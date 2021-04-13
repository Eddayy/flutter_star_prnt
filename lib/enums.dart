///Enum for Star Port type
enum StarPortType {
  All,
  LAN,
  Bluetooth,
  USB,
}

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

extension ExtendedCodePageType on StarCodePageType {
  String get text {
    return this.toString().split('.').last;
  }
}

///Constant for possible InternationalType
enum StarInternationalType {
  UK,
  USA,
  France,
  Germany,
  Denmark,
  Sweden,
  Italy,
  Spain,
  Japan,
  Norway,
  Denmark2,
  Spain2,
  LatinAmerica,
  Korea,
  Ireland,
  Legal,
}

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

extension ExtendedStarFontStyleType on StarFontStyleType {
  String get text {
    return this.toString().split('.').last;
  }
}

///Constant for possible CutPaperAction
enum StarCutPaperAction {
  FullCut,
  FullCutWithFeed,
  PartialCut,
  PartialCutWithFeed,
}

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

extension ExtendedStarBlackMarkType on StarBlackMarkType {
  String get text {
    return this.toString().split('.').last;
  }
}

///Constant for possible AlignmentPosition
enum StarAlignmentPosition {
  Left,
  Center,
  Right,
}

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

extension ExtendedStarBitmapConverterRotation on StarBitmapConverterRotation {
  String get text {
    return this.toString().split('.').last;
  }
}
