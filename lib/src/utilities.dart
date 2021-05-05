import 'package:collection/collection.dart';
// Credits to https://github.com/ImTung

/// Object representation of categories printers group by product line
class StarMicronicsModel {
  /// Printer's product line
  String? name;

  /// Printer's emulation
  String? emulation;

  /// Model in the product line
  List<String> models;
  StarMicronicsModel({this.name, this.emulation, required this.models});
}

/// Static list of [StarMicronicsModel]
final List<StarMicronicsModel> starMicronicsModels = [
  StarMicronicsModel(
    name: 'mC-Print2',
    emulation: 'StarPRNT',
    models: ['MCP20 (STR-001)', 'MCP21 (STR-001)', 'MCP21'],
  ),
  StarMicronicsModel(
    name: 'mC-Print3',
    emulation: 'StarPRNT',
    models: ['MCP30 (STR-001)', 'MCP31'],
  ),
  StarMicronicsModel(
    name: 'mPOP',
    emulation: 'StarPRNT',
    models: ['POP10'],
  ),
  StarMicronicsModel(
    name: 'FVP10',
    emulation: 'StarLine',
    models: ['FVP10 (STR_T-001)'],
  ),
  StarMicronicsModel(
    name: 'TSP100',
    emulation: 'StarGraphic',
    models: ['TSP100', 'TSP113', 'TSP143', 'TSP143 (STR_T-001)'],
  ),
  StarMicronicsModel(
    name: 'TSP650II',
    emulation: 'StarLine',
    models: [
      'TSP654II (STR_T-001)',
      'TSP654 (STR_T-001)',
      'TSP651 (STR_T-001)'
    ],
  ),
  StarMicronicsModel(
    name: 'TSP700II',
    emulation: 'StarLine',
    models: ['TSP743II (STR_T-001)', 'TSP743 (STR_T-001)'],
  ),
  StarMicronicsModel(
    name: 'TSP800II',
    emulation: 'StarLine',
    models: ['TSP847II (STR_T-001)', 'TSP847 (STR_T-001)'],
  ),
  StarMicronicsModel(
    name: 'SM-S210i',
    emulation: 'EscPosMobile',
    models: ['SM-S210i'],
  ),
  StarMicronicsModel(
    name: 'SM-S220i',
    emulation: 'EscPosMobile',
    models: ['SM-S220i'],
  ),
  StarMicronicsModel(
    name: 'SM-S230i',
    emulation: 'EscPosMobile',
    models: ['SM-S230i'],
  ),
  StarMicronicsModel(
    name: 'SM-T300i/T300',
    emulation: 'EscPosMobile',
    models: ['SM-T300i'],
  ),
  StarMicronicsModel(
    name: 'SM-T400i',
    emulation: 'EscPosMobile',
    models: ['SM-T400i'],
  ),
  StarMicronicsModel(
    name: 'BSC10',
    emulation: 'EscPos',
    models: ['BSC10'],
  ),
  StarMicronicsModel(
    name: 'SM-S210i StarPRNT',
    emulation: 'StarPRNT',
    models: ['SM-S210i StarPRNT'],
  ),
  StarMicronicsModel(
    name: 'SM-S220i StarPRNT',
    emulation: 'StarPRNT',
    models: ['SM-S220i StarPRNT'],
  ),
  StarMicronicsModel(
    name: 'SM-S230i StarPRNT',
    emulation: 'StarPRNT',
    models: ['SM-S230i StarPRNT'],
  ),
  StarMicronicsModel(
    name: 'SM-T300i/T300 StarPRNT',
    emulation: 'StarPRNT',
    models: ['SM-T300i StarPRNT'],
  ),
  StarMicronicsModel(
    name: 'SM-T400i StarPRNT',
    emulation: 'StarPRNT',
    models: ['SM-T400i StarPRNT'],
  ),
  StarMicronicsModel(
    name: 'SM-L200',
    emulation: 'StarPRNT',
    models: ['SM-L200'],
  ),
  StarMicronicsModel(
    name: 'SP700',
    emulation: 'StarDotImpact',
    models: [
      'SP712 (STR-001)',
      'SP717 (STR-001)',
      'SP742 (STR-001)',
      'SP747 (STR-001)'
    ],
  ),
  StarMicronicsModel(
    name: 'SM-L300',
    emulation: 'StarPRNTL',
    models: ['SM-L300'],
  ),
];

/// Helper class to handle different type of printers
class StarMicronicsUtilities {
  /// Detects the [modelName] of the printer and return [StarMicronicsModel], returns [null] if not found
  static StarMicronicsModel? detectEmulation({String? modelName}) {
    if (modelName != null && modelName.isNotEmpty) {
      return starMicronicsModels.firstWhereOrNull(
        (starMicronicsModel) =>
            starMicronicsModel.models.firstWhereOrNull(
              (supportedModel) => modelName.contains(supportedModel),
            ) !=
            null,
      );
    } else {
      return null;
    }
  }

  /// Checks if command is supported WIP
  static isCommandSupport(String command, String emulation) {}
}
