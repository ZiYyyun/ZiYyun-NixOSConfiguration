/**
 * File: libs_emb_mcu_shell.nix
 * Author: ziyun
 * Date: 2026-07-31
 * Description: Helper for MCU-oriented native devShells.
 */
{
  pkgs,
  name,
  packages,
  env ? { },
  message ? "",
}:

pkgs.mkShell {
  inherit name;

  packages = packages;

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
