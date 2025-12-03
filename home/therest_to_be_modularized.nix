{ pkgs, misc, lib, flake, ... }:
let
  inherit (flake) inputs;
  inherit (inputs) self;
  clockify = pkgs.callPackage "${self}/packages/clockify.nix" { };
in
{
  home.packages = with pkgs; [
    bat
    fd
    gdu
    fzf
    jq
    yq-go
    neofetch
    fastfetch
    htop
    cheat
    just
    ghc
    stack
    zeal
    doxygen
    rubber
    graphviz
    texlive.combined.scheme-full
    pandoc
    pdftk
    libreoffice-qt
    scribus
    hledger
    hledger-ui
    hledger-web
    hledger-interest
    rustup
    cargo-generate
    cargo-edit
    cargo-watch
    wasm-pack
    # cargo-feature # BROKEN in 24.11
    cargo-features-manager
    cargo-expand
    cargo-outdated
    cargo-tauri
    cargo-mobile2
    perseus-cli
    trunk
    diesel-cli
    hyperfine # cli benchmarking utility
    github-cli
    glab
    git-town
    delta
    git-ignore
    git-absorb
    pre-commit
    qgit
    thicket
    git-subrepo
    mercurial
    darcs
    pijul
    subversion
    gist
    git-cliff
    git-standup
    gitflow
    gitleaks
    quilt
    commitizen
    cmake
    cmake-format
    ninja
    clang-tools
    clang-analyzer
    whatstyle
    doctl
    # vault-bin
    caddy
    hugo
    ngrok
    loccount
    devbox
    devenv
    plantuml
    nixpkgs-fmt
    bibtex-tidy
    shfmt
    fantomas
    stylelint
    nodejs
    nodePackages.yarn
    nodePackages.prettier
    clang_20
    ccls
    sqlite
    unstable.nodePackages.vercel
    heroku
    gdb
    lldb
    valgrind
    kdePackages.kcachegrind
    massif-visualizer
    heaptrack
    # elf-dissector
    kdiff3
    meld
    pkg-config
    tor-browser
    diceware
    qtpass
    gopass
    gopass-jsonapi
    lrzip
    zip
    unzip
    unrar
    xar
    lz4
    lzop
    rzip
    upx
    xdelta
    zstd
    zsync
    p7zip
    zpaq
    brotli
    lzip
    squashfsTools
    obs-studio
    gimp
    krita
    povray
    inkscape
    sweethome3d.application
    sweethome3d.textures-editor
    sweethome3d.furniture-editor
    synfigstudio
    lmms
    wakatime-cli
    unstable.zoom-us
    telegram-desktop
    unstable.asdf-vm
    go
    gotools
    unstable.zed-editor

    ## From system.environment:

    # Utilities
    wget
    usbutils
    gnupg
    cpufrequtils
    psmisc
    file
    dig
    lesspipe
    lm_sensors
    lsof
    pciutils
    imagemagick
    lsb-release
    geoipWithDatabase
    signing-party
    openssl
    tree
    nox
    lshw
    inetutils
    # bsdgames # colides with mono
    mc
    fpart
    parted
    gptfdisk
    appimage-run
    btrfs-progs
    zfs
    zfs-replicate
    sanoid
    znapzend
    vorta
    openrazer-daemon
    razergenie
    hwinfo
    mkpasswd
    pwgen
    python312Packages.xattr
    pxattr
    sysstat
    smartmontools
    msr-tools
    xorg.xev
    xorg.xwininfo
    hddtemp
    unstable.cachix
    exfat
    dosfstools
    fzf
    # dyndnsc # BROKEN 22.11 (from sanic)
    wireguard-tools
    unstable.bootiso
    socat
    pcsc-tools
    pcsclite
    aria
    persepolis
    strongswanNM
    wireguard-tools
    protonvpn-gui
    protonmail-bridge-gui
    can-utils
    cantoolz
    skim
    csvtool
    # taskade
    httpie
    #sox

    # Messaging
    discord

    # Xorg
    xorg.xhost
    xorg.xdpyinfo
    glxinfo
    clinfo
    vulkan-tools
    wayland-utils

    # File systems
    ntfs3g
    yandex-disk
    megasync
    onedrive
    onedrivegui
    dropbox

    # Finances
    # binance

    # Games
    (steam.override {
      extraPkgs = pkgs: [
        vulkan-tools
        vulkan-loader
        glxinfo
        gtk3
        gtk3-x11
        ocl-icd
        librsvg
      ];
    })
    (steam.override {
      extraPkgs = pkgs: [
        vulkan-tools
        vulkan-loader
        glxinfo
        gtk3
        gtk3-x11
        ocl-icd
        librsvg
      ];
    }).run
    protontricks

    # Multimedia
    smplayer
    mpv
    yt-dlp
    mkvtoolnix
    frei0r
    ffmpeg-full
    spotify
    soundkonverter
    vlc
    # openshot-qt
    # avidemux
    # davinci-resolve
    qpwgraph # pipewire visualisation tool
    unstable.kdePackages.kdenlive
    avidemux

    # K8s
    kubernetes-helm
    terraform
    unstable.pulumi
    k9s

    # Antivirus
    clamav # fprot
    clamtk

    # Databases
    # pgadmin # disable for not
    pgmanage
    dbeaver-bin

    jetbrains.clion
    jetbrains.goland
    jetbrains.pycharm-professional
    jetbrains.rust-rover
    jetbrains.datagrip
    jetbrains.writerside
    jetbrains.webstorm
    joplin-desktop

    html2text

    # Tailscale GUI
    ktailctl

    # Rust replacement for coreutils
    uutils-coreutils-noprefix

    # Networking
    nmap
    rustscan
  ];
}
