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
  message ? "",
}:

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
    ${pkgs.lib.optionalString (message != "") ''echo "${message}"''}
    echo "========================================="
    echo ""
  '';
}
