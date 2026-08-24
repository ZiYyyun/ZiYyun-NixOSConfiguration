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
 *   @deepseek-ai/dsh-tools / dsh-llm / dsh-llm-pi-ai / dsh-atomic-write /
 *   dsh-home-paths 以及 @earendil-works/pi-ai 不在此处独立拉取——它们由
 *   dsh 宿主提供，installPhase 里从 dsh 包的 node_modules 软链接过来。
 *   这些包自身的 peerDeps（cordis / dsh-scope / dsh-session 等）也能从
 *   dsh 宿主的 node_modules 正确解析。
 *   注意：插件被 home.file .source 软链进 profile，Node 解析 realpath 后
 *   会从本产物的 node_modules 向上查找，所以这些 peerDeps 必须出现在
 *   本产物的 node_modules 里（仅放在 profile 里不够）。
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

  # 多平台订阅/API 接入：SuperGrok/Grok Build、ChatGPT Plus Codex、Kimi Code、
  # Claude Code 订阅 OAuth + OpenAI/Anthropic API-key 网关共存。
  codingOauth = tgz "dsh-coding-subscription-oauth"
    "https://registry.npmjs.org/dsh-coding-subscription-oauth/-/dsh-coding-subscription-oauth-0.6.0.tgz"
    "sha256-DxTFx6fDTNTIpNcvJulLgS7xJuw+J/Nt13ZkkmyfGx0=";

  codingOauthCore = tgz "dsh-coding-oauth-core"
    "https://registry.npmjs.org/dsh-coding-oauth-core/-/dsh-coding-oauth-core-0.1.0.tgz"
    "sha256-3GlRBvSztzlUU1DNqqyhzZezVkJLostpYTRm1bm6qj8=";

  # undici 7.x（插件声明 ^7.24.8，8.x 不兼容）
  undici7 = tgz "undici"
    "https://registry.npmjs.org/undici/-/undici-7.29.0.tgz"
    "sha256-7CAF2CJzR2X8CMPuXVCx9yC/HD/GI1qwKOXMYchaOnA=";
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
    unpackOne ${codingOauth}     "$out/node_modules/dsh-coding-subscription-oauth"
    unpackOne ${codingOauthCore} "$out/node_modules/dsh-coding-oauth-core"
    unpackOne ${undici7}         "$out/node_modules/undici"

    # 鲸鱼娘皮肤：仓库含多个皮肤，只提取 maid-atelier 子目录
    mkdir -p /tmp/deep-whale "$out/node_modules/@dsh-external"
    tar xzf ${deepWhale} -C /tmp/deep-whale --strip-components=1
    cp -r /tmp/deep-whale/maid-atelier \
      "$out/node_modules/@dsh-external/dsh-client-ui-skin-maid-atelier"

    # dsh-coding-subscription-oauth / dsh-context-doctor / dsh-context-compass
    # import @deepseek-ai/dsh-* and @earendil-works/pi-ai at runtime as
    # peerDependencies.  These are dsh core packages shipped inside the dsh
    # host's own node_modules, so symlink them from there rather than fetching
    # separate copies — their own transitive peerDeps (cordis, dsh-scope,
    # dsh-session …) resolve correctly from the dsh host's node_modules tree.
    linkFromHost() { # $1 = package path under host node_modules (e.g. @deepseek-ai/dsh-llm)
      mkdir -p "$out/node_modules/$(dirname "$1")"
      ln -s "${dsh}/lib/node_modules/@deepseek-ai/dsh/node_modules/$1" \
        "$out/node_modules/$1"
    }
    for pkg in \
      @deepseek-ai/dsh-tools \
      @deepseek-ai/dsh-llm \
      @deepseek-ai/dsh-llm-pi-ai \
      @deepseek-ai/dsh-atomic-write \
      @deepseek-ai/dsh-home-paths \
      @earendil-works/pi-ai
    do
      linkFromHost "$pkg"
    done

    # dsh-coding-subscription-oauth's client bundle calls ctx.slots, but the
    # published package ships an incomplete client injection setup, so the
    # cordis context proxy throws "cannot get property 'slots' without inject"
    # and the whole plugin fails to load in the web UI.  Two places need the
    # slots service wired up (dsh-context-doctor, which works, does both):
    #   1. package.json dsh.client.inject must load @deepseek-ai/dsh-client-ui-slots
    #      (the package that provides the slots service)
    #   2. client.js' inject export must request "slots" (service name) —
    #      the bundle currently only declares ["locale"]
    # NB: the npm tarball's package.json uses CRLF line endings, so strip the
    # \r first or the anchored sed match never fires.
    codingOauthPj="$out/node_modules/dsh-coding-subscription-oauth/package.json"
    tr -d '\r' < "$codingOauthPj" > "$codingOauthPj.lf"
    mv "$codingOauthPj.lf" "$codingOauthPj"
    sed -i \
      '/^        "@deepseek-ai\/dsh-client-ui-settings",$/a\        "@deepseek-ai/dsh-client-ui-slots",' \
      "$codingOauthPj"
    sed -i 's/Yo=\["locale"\]/Yo=["locale","slots"]/' \
      "$out/node_modules/dsh-coding-subscription-oauth/lib/client.js"

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
