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
  message = "Java shell: JDK, Maven, Gradle and JDT language server.";
}
