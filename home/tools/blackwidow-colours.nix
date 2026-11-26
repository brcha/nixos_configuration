{ writeShellApplication, coreutils }:

writeShellApplication {
  name = "blackwidow-colours";
  runtimeInputs = [ coreutils ];
  text = builtins.readFile ./blackwidow-colours.sh;
}
