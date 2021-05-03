// To parse this JSON data, do
//
//     final printerResponseStatus = printerResponseStatusFromMap(jsonString);

import 'dart:convert';

class PrinterResponseStatus {
  final bool offline;
  final bool coverOpen;
  final bool cutterError;
  final bool receiptPaperEmpty;
  final String? errorMessage;
  final bool isSuccess;
  final bool overTemp;
  final String? infoMessage;
  final String? modelName;
  final String? firmwareVersion;

  PrinterResponseStatus({
    required this.offline,
    required this.coverOpen,
    required this.cutterError,
    required this.receiptPaperEmpty,
    this.errorMessage,
    required this.isSuccess,
    required this.overTemp,
    this.infoMessage,
    this.modelName,
    this.firmwareVersion,
  });

  PrinterResponseStatus copyWith({
    bool? offline,
    bool? coverOpen,
    bool? cutterError,
    bool? receiptPaperEmpty,
    String? errorMessage,
    bool? isSuccess,
    bool? overTemp,
    String? infoMessage,
    String? modelName,
    String? firmwareVersion,
  }) {
    return PrinterResponseStatus(
      offline: offline ?? this.offline,
      coverOpen: coverOpen ?? this.coverOpen,
      cutterError: cutterError ?? this.cutterError,
      receiptPaperEmpty: receiptPaperEmpty ?? this.receiptPaperEmpty,
      errorMessage: errorMessage ?? this.errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
      overTemp: overTemp ?? this.overTemp,
      infoMessage: infoMessage ?? this.infoMessage,
      modelName: modelName ?? this.modelName,
      firmwareVersion: firmwareVersion ?? this.firmwareVersion,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'offline': offline,
      'coverOpen': coverOpen,
      'cutterError': cutterError,
      'receiptPaperEmpty': receiptPaperEmpty,
      'error_message': errorMessage,
      'is_success': isSuccess,
      'overTemp': overTemp,
      'info_message': infoMessage,
      'ModelName': modelName,
      'FirmwareVersion': firmwareVersion,
    };
  }

  factory PrinterResponseStatus.fromMap(Map<String, dynamic> map) {
    return PrinterResponseStatus(
      offline: map['offline'] ?? true,
      coverOpen: map['coverOpen'] ?? false,
      cutterError: map['cutterError'] ?? false,
      receiptPaperEmpty: map['receiptPaperEmpty'] ?? false,
      errorMessage: map['error_message'],
      isSuccess: map['is_success'] ?? false,
      overTemp: map['overTemp'] ?? false,
      infoMessage: map['info_message'],
      modelName: map['ModelName'],
      firmwareVersion: map['FirmwareVersion'],
    );
  }

  String toJson() => json.encode(toMap());

  factory PrinterResponseStatus.fromJson(String source) =>
      PrinterResponseStatus.fromMap(json.decode(source));

  @override
  String toString() {
    return 'PrinterResponseStatus(offline: $offline, coverOpen: $coverOpen, cutterError: $cutterError, receiptPaperEmpty: $receiptPaperEmpty, errorMessage: $errorMessage, isSuccess: $isSuccess, overTemp: $overTemp, infoMessage: $infoMessage, modelName: $modelName, firmwareVersion: $firmwareVersion)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PrinterResponseStatus &&
        other.offline == offline &&
        other.coverOpen == coverOpen &&
        other.cutterError == cutterError &&
        other.receiptPaperEmpty == receiptPaperEmpty &&
        other.errorMessage == errorMessage &&
        other.isSuccess == isSuccess &&
        other.overTemp == overTemp &&
        other.infoMessage == infoMessage &&
        other.modelName == modelName &&
        other.firmwareVersion == firmwareVersion;
  }

  @override
  int get hashCode {
    return offline.hashCode ^
        coverOpen.hashCode ^
        cutterError.hashCode ^
        receiptPaperEmpty.hashCode ^
        errorMessage.hashCode ^
        isSuccess.hashCode ^
        overTemp.hashCode ^
        infoMessage.hashCode ^
        modelName.hashCode ^
        firmwareVersion.hashCode;
  }
}
