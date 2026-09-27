{ config, pkgs, unstablePkgs, inputs, userConfig, lib, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./happ-nixos/happ-module.nix
    ./JES.nix
  ];

  # ============================================================
  # ENVIRONMENT
  # ============================================================
  environment.sessionVariables = {
    GI_TYPELIB_PATH = "/run/current-system/sw/lib/girepository-1.0";
    ICON_THEME = "Tela-nord";
    QS_ICON_THEME = "Tela-nord";
    QT_QPA_PLATFORMTHEME = "qt6ct";
    GDK_BACKEND = "wayland";
    NIXOS_OZONE_WL = "1";
    TERMINAL = "foot";
  };

  services.jes.enable = true;

  # Moza Racing udev rules
  services.udev.packages = [
    (pkgs.writeTextDir "etc/udev/rules.d/70-boxflat.rules" ''
      SUBSYSTEM=="tty", KERNEL=="ttyACM*", ATTRS{idVendor}=="346e", ACTION=="add", MODE="0666", TAG+="uaccess"
      KERNEL=="hidraw*", ATTRS{idVendor}=="346e", MODE="0666", TAG+="uaccess"
    '')
  ];
  
  environment.etc."xdg/menus/applications.menu".source = 
    "${pkgs.kdePackages.plasma-workspace}/etc/xdg/menus/plasma-applications.menu";

  # ============================================================
  # PACKAGES
  # ============================================================
  nixpkgs.config = {
    allowUnfree = true;
    rocmSupport = true;
  };
 
  nix.settings = {
    auto-optimise-store = true;
    max-jobs = "auto";
  };
   
  environment.systemPackages = 
    # STABLE
    (with pkgs; [
      logmein-hamachi
      amnezia-vpn

      # GUI — Творчество и медиа
      blender
      inkscape
      krita
      gmic
      obsidian
      (mpv.override { scripts = with pkgs.mpvScripts; [ mpris ]; })
      upscaler
      renoise

      # GUI — KDE
      kdePackages.kdenlive
      kdePackages.gwenview
      kdePackages.okular
      kdePackages.dolphin
      kdePackages.ffmpegthumbs
      kdePackages.kdeconnect-kde
      kdePackages.kwallet
      kdePackages.kwallet-pam
      kdePackages.kwalletmanager
      kdePackages.ksshaskpass
      kdePackages.qt6ct
      kdePackages.qtstyleplugin-kvantum
      # kdePackages.plasma-browser-integration
      # kdePackages.kio

      # GUI — Офис и документы
      libreoffice-qt6-fresh
      zeal

      # GUI — Разработка
      arduino-ide
      avalonia-ilspy

      # GUI — Сеть и мессенджеры
      # deltachat-desktop
      zoom-us

      # GUI — Игры
      prismlauncher
      protonplus
      steam
      boxflat

      # GUI — Системные утилиты
      adwsteamgtk
      blueman
      bottles
      corectrl
      file-roller
      qalculate-qt
      tuigreet
      nmgui
      hyprlock
      lxqt.pavucontrol-qt
      pcmanfm-qt
      krusader
      nwg-look
      unityhub

      # CLI — Редакторы
      helix
      neovim
      micro

      # CLI — Разработка
      cargo
      jdk25
      nodejs
      gcc
      upx
      git
      bfg-repo-cleaner
      gnumake
      lua-language-server
      rust-analyzer
      sass
      sqlite

      # CLI — Android & Mobile
      android-tools
      adb-sync
      adbtuifm
      adbfs-rootless
      scrcpy
      tigervnc
      sshfs
      pmbootstrap
      pixelflasher

      # CLI — Мультимедиа
      cava
      ffmpeg
      ldacbt
      mpd-mpris
      pamixer
      playerctl
      rmpc
      gowall

      # CLI — Системные библиотеки
      dbus
      glib
      glibc
      gobject-introspection
      libnotify
      wtype
      inotify-tools
      xwayland-satellite
      pciutils

      # Python
      (python314.withPackages (ps: with ps; [
         tkinter-gl
         mutagen
       ]))

      # Сеть и VPN
      qbittorrent-enhanced-nox
      wireguard-tools

      # Файлы и архивы
      coreutils-full
      dust
      tree
      p7zip
      poppler
      unzip
      wget
      zip

      # Wayland — Скриншоты/видео и буфер
      cliphist
      grim
      slurp
      wl-clipboard
      wf-recorder

      # Повседневные утилиты
      appimage-run
      bat
      btop-rocm
      browsh
      chafa
      clinfo
      cmatrix
      ddcutil
      fastfetch
      jq
      lsd
      mdcat
      mdr
      pipes
      w3m
      yazi
      zellij
      arduino-cli
      yggdrasil
      taplo

      # AMD GPU — ROCm
      libdrm
      libGL
      libva
      libvdpau
      mesa
      mesa-demos
      vulkan-loader
      vulkan-validation-layers
      wayland
      rocmPackages.rocminfo
      rocmPackages.rocm-smi
      rocmPackages.rocm-runtime
      rocmPackages.hipcc
      rocmPackages.hipblas
      rocmPackages.rocm-device-libs

      # Диск и ФС
      kbd
      udisks2
      udiskie
      ntfs3g
      exfat

      # Виртуализация
      distrobox

      # iOS
      libimobiledevice
      ifuse
      ideviceinstaller

      # Темы и иконки
      gsettings-desktop-schemas
      gnome-themes-extra
      rose-pine-cursor
      rose-pine-hyprcursor
      tela-icon-theme
      adw-gtk3

      # Unity3D
      libsecret

      brightnessctl
    ]) 
    
    # UNSTABLE
    ++ (with unstablePkgs; [
      telegram-desktop
      element-desktop
      (ungoogled-chromium.override { enableWideVine = true; })
      discord
      yt-dlp

      # CLI
      go
      zig
      llama-cpp-rocm

      # TUI — Игры
      bastet
      moon-buggy
      nsnake

      # Wayland & Sway
      hyprpicker
      inputs.persway.packages.${pkgs.stdenv.hostPlatform.system}.default
    ])

    # NUR
    ++ (with pkgs.nur.repos; [
      lonerOrz.linux-wallpaperengine
      sn0wm1x.naiveproxy-bin
      guoard.hiddify
    ]);

  programs.kdeconnect.enable = true;
  
  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
    ];
  };

  programs.keyboard-center = {
    enable = true;

    # Добавить пользователя в группу plugdev (доступ к hidraw без sudo)
    enableUserGroup = true;   # по умолчанию true
    enableUdevRules = false;   # по умолчанию true

  };

  # ============================================================
  # DISPLAY & LOGIN
  # ============================================================
  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd ${userConfig.prefered_WM}";
    };
  };
  systemd.services.greetd.serviceConfig.ExecStartPre = [ "${pkgs.kbd}/bin/setfont ter-v32n" ];

  programs.sway = {
    enable = true;
    package = unstablePkgs.swayfx;
    wrapperFeatures.gtk = true;
  };

  programs.driftwm.enable = true;

  programs.zwwm = {
    enable = true;
    xwayland.enable = true;
  };
  
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-wlr
      kdePackages.xdg-desktop-portal-kde
    ];
  };

  # services.displayManager.sessionPackages = [
  # ];

  # ============================================================
  # INPUT & NETWORK SERVICES
  # ============================================================
  services.espanso = {
    enable = true;
    package = pkgs.espanso-wayland;
  };

  services.yggdrasil = {
    enable = true;
    settings.Peers = [
      "tls://ygg-msk-1.averyan.ru:8362"
      "tls://x-mow-0.sergeysedoy97.ru:65534"
    ];
  };

  # ============================================================
  # USER & HOME-MANAGER
  # ============================================================
  users.users.${userConfig.username} = {
    isNormalUser = true;
    description = "${userConfig.description}";
    extraGroups = [ "networkmanager" "wheel" "dialout" "input" "plugdev" "storage" "i2c" "usbmux" "adbusers" "ydotool" ];
    packages = with pkgs; [];
  };

  security.pam.services."${userConfig.username}".kwallet = {
    enable = true;
    package = pkgs.kdePackages.kwallet-pam;
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs userConfig; };
    users.${userConfig.username} = {
      home = {
        username = "${userConfig.username}";
        homeDirectory = "/home/${userConfig.username}";
        stateVersion = "26.05";
      };

      services.mpd = {
        enable = true;
        musicDirectory = "${home.homeDirectory}/music/";
        extraConfig = ''
          audio_output {
            type "alsa"
            name "Alsa"
            mixer_type "software"
          }
          replaygain "off"
        '';
      };

      dconf = {
        enable = true;
        settings = {
          "org/gnome/desktop/interface" = {
            font-name = "Mononoki Nerd Font Propo 12";
            monospace-font-name = "Mononoki Nerd Font Mono 12";
            gtk-theme = "adw-gtk3-dark";
            icon-theme = "Tela-grey-dark";
          };
        };
      };

      gtk = {
        enable = true;
        theme = {
          name = "adw-gtk3-dark";
          package = pkgs.adw-gtk3;
        };
        font = {
          name = "Mononoki Nerd Font Propo";
          size = 12;
        };
      };
    };
    backupFileExtension = "backup";
  };
  
  # ============================================================
  # AUDIO & BLUETOOTH
  # ============================================================
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
    wireplumber.extraConfig = {
      "50-bluez-config" = {
        "monitor.bluez.properties" = {
          "bluez5.enable-msbc" = true;
          "bluez5.enable-sbc-xq" = true;
          "bluez5.enable-hw-volume" = true;
          "bluez5.codecs" = [ "sbc" "aac" "ldac" ];
          "bluez5.ldac-quality" = "high";
        };
      };
      "10-reset-volume-curve" = {
        "monitor.alsa.properties" = {
          # "linear" вернет максимальную громкость на средних процентах
          "alsa.volume-method" = "linear";
          "alsa.reserve-loopback" = false;
        };
        "node.rules" = [
          {
            matches = [ { "node.name" = "~alsa_output.*"; } ];
            actions = {
              update-props = {
                # Игнорируем заниженную базу dB из аппаратных драйверов
                "ignore-db" = true;
                # Выставляем софтверный лимит на честный максимум
                "volume.max" = 1.0;
              };
            };
          }
        ];
      };
    };
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings.General.Enable = "Source,Sink,Media,Socket";
  };
  services.blueman.enable = true;

  # ============================================================
  # GAMING
  # ============================================================
  programs.steam = {
    enable = true;
    extraPackages = with pkgs; [
      libgudev libvdpau libusb1 speex SDL2 openal
      libglvnd gtk3 mono dbus
    ];
    extraCompatPackages = [
      pkgs.proton-ge-bin
    ];
  };

  # ============================================================
  # FONTS
  # ============================================================
  fonts = {
    packages = with pkgs; [
      iosevka-bin 
      noto-fonts-cjk-sans
      noto-fonts-monochrome-emoji
      nerd-fonts.mononoki
      liberation_ttf
      corefonts
      monocraft
      miracode
      source-han-sans
      source-han-serif
    ];
    fontconfig.enable = true;
    fontconfig.defaultFonts = {
      sansSerif = [ "Source Han Sans SC" "Noto Sans CJK SC" ];
      serif = [ "Source Han Serif SC" ];
      emoji = [ "Noto Emoji" ];
    };
  };

  # ============================================================
  # GRAPHICS & HARDWARE
  # ============================================================
  hardware.graphics.enable = true;
  hardware.i2c.enable = true;

  environment.variables.HSA_OVERRIDE_GFX_VERSION = "11.0.0";
  hardware.amdgpu.overdrive.enable = true;

  services.hardware.openrgb = {
    enable = true;
    motherboard = "amd";
    startupProfile = "${userConfig.username}";
    package = unstablePkgs.openrgb;
  };

  # ============================================================
  # VIRTUALIZATION
  # ============================================================
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  # ============================================================
  # SERVICES
  # ============================================================
  services.usbmuxd = {
    enable = true;
    package = pkgs.usbmuxd2;
  };

  services.printing = {
    enable = true;
    drivers = [ pkgs.pantum-driver ];
  };
  
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  programs.ydotool.enable = true;
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [ glib glibc ];

  # ============================================================
  # FILE SYSTEMS
  # ============================================================
  services.gvfs.enable = true;

  services.udisks2 = {
    enable = true;
    settings."udisks2.conf" = {
      udisks2 = {
        modules = ["*"];
        modules_load_preference = "ondemand";
      };
      defaults.encryption = "luks2";
    };
  };

  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (action.id == "org.freedesktop.udisks2.filesystem-mount" ||
          action.id == "org.freedesktop.udisks2.filesystem-mount-system" ||
          action.id == "org.freedesktop.udisks2.erase-device" ||
          action.id == "org.freedesktop.udisks2.modify-device" ||
          action.id == "org.freedesktop.udisks2.filesystem-unmount" ||
          action.id == "org.freedesktop.udisks2.filesystem-unmount-others") {
        return polkit.Result.YES;
      }
    });
    
    polkit.addRule(function(action, subject) {
      if (action.id == "org.freedesktop.Flatpak.app-install" ||
          action.id == "org.freedesktop.Flatpak.runtime-install" ||
          action.id == "org.freedesktop.Flatpak.app-uninstall" ||
          action.id == "org.freedesktop.Flatpak.runtime-uninstall" ||
          action.id == "org.freedesktop.Flatpak.modify-repo") {
        if (subject.isInGroup("wheel")) {
          return polkit.Result.YES;
        }
      }
    });
  '';

  services.flatpak.enable = true;

  # ============================================================
  # UDEV RULES
  # ============================================================
  services.udev.extraRules = ''
    # i2c ddcutil
    KERNEL=="i2c-[0-9]*", GROUP="i2c", MODE="0666"
    
    # OpenRGB
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", MODE="0666", TAG+="uaccess"
    SUBSYSTEM=="usb", MODE="0666", TAG+="uaccess"

    # Attach Shark
    KERNEL=="hidraw*", ATTRS{idVendor}=="1d57", ATTRS{idProduct}=="212c", TAG+="uaccess"
  '';

  # ============================================================
  # NIX & BOOT
  # ============================================================
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 10d";
  };

  boot.loader = {
    grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
      useOSProber = true;
    };
    efi.canTouchEfiVariables = true;
  };

  boot.kernelPackages = pkgs.linuxPackages_zen;

  # Явно подключаем модули ядра для iptables и ipset
  boot.kernelModules = [
    "i2c-dev"
    "i2c-piix4"
    "tun"
    "dummy"
    "wireguard"
    "ip_set"
    "ip_set_hash_ip"
    "ip_set_hash_ipport"
    "xt_set"
  ];

  boot.kernelParams = [
    "fbcon=font:ter-v32n"
    "vt.default_utf8=1"
    "consoleblank=0"
    "pcie_aspm=off"

    "vt.default_red=56,220,95,224,124,220,147,220,96,220,95,224,124,220,147,240"
    "vt.default_grn=56,163,127,207,184,140,224,220,96,163,127,207,184,140,224,240"
    "vt.default_blu=56,163,95,159,187,195,227,204,96,163,95,159,187,195,227,240"
  ];

  boot.extraModprobeConfig = ''
    options iwlwifi power_save=0
  '';

  # ============================================================
  # CONSOLE
  # ============================================================
  console = {
    font = "ter-v32n";
    packages = with pkgs; [ terminus_font kbd spleen unifont ];
    earlySetup = true;
    useXkbConfig = true;
  };

  services.xserver.xkb = {
    layout = "us,ru";
    options = "grp:caps_toggle,caps:shiftlock";
  };

  systemd.services.set-tty-colors = {
    description = "Apply Zenburn TTY colors and font";
    wantedBy = [ "multi-user.target" ];
    after = [ "systemd-vconsole-setup.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      ${pkgs.kbd}/bin/setfont ter-v32n

      for tty in /dev/tty{1..6}; do
        ${pkgs.kbd}/bin/setfont -C "$tty" ter-v32n
        echo -en "\e]P0383838" > "$tty"
        echo -en "\e]P1dca3a3" > "$tty"
        echo -en "\e]P25f7f5f" > "$tty"
        echo -en "\e]P3e0cf9f" > "$tty"
        echo -en "\e]P47cb8bb" > "$tty"
        echo -en "\e]P5dc8cc3" > "$tty"
        echo -en "\e]P693e0e3" > "$tty"
        echo -en "\e]P7dcdccc" > "$tty"
        echo -en "\e]P8606060" > "$tty"
        echo -en "\e]P9dca3a3" > "$tty"
        echo -en "\e]PA5f7f5f" > "$tty"
        echo -en "\e]PBe0cf9f" > "$tty"
        echo -en "\e]PC7cb8bb" > "$tty"
        echo -en "\e]PDdc8cc3" > "$tty"
        echo -en "\e]PE93e0e3" > "$tty"
        echo -en "\e]PFf0f0f0" > "$tty"
      done
    '';
  };

  # ============================================================
  # NETWORK & FIREWALL
  # ============================================================
  networking.hostName = "${userConfig.hostname}";
  networking.networkmanager.enable = true;
  hardware.enableRedistributableFirmware = true;
  
  services.happ.enable = true;
  systemd.tmpfiles.rules = [ "L+ /var/lib/dbus/machine-id - - - - /etc/machine-id" ];
  
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };
  
  networking.firewall = {
    extraPackages = [ pkgs.ipset ];
    enable = true;
    allowedTCPPortRanges = [ { from = 1714; to = 1764; } ];
    allowedUDPPortRanges = [ { from = 1714; to = 1764; } ];
   
    extraCommands = ''
      if ! ipset --quiet list upnp; then
        ipset create upnp hash:ip,port timeout 3 || true
      fi
      iptables -A OUTPUT -d 239.255.255.250/32 -p udp -m udp --dport 1900 -j SET --add-set upnp src,src --exist || true
      iptables -A nixos-fw -p udp -m set --match-set upnp dst,dst -j nixos-fw-accept || true
          
      # Minecraft (локальная сеть)
      iptables -A nixos-fw -p tcp --dport 25565 -s 192.168.2.0/24 -j nixos-fw-accept || true
      iptables -A nixos-fw -p udp --dport 25565 -s 192.168.2.0/24 -j nixos-fw-accept || true
      iptables -A INPUT -i tun0 -j ACCEPT || true
      iptables -A OUTPUT -o tun0 -j ACCEPT || true
      iptables -A nixos-fw -i tun+ -j nixos-fw-accept || true
      iptables -A nixos-fw -o tun+ -j nixos-fw-accept || true
      iptables -A nixos-fw -i tun1 -j nixos-fw-accept || true
      iptables -A nixos-fw -o tun1 -j nixos-fw-accept || true
      iptables -A nixos-forward -i tun+ -j nixos-fw-accept || true
      iptables -A nixos-forward -o tun+ -j nixos-fw-accept || true
  
      # Прокси Throne
      iptables -A nixos-fw -p tcp --dport 2080 -s 192.168.2.0/24 -j nixos-fw-accept || true
      iptables -A nixos-fw -p tcp --dport 1080 -s 192.168.2.0/24 -j nixos-fw-accept || true
      
      # Маркировка трафика
      iptables -t mangle -A OUTPUT -p udp --dport 19241 -j MARK --set-mark 68 || true
      iptables -I nixos-fw 1 -p udp --dport 19241 -j ACCEPT || true

      # Lofi Engine
      iptables -A nixos-fw -p tcp --dport 1420 -s 192.168.2.0/24 -j nixos-fw-accept || true
      iptables -A nixos-fw -p udp --dport 1420 -s 192.168.2.0/24 -j nixos-fw-accept || true
    '';
  };
   
  programs.amnezia-vpn.enable = true;

  # ============================================================
  # LOCALIZATION
  # ============================================================
  time.timeZone = "${userConfig.timezone}";
  i18n.defaultLocale = "en_GB.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "ru_RU.UTF-8";
    LC_IDENTIFICATION = "ru_RU.UTF-8";
    LC_MEASUREMENT = "ru_RU.UTF-8";
    LC_MONETARY = "ru_RU.UTF-8";
    LC_NAME = "ru_RU.UTF-8";
    LC_NUMERIC = "ru_RU.UTF-8";
    LC_PAPER = "ru_RU.UTF-8";
    LC_TELEPHONE = "ru_RU.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };

  system.stateVersion = "25.11";
}
