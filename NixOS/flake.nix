{
  description = "NixOS flake для ORFLEMPC";

  inputs = {
    # --- Nixpkgs ---
    # В офлайн режиме: url переключается на path:/mnt/nixpkgs
    # Сейчас онлайн — тянем с github, flake.lock фиксирует ревизию
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    nur.url = "github:nix-community/NUR";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    keyboard-center = {
      url = "gitlab:dark_siders/keyboard-control";
      inputs.nixpkgs.follows = "nixpkgs"; 
    };

    driftwm.url = "github:malbiruk/driftwm";

    zwwm.url = "github:binarylinuxx/zwwm";
    
    persway.url = "github:saylesss88/persway";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, nur, home-manager, driftwm, zwwm, keyboard-center, ... }@inputs:
  let
    system = "x86_64-linux";
    userConfig = builtins.fromTOML (builtins.readFile ./user-config.toml);

    specialArgs = { inherit inputs system userConfig; };

    unstablePkgs = import nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };

  in {
    nixosConfigurations.${userConfig.hostname} = nixpkgs.lib.nixosSystem {
      inherit system specialArgs;

      modules = [
        ./configuration.nix

        { _module.args = { inherit unstablePkgs; }; }

        # NUR overlay
        { nixpkgs.overlays = [ nur.overlays.default ]; }

        # Сторонние модули
        home-manager.nixosModules.home-manager
        driftwm.nixosModules.default
        keyboard-center.nixosModules.default
        zwwm.nixosModules.default

      ];
    };
  };
}
