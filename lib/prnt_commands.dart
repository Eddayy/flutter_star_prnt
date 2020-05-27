class PrntCommands {
  List<Map<String,dynamic>> _commands = [];

  



  List<Map<String,dynamic>> getCommands() {
    return _commands;
  }

  push(Map<String,dynamic> command) {
    this._commands.add(command);
  }
  clear() {
    this._commands.clear();
  }
}