/**
 * File: mk-linux-cross-shell.nix
 * Author: ziyun
 * Date: 2026-07-31
 * Description: Helper for Linux SoC cross-compiling devShells.
 */
{
  pkgs,
  name,
  crossPkgs,
  arch,
  packages ? [ ],
  message ? "",
}:

pkgs.mkShell {
  inherit name;

  packages = packages ++ [
    crossPkgs.stdenv.cc
    pkgs.gdb
  ];

  shellHook = ''
    export ARCH=${arch}
    export CROSS_COMPILE=${crossPkgs.stdenv.cc.targetPrefix}

    echo ""
    echo "========================================="
    echo " ${name}"
    echo "========================================="
    echo " Target         : ${crossPkgs.stdenv.targetPlatform.config}"
    echo " ARCH           : $ARCH"
    echo " CROSS_COMPILE  : $CROSS_COMPILE"
    ${pkgs.lib.optionalString (message != "") ''echo "${message}"''}
    echo "========================================="
    echo ""
  '';
}
