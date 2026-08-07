{ pkgs, ... }:
let
  mkLanguageShell = import ../lib/mk-language-shell.nix;
in
mkLanguageShell {
  inherit pkgs;
  name = "java";
  packages = with pkgs; [
    jdk
    maven
    gradle
    jdt-language-server
  ];
  env = {
    JAVA_HOME = "${pkgs.jdk}";
  };
  message = "Java shell: JDK, Maven, Gradle and JDT language server.";
}
