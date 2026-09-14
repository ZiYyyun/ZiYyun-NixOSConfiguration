/**
 * File: default.nix
 * Author: ziyun
 * Date: 2026-08-21
 * Description: DeepSeek Harness (`dsh`) as a standalone desktop application.
 *
 * 从 node 开发 shell 中独立出来：不再污染 `nix develop .#node`，
 * 可通过桌面菜单启动 Web UI，也可用 `dsh` 命令或 `nix run .#dsh`。
 *
 * 来源：https://github.com/deepseek-ai/deepseek-harness
 * 更新：`packages/custom/update.sh --bump dsh` 一键完成（重新生成 vendored
 * lock → 改 version/src.hash → npmDepsHash fakeHash 两轮校准）。
 * 手动流程同理：lock 须按新 tarball 重生成（devDeps 剪除，见 postPatch 注释）。
 */
{ pkgs, lib }:

pkgs.buildNpmPackage rec {
  pname = "deepseek-harness";
  version = "0.1.5-rc.1";
  src = pkgs.fetchurl {
    url = "https://registry.npmjs.org/@deepseek-ai/dsh/-/dsh-${version}.tgz";
    hash = "sha256-Gnlxnxx2ORisMOgZTfeDqTMMaxLV8EyVBzGj+KHD2dA=";
  };
  npmDepsHash = "sha256-cqN2pdqnxEqJ/dPKW/cNSLICI4kB6qSJ7PqKqsQAMRo=";
  dontNpmBuild = true;

  # The npm tarball does not ship a lock file, but buildNpmPackage requires
  # one to keep npmDepsHash stable. Vendor the lock generated from the tarball.
  # 同时剪掉 package.json 的 devDependencies：0.1.5-rc.1 起部分 experimental
  # dev 包未发布到 npm（E404），且 dontNpmBuild 场景下运行时不需要它们；
  # 不剪会与 vendored lock（不含 dev）不一致导致 offline 安装 ENOTCACHED。
  postPatch = ''
    cp ${./package-lock.json} package-lock.json
    # 用绝对路径调 node：postPatch 同时作用于主构建与 npm-deps FOD，后者 PATH 无裸 node
    ${pkgs.nodejs}/bin/node -e "const fs=require('fs');const p=JSON.parse(fs.readFileSync('package.json','utf8'));delete p.devDependencies;fs.writeFileSync('package.json',JSON.stringify(p,null,2)+'\n')"
  '';

  nativeBuildInputs = [
    pkgs.makeWrapper
    pkgs.copyDesktopItems
  ];

  desktopItems = [
    (pkgs.makeDesktopItem {
      name = "deepseek-harness";
      desktopName = "DeepSeek Harness";
      genericName = "AI coding agent";
      comment = "Launch the DeepSeek Harness browser interface";
      exec = "dsh web";
      icon = "applications-development";
      terminal = false;
      categories = [ "Development" "Utility" ];
      keywords = [ "AI" "DeepSeek" "coding" "agent" ];
    })
  ];

  # The HMR service in the web profile needs Node's internal modules, so
  # re-wrap the generated `dsh` bin to start node with --expose-internals.
  postInstall = ''
    makeWrapper ${pkgs.nodejs}/bin/node "$out/bin/dsh" \
      --add-flags "--expose-internals" \
      --add-flags "$out/lib/node_modules/@deepseek-ai/dsh/lib/bin.js"
  '';

  meta = with lib; {
    description = "DeepSeek Harness AI coding agent";
    homepage = "https://github.com/deepseek-ai/deepseek-harness";
    license = licenses.mit;
    platforms = platforms.linux;
    mainProgram = "dsh";
  };
}
