/**
 * File: feiq.nix
 * Author: ziyun
 * Date: 2026-08-20
 * Description: FeiQ (飞秋) LAN messenger packaged with Wine.
 *
 * The official download (feiq18.com) ships FeiQ.exe as a green (portable)
 * program, so no installation is needed — extract mode.
 * FeiQ uses LAN UDP broadcast for discovery, which works directly from Wine
 * on the host (no container network issues).
 */
{ pkgs, callPackage }:
let
  mkWineApp = callPackage ./wine-app.nix { };
in
mkWineApp {
  pname = "feiq";
  version = "2013-06-06";
  src = pkgs.fetchzip {
    url = "http://feiq18.com/down/feiq.zip";
    sha256 = "sha256-wgsvNK1Gn4s4JNlql0KWZDhSiEMAQPtf6SkoAPaWXOQ=";
  };
  mode = "extract";
  mainExe = "FeiQ.exe";
  desktopName = "飞秋";
  description = "局域网即时通讯与文件传输（飞秋）";
  categories = "Network";
}
