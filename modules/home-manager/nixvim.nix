/**
 * File: nixvim.nix
 * Author: ziyun
 * Date: 2026-08-04
 * Description: Declarative Neovim configuration powered by nixvim.
 */
{ pkgs, ... }:
{
  programs.nixvim = {
    enable = true;
    nixpkgs.source = pkgs.path;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    opts = {
      number = true;
      relativenumber = true;
      expandtab = true;
      shiftwidth = 2;
      tabstop = 2;
      smartindent = true;
      termguicolors = true;
      signcolumn = "yes";
      updatetime = 200;
    };

    globals.mapleader = " ";

    clipboard.providers.wl-copy.enable = true;

    colorschemes.catppuccin = {
      enable = true;
      settings.flavour = "mocha";
    };

    plugins = {
      treesitter = {
        enable = true;
        settings.highlight.enable = true;
      };
      telescope.enable = true;
      lualine.enable = true;
      which-key.enable = true;
      web-devicons.enable = true;
      yazi.enable = true;
    };

    keymaps = [
      {
        mode = "n";
        key = "<leader>ff";
        action = "<cmd>Telescope find_files<CR>";
        options.desc = "Find files";
      }
      {
        mode = "n";
        key = "<leader>fg";
        action = "<cmd>Telescope live_grep<CR>";
        options.desc = "Live grep";
      }
      {
        mode = "n";
        key = "<leader>e";
        action = "<cmd>Yazi<CR>";
        options.desc = "Open yazi";
      }
    ];
  };
}
