{ config, pkgs, lib, ... }:

{
  options.services.jes.enable = pkgs.lib.mkEnableOption "Install dependencies for Just Enough Shell";

  config = lib.mkIf config.services.jes.enable {
    environment.systemPackages = with pkgs; [
      # libs
      qt6.qtbase
      qt6.qtdeclarative
      qt6.qtmultimedia
      qt6.qtshadertools
      qt6.qtwayland
      qt6.qtimageformats

      # themes
      matugen

      # logical + ui
      quickshell
      bash
      go
    ];
    environment.shellInit = ''
      export PATH="$HOME/.local/bin:$PATH"
    '';
  };
}
