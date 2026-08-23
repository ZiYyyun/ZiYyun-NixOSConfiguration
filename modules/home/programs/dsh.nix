/**
 * File: dsh.nix
 * Author: ziyun
 * Date: 2026-08-23
 * Description: DSH web profile 插件挂载（与 dsh 本体分层的第二层）。
 *
 * 插件本体：packages/custom/deepseek-harness/plugins.nix 构建出扁平
 * node_modules；本模块把每个包链接进 ~/.dsh/profiles/web/node_modules/，
 * 并生成 package.json 的 bundles 声明（cordis 加载依据）。
 *
 * 注意：cordis.yml / cordis.patch.yml / pnpm-lock.yaml 仍由 dsh 自行管理；
 * 新增插件请写进 plugins.nix（不要用 `dsh plugin add`，会被本文件覆盖）。
 */
{ config, lib, pkgs, customPackages, ... }:

let
  # dsh-plugins 需要 dsh 宿主（plugins.nix 的 installPhase 要软链接
  # @deepseek-ai/dsh-tools）。用 flake 注入的 customPackages 取现成结果。
  dshPlugins = customPackages.dsh-plugins;
  plugin = name: {
    source = "${dshPlugins}/node_modules/" + name;
  };

  # 与 dsh plugin add 等价的效果：包在 node_modules + bundles 声明。
  profilePackageJson = builtins.toJSON {
    name = "dsh-profile-web";
    private = true;
    dependencies = {
      "dsh-context-compass" = "^0.7.14";
      "dsh-context-doctor" = "0.6.1";
      "dsh-dream-skin" = "^0.4.4";
      "dshmarket" = "^1.0.0";
      "@dsh-external/dsh-client-ui-skin-maid-atelier" = "0.0.1";
    };
    dsh.profile.bundles = [
      "@deepseek-ai/dsh-base"
      "@deepseek-ai/dsh-web-app"
      "dsh-context-doctor"
      "dsh-dream-skin"
      "dsh-context-compass"
      "dshmarket"
      "@dsh-external/dsh-client-ui-skin-maid-atelier"
    ];
  } + "\n";
in
{
  home.file = {
    ".dsh/profiles/web/node_modules/dshmarket".source = "${dshPlugins}/node_modules/dshmarket";
    ".dsh/profiles/web/node_modules/dsh-context-doctor".source = "${dshPlugins}/node_modules/dsh-context-doctor";
    ".dsh/profiles/web/node_modules/dsh-context-compass".source = "${dshPlugins}/node_modules/dsh-context-compass";
    ".dsh/profiles/web/node_modules/dsh-dream-skin".source = "${dshPlugins}/node_modules/dsh-dream-skin";
    ".dsh/profiles/web/node_modules/@deepseek-ai/schemastery".source = "${dshPlugins}/node_modules/@deepseek-ai/schemastery";
    ".dsh/profiles/web/node_modules/@deepseek-ai/cosmokit".source = "${dshPlugins}/node_modules/@deepseek-ai/cosmokit";
    # dsh-tools 由 dsh 宿主提供，plugins.nix 里已从宿主 node_modules 软链进产物；
    # context-doctor / context-compass 运行时 import 它，必须链接到 profile。
    ".dsh/profiles/web/node_modules/@deepseek-ai/dsh-tools".source = "${dshPlugins}/node_modules/@deepseek-ai/dsh-tools";
    ".dsh/profiles/web/node_modules/@standard-schema/spec".source = "${dshPlugins}/node_modules/@standard-schema/spec";
    ".dsh/profiles/web/node_modules/zod".source = "${dshPlugins}/node_modules/zod";
    ".dsh/profiles/web/node_modules/@dsh-external/dsh-client-ui-skin-maid-atelier".source = "${dshPlugins}/node_modules/@dsh-external/dsh-client-ui-skin-maid-atelier";
    ".dsh/profiles/web/package.json".text = profilePackageJson;
  };
}
