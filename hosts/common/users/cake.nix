{ config
, pkgs
, inputs
, ...
}: {
  users.users.cake = {
    initialHashedPassword = "$y$j9T$46H6fi69q2KhnLFLUQ1BG1$Ji4yE8MRrr6iPnFCGkXfqYrJYCr9raTrJr11Ya9NOpA";
    isNormalUser = true;
    description = "Cake user";
    extraGroups = [
      "wheel"
      "networkmanager"
      "audio"
      "video"
      "flatpak"
      "plugdev"
      "input"
      "libvirt"
      "kvm"
      "qemu-libvirt"
    ];
    packages = [ inputs.home-manager.packages.${pkgs.system}.default ];

  };

  home-manager.users.cake =
    import cake/lynx.nix;
}
