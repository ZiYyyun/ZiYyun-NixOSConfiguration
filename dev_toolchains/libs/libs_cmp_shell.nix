/**
 * File: libs_cmp_shell.nix
 * Author: ziyun
 * Date: 2026-08-07
 * Description: Helper for programming-oriented devShells.
 */
{
  pkgs,
  name,
  packages,
  env ? { },
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
  inherit name packages;

  shellHook = ''
    ${builtins.concatStringsSep "\n" (
      builtins.attrValues (
        builtins.mapAttrs (key: value: "export ${key}=${pkgs.lib.escapeShellArg value}") env
      )
    )}

    echo ""
    echo "========================================="
    echo " ${name}"
    echo "========================================="
    ${renderList "Tools" tools}
    ${renderList "Libraries" libraries}
    ${renderVersions}
    ${pkgs.lib.optionalString (message != "") ''echo "${message}"''}
    echo "========================================="
    echo ""
  '';
}
