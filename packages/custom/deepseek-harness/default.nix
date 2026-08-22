/**
 * File: default.nix
 * Author: ziyun
 * Date: 2026-08-21
 * Description: DeepSeek Harness CLI (`dsh`) as a standalone package.
 *
 * 从 node 开发 shell 中独立出来：不再污染 `nix develop .#node`，
 * 需要时通过 `nix run .#dsh` 或（若加入 home.packages）直接使用 `dsh`。
 *
 * 来源：https://github.com/deepseek-ai/deepseek-harness
 * 更新：改 version + 两个 hash（src 与 npmDepsHash，构建报错会给出真实值）。
 */
{ pkgs, lib }:

pkgs.buildNpmPackage rec {
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
    cp ${./package-lock.json} package-lock.json
  '';

  nativeBuildInputs = [ pkgs.makeWrapper ];

  # The HMR service in the web profile needs Node's internal modules, so
  # re-wrap the generated `dsh` bin to start node with --expose-internals.
  postInstall = ''
    makeWrapper ${pkgs.nodejs}/bin/node "$out/bin/dsh" \
      --add-flags "--expose-internals" \
      --add-flags "$out/lib/node_modules/@deepseek-ai/dsh/lib/bin.js"
  '';

  meta = with lib; {
    description = "DeepSeek Harness CLI (dsh)";
    homepage = "https://github.com/deepseek-ai/deepseek-harness";
    license = licenses.mit;
    platforms = platforms.linux;
    mainProgram = "dsh";
  };
}
