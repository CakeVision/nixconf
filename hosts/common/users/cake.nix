{ config
, pkgs
, inputs
, ...
}: {
  users.users.cake = {
    initialHashedPassword = "$y$j9T$nRmY0nQ9pqV2GTeVcyA1p.$l55heBZdk97.fXLLjxemXM9qn9zECUmJyP81mgwaG.7";
    isNormalUser = true;
    description = "Cake";
    extraGroups = [
      "wheel"
      "networkmanager"
      "audio"
      "video"
      "input"
      "plugdev"
      "flatpak"
    ];
    packages = [
      inputs.home-manager.packages.${pkgs.system}.default
    ];
  };
  home-manager.users.cake =
    #   import cake/${config.networking.hostName}.nix;
    import cake/lynx.nix;
}
