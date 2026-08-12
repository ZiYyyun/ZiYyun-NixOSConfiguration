{ pkgs, ... }:
let
  devCmpPackages = import ../libs/libs_cmp_packages.nix { inherit pkgs; };
  mkDevCmpShell = import ../libs/libs_cmp_shell.nix;
in
mkDevCmpShell {
  inherit pkgs;
  name = "java";
  packages = devCmpPackages.java;
  env = {
    JAVA_HOME = "${pkgs.jdk}";
  };
  tools = [ "jdk" "maven" "gradle" "jdt-language-server" ];
  versionCommands = [
    { name = "java"; bin = "java"; command = "java -version"; }
    { name = "maven"; bin = "mvn"; command = "mvn --version"; }
    { name = "gradle"; bin = "gradle"; command = "gradle --version"; }
  ];
  message = "Java shell: JDK, Maven, Gradle and JDT language server.";
}
