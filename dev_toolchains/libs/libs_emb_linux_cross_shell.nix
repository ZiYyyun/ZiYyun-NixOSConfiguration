/**
 * File: libs_emb_linux_cross_shell.nix
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
  tools ? [ ],
  libraries ? [ ],
  versionCommands ? [ ],
  message ? "",
}:

let
  renderList = title: values:
    pkgs.lib.optionalString (values != [ ]) ''
      echo "${title}:"
      ${builtins.concatStringsSep "\n" (map (value: "echo \"  - ${value}\"") values)}
    '';
  renderVersions = pkgs.lib.optionalString (versionCommands != [ ]) ''
    echo "Versions:"
    ${builtins.concatStringsSep "\n" (map (cmd: ''
      if command -v ${cmd.bin} >/dev/null 2>&1; then
        printf "  - ${cmd.name}: "
        ${cmd.command} 2>/dev/null | ${pkgs.coreutils}/bin/head -n 1 || true
      fi
    '') versionCommands)}
  '';
in
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
    ${renderList "Tools" tools}
    ${renderList "Libraries" libraries}
    ${renderVersions}
    ${pkgs.lib.optionalString (message != "") ''echo "${message}"''}
    echo "========================================="
    echo ""
  '';
}
