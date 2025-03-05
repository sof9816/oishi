// Enum to represent the different bridge commands
enum BridgeCommand {
  pop,
  popRoot,
  push,
  popAndPush,
  popRootAndPush,
  closeAndAlert,
  getToken,
  setToken,
  deleteToken, // Added deleteToken command
  refresh,
  saveLocally,
  getLocally,
  deleteLocally, // Added deleteLocally command
  clearAll, // Added clearAll command
  unknown; // For unknown bridge commands

  // Factory method to parse the string into a BridgeCommand enum
  static BridgeCommand fromString(String command) {
    return BridgeCommand.values.firstWhere(
        (e) => e.toString().split('.').last == command,
        orElse: () => BridgeCommand.unknown);
  }
}
