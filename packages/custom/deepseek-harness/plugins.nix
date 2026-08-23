/**
 * File: plugins.nix
 * Author: ziyun
 * Date: 2026-08-23
 * Description: DSH 社区插件集 —— 与 dsh 本体（default.nix）分层的第二层。
 *
 * 布局说明：profile 用 pnpm 安装时 hoistPattern=*，依赖全部 hoist 到顶层
 * node_modules；这里直接铺出等价的扁平布局，cordis 加载器按包名 require。
 * 所有插件都自带构建产物（lib/），无需编译；peerDependencies
 * （@deepseek-ai/cordis、react、@deepseek-ai/dsh-client-* 等）由 dsh 宿主提供。
 *
 * 插件清单：
 *   dshmarket            1.0.0   可视化插件市场（Settings → Plugin Market）
 *   dsh-context-doctor   0.6.1   上下文注入审计（context_audit 工具 + 面板）
 *   dsh-context-compass  0.7.14  上下文成本自查（/compass）
 *   dsh-dream-skin       0.4.4   换肤
 *   @dsh-external/dsh-client-ui-skin-maid-atelier  鲸鱼娘皮肤（深海女仆工坊）
 *   传递依赖：@deepseek-ai/schemastery、@deepseek-ai/cosmokit、
 *             @standard-schema/spec、zod
 *
 *   @deepseek-ai/dsh-tools 不在此处独立拉取——它由 dsh 宿主提供，
 *   installPhase 里从 dsh 包的 node_modules 软链接过来。
 *   这样 dsh-tools 自身的 peerDeps（cordis / dsh-scope / dsh-llm /
 *   dsh-session 等）也能从 dsh 宿主的 node_modules 正确解析。
 *
 * 更新插件：改版本号与 hash → home-manager switch → 重启 dsh web。
 * github.com 直连不通，doctor 走 ghfast.top 代理（与本仓库其他 input 一致）。
 */
{ lib, stdenv, fetchurl, dsh }:

let
  tgz = name: url: hash: fetchurl {
    inherit url hash;
    name = "${name}.tgz";
  };

  dshmarket = tgz "dshmarket"
    "https://registry.npmjs.org/dshmarket/-/dshmarket-1.0.0.tgz"
    "sha256-EH9cjn24g/oRAF1msNEIQFooDl84toEGfSK0uuAEqx0=";

  doctor = tgz "dsh-context-doctor"
    "https://ghfast.top/https://github.com/Zhenyu98/dsh-context-doctor/archive/refs/heads/main.tar.gz"
    "sha256-E+I9v3/vp/dske2FED7TAZZetnt2T+Sr4XKGFx5CAnE=";

  compass = tgz "dsh-context-compass"
    "https://registry.npmjs.org/dsh-context-compass/-/dsh-context-compass-0.7.14.tgz"
    "sha256-V4sHiEAY/tJtM28u6QcwYQAJ9oFjJR/t5lDBe/0QKZo=";

  dreamSkin = tgz "dsh-dream-skin"
    "https://registry.npmjs.org/dsh-dream-skin/-/dsh-dream-skin-0.4.4.tgz"
    "sha256-NLOvOJC0qgU3t/DIBvjR8ujIdXJiNH2Ex+lIeQ4IFUo=";

  schemastery = tgz "schemastery"
    "https://registry.npmjs.org/@deepseek-ai/schemastery/-/schemastery-3.18.1.tgz"
    "sha256-pktb7WYfMDyyekS8OUIULalTRgzKRFcfidlg81p0toI=";

  cosmokit = tgz "cosmokit"
    "https://registry.npmjs.org/@deepseek-ai/cosmokit/-/cosmokit-1.8.2.tgz"
    "sha256-dJhuCl0reYRgfVkTl0sIPTDv4xrFwlqLHvyQsG+k7JA=";

  spec = tgz "standard-schema-spec"
    "https://registry.npmjs.org/@standard-schema/spec/-/spec-1.1.0.tgz"
    "sha256-p8tyaL4oCrUY1FD4w7B8hvI0FyJcCrU2ke1ZswZ8zq8=";

  zod = tgz "zod"
    "https://registry.npmjs.org/zod/-/zod-4.4.3.tgz"
    "sha256-7jjxf1M/1QBhBoWkg64vQTwm9OszpRaEMUVjyNYPJ5w=";

  # 鲸鱼娘皮肤（深海女仆工坊）—— Small-tailqwq/dsh-deep-whale 仓库的
  # maid-atelier 子目录即完整皮肤包（自带构建产物），包名
  # @dsh-external/dsh-client-ui-skin-maid-atelier。
  deepWhale = tgz "dsh-deep-whale"
    "https://ghfast.top/https://github.com/Small-tailqwq/dsh-deep-whale/archive/refs/heads/main.tar.gz"
    "sha256-P1K/NDcpC/PGbo9/jqFXP1hucVvxKxuoEyozeMXm3wA=";
in
stdenv.mkDerivation {
  pname = "dsh-plugins";
  version = "2026-08-23";

  dontBuild = true;
  dontConfigure = true;
  unpackPhase = "true"; # 各 tgz 在 installPhase 里逐个解压到目标目录

  installPhase = ''
    runHook preInstall

    unpackOne() { # $1=src tarball  $2=目标目录
      mkdir -p "$2"
      tar xzf "$1" -C "$2" --strip-components=1
    }

    unpackOne ${dshmarket} "$out/node_modules/dshmarket"
    unpackOne ${doctor}    "$out/node_modules/dsh-context-doctor"
    unpackOne ${compass}   "$out/node_modules/dsh-context-compass"
    unpackOne ${dreamSkin} "$out/node_modules/dsh-dream-skin"
    unpackOne ${schemastery} "$out/node_modules/@deepseek-ai/schemastery"
    unpackOne ${cosmokit}    "$out/node_modules/@deepseek-ai/cosmokit"
    unpackOne ${spec}        "$out/node_modules/@standard-schema/spec"
    unpackOne ${zod}         "$out/node_modules/zod"

    # 鲸鱼娘皮肤：仓库含多个皮肤，只提取 maid-atelier 子目录
    mkdir -p /tmp/deep-whale "$out/node_modules/@dsh-external"
    tar xzf ${deepWhale} -C /tmp/deep-whale --strip-components=1
    cp -r /tmp/deep-whale/maid-atelier \
      "$out/node_modules/@dsh-external/dsh-client-ui-skin-maid-atelier"

    # dsh-context-doctor / dsh-context-compass import @deepseek-ai/dsh-tools
    # at runtime.  dsh-tools is a dsh core package shipped inside the dsh
    # host's own node_modules, so symlink it from there rather than fetching
    # a separate copy — dsh-tools' own peerDeps (cordis, dsh-scope, dsh-llm,
    # dsh-session …) resolve correctly from the dsh host's node_modules tree.
    ln -s "${dsh}/lib/node_modules/@deepseek-ai/dsh/node_modules/@deepseek-ai/dsh-tools" \
      "$out/node_modules/@deepseek-ai/dsh-tools"

    # dshmarket's author used 'dsh-market' (with dash) as the internal id
    # but published the npm package as 'dshmarket' (no dash).  This causes
    # three mismatches we fix here:
    #   1. cordis.patch.yml name → must be 'dshmarket' (npm package name)
    #      so the cordis loader can import it from the profile root
    #   2. cordis.patch.yml id  → 'dshmarket' for consistency
    #   3. client.js __ModuleLoader__.load id + exports.name → 'dshmarket'
    #      so the frontend can match the registration to the entry name
    sed -i \
      -e "s/name: 'dsh-market'/name: 'dshmarket'/" \
      -e "s/id: dsh-market/id: dshmarket/" \
      "$out/node_modules/dshmarket/cordis.patch.yml"
    sed -i \
      -e 's/id: "dsh-market"/id: "dshmarket"/' \
      -e "s/exports.name = 'dsh-market'/exports.name = 'dshmarket'/" \
      "$out/node_modules/dshmarket/client/client.js"

    runHook postInstall
  '';

  meta = with lib; {
    description = "DSH web profile community plugins (dshmarket, context-doctor, context-compass, dream-skin + deps)";
    homepage = "https://github.com/deepseek-ai/deepseek-harness";
    license = licenses.mit;
    platforms = platforms.linux;
    maintainers = [ ];
  };
}
