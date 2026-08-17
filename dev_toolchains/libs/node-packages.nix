/**
 * File: node-packages.nix
 * Author: ziyun
 * Date: 2026-08-17
 * Description: Declaratively packaged npm CLI tools.
 *
 * npm packages are not listed in nixpkgs as individual packages; to install a
 * CLI from the npm registry reproducibly we wrap it with `buildNpmPackage`.
 * The `npmDepsHash` pins the exact dependency tree so the build is reproducible.
 */
{ pkgs }:

let
  # DeepSeek Harness CLI (`dsh`): https://github.com/deepseek-ai/deepseek-harness
  deepseek-harness = pkgs.buildNpmPackage rec {
    pname = "deepseek-harness";
    version = "0.1.0-rc.6";
    src = pkgs.fetchurl {
      url = "https://registry.npmjs.org/@deepseek-ai/dsh/-/dsh-${version}.tgz";
      hash = "sha256-G4qaCtPH/q7OR5JuC9N8oVHHzPqZeVOvpf0BJheE6tw=";
    };
    npmDepsHash = "sha256-yvKSLb3oCpmIIhkrdFPVui9Hpxz68wBLqibDAFlBfbU=";
    dontNpmBuild = true;

    # The npm tarball does not ship a lock file, but buildNpmPackage requires
    # one to keep npmDepsHash stable. Vendor the lock generated from the tarball.
    postPatch = ''
      cp ${./deepseek-harness/package-lock.json} package-lock.json
    '';

    meta = {
      description = "DeepSeek Harness CLI (dsh)";
      homepage = "https://github.com/deepseek-ai/deepseek-harness";
      license = pkgs.lib.licenses.mit;
      mainProgram = "dsh";
    };
  };
in
{
  inherit deepseek-harness;
}
