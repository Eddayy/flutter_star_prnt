// This file is from https://github.com/ImTung/flutter_star_micronics thanks for ImTung..
// This is under maintance so will be diffrent in real source
class StarMicronicsModel {
  String? name;
  String? emulation;
  List<String> models;
  StarMicronicsModel({this.name, this.emulation, required this.models});
}

final List<StarMicronicsModel> starMicronicsModels = [
  StarMicronicsModel(
      name: 'mC-Print2',
      emulation: 'StarPRNT',
      models: ["MCP20 (STR-001)", "MCP21 (STR-001)", "MCP21"]),
  StarMicronicsModel(
      name: 'mC-Print3',
      emulation: 'StarPRNT',
      models: ["MCP30 (STR-001)", "MCP31"]),
  StarMicronicsModel(
    name: 'mPOP',
    emulation: 'StarPRNT',
    models: ["POP10"],
  ),
  StarMicronicsModel(
      name: 'FVP10', emulation: 'StarLine', models: ["FVP10 (STR_T-001)"]),
  StarMicronicsModel(
      name: 'TSP100',
      emulation: 'StarGraphic',
      models: ["TSP113", "TSP143", "TSP143 (STR_T-001)"]),
  StarMicronicsModel(name: 'TSP650II', emulation: 'StarLine', models: [
    "TSP654II (STR_T-001)",
    "TSP654 (STR_T-001)",
    "TSP651 (STR_T-001)"
  ]),
  StarMicronicsModel(
      name: 'TSP700II',
      emulation: 'StarLine',
      models: ["TSP743II (STR_T-001)", "TSP743 (STR_T-001)"]),
  StarMicronicsModel(
      name: 'TSP800II',
      emulation: 'StarLine',
      models: ["TSP847II (STR_T-001)", "TSP847 (STR_T-001)"]),
  StarMicronicsModel(
      name: 'SM-S210i', emulation: 'EscPosMobile', models: ["SM-S210i"]),
  StarMicronicsModel(
      name: 'SM-S220i', emulation: 'EscPosMobile', models: ["SM-S220i"]),
  StarMicronicsModel(
      name: 'SM-S230i', emulation: 'EscPosMobile', models: ["SM-S230i"]),
  StarMicronicsModel(
      name: 'SM-T300i/T300', emulation: 'EscPosMobile', models: ["SM-T300i"]),
  StarMicronicsModel(
      name: 'SM-T400i', emulation: 'EscPosMobile', models: ["SM-T400i"]),
  StarMicronicsModel(name: 'BSC10', emulation: 'EscPos', models: ["BSC10"]),
  StarMicronicsModel(
      name: 'SM-S210i StarPRNT',
      emulation: 'StarPRNT',
      models: ["SM-S210i StarPRNT"]),
  StarMicronicsModel(
      name: 'SM-S220i StarPRNT',
      emulation: 'StarPRNT',
      models: ["SM-S220i StarPRNT"]),
  StarMicronicsModel(
      name: 'SM-S230i StarPRNT',
      emulation: 'StarPRNT',
      models: ["SM-S230i StarPRNT"]),
  StarMicronicsModel(
      name: 'SM-T300i/T300 StarPRNT',
      emulation: 'StarPRNT',
      models: ["SM-T300i StarPRNT"]),
  StarMicronicsModel(
      name: 'SM-T400i StarPRNT',
      emulation: 'StarPRNT',
      models: ["SM-T400i StarPRNT"]),
  StarMicronicsModel(
      name: 'SM-L200', emulation: 'StarPRNT', models: ["SM-L200"]),
  StarMicronicsModel(name: 'SP700', emulation: 'StarDotImpact', models: [
    "SP712 (STR-001)",
    "SP717 (STR-001)",
    "SP742 (STR-001)",
    "SP747 (STR-001)"
  ]),
  StarMicronicsModel(
      name: 'SM-L300', emulation: 'StarPRNTL', models: ["SM-L300"]),
];

class StarMicronicsUtilities {
  static StarMicronicsModel detectEmulation({String? modelName}) {
    final defaultModel = StarMicronicsModel(
        name: 'TSP100',
        emulation: 'StarGraphic',
        models: ["TSP113", "TSP143", "TSP143 (STR_T-001)"]);

    if (modelName != null && modelName.isNotEmpty) {
      return starMicronicsModels.firstWhere(
          (element) => element.models.contains(modelName),
          orElse: () => defaultModel);
    } else {
      return defaultModel;
    }
  }

  static isCommandSupport(String command, String emulation) {}
}
