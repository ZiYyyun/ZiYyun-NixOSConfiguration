/**
 * File: default.nix
 * Author: ziyun
 * Date: 2026-08-20
 * Description: Windows apps packaged with Wine (winapps).
 */
{ callPackage }:

{
  feiq = callPackage ./feiq.nix { };
  redspider-student = callPackage ./redspider.nix { };
}
