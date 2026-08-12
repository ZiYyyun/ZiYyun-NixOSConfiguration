{ pkgs, ... }:
let
  compilerPackages = import ../libs/compiler-packages.nix { inherit pkgs; };
  mkCompilerShell = import ../libs/compiler-shell.nix;
in
mkCompilerShell {
  inherit pkgs;
  name = "java";
  packages = compilerPackages.java;
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
