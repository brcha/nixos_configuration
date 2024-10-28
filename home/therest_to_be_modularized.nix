{ pkgs, misc, lib, flake, ... }:
let
  inherit (flake) inputs;
  inherit (inputs) self;
  clockify = pkgs.callPackage "${self}/packages/clockify.nix" { };
in
{
  home.packages = with pkgs; [
    helix
    bat
    fd
    fzf
    jq
    yq-go
    neofetch
    fastfetch
    htop
    cheat
    just
    emacs
    ghc
    stack
    alex
    happy
    haskellPackages.hindent
    stylish-haskell
    hlint
    haskellPackages.apply-refact
    haskellPackages.implicit-hie
    shake
    haskellPackages.retrie
    ghcid
    ihp-new
    zeal
    doxygen
    doxygen_gui
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
    todoist
    nextcloud-client
    rustup
    cargo-generate
    cargo-edit
    cargo-watch
    wasm-pack
    cargo-feature
    cargo-expand
    cargo-outdated
    cargo-tauri
    cargo-mobile2
    perseus-cli
    trunk
    diesel-cli
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
    subversion
    gist
    git-cliff
    git-standup
    gitflow
    gitleaks
    onefetch
    commitizen
    cmake
    cmake-format
    vcpkg
    ninja
    conan
    ccache
    clang-tools
    clang-analyzer
    nasm
    silver-searcher
    docker-compose
    podman-compose
    whatstyle
    doctl
    # vault-bin
    google-cloud-sdk
    caddy
    hugo
    ngrok
    loccount
    devbox
    plantuml
    flutter
    nixpkgs-fmt
    bibtex-tidy
    haskellPackages.cabal-fmt
    shfmt
    fantomas
    stylelint
    nodejs
    nodePackages.yarn
    nodePackages.parcel-bundler
    nodePackages.prettier
    clang_17
    ccls
    mono
    msitools
    dotnet-sdk_8
    godot_4
    elmPackages.elm
    elmPackages.elm-format
    elmPackages.elm-upgrade
    elmPackages.elm-analyse
    elmPackages.elm-doc-preview
    elmPackages.elm-test
    elmPackages.elm-xref
    purescript
    nodePackages.pulp
    nodePackages.purty
    R
    rstudio
    sqlite
    nodePackages.vercel
    heroku
    gdb
    lldb
    valgrind
    kcachegrind
    massif-visualizer
    heaptrack
    # elf-dissector
    kdiff3
    meld
    gnumake
    libtool
    automake
    autoconf
    gnum4
    pkg-config
    brave
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
    blender
    povray
    xfig
    inkscape
    openscad
    natron
    drawio
    sweethome3d.application
    sweethome3d.textures-editor
    sweethome3d.furniture-editor
    synfigstudio
    lmms
    scilab-bin
    octaveFull
    wakatime
    unstable.zoom-us
    tdesktop
    unstable.asdf-vm
    jdk

    ## From system.environment:

    # Utilities
    wget
    zbackup
    usbutils
    nixfmt-rfc-style
    gnupg
    cpufrequtils
    psmisc
    file
    bind
    lesspipe
    lm_sensors
    lsof
    pciutils
    imagemagick
    lsb-release
    inxi
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
    borgbackup
    vorta
    openrazer-daemon
    razergenie
    openrgb
    hwinfo
    iperf
    mkpasswd
    pwgen
    dmg2img
    python39Packages.xattr
    pxattr
    sysstat
    smartmontools
    msr-tools
    xorg.xev
    xorg.xwininfo
    hddtemp
    psensor
    unstable.cachix
    exfat
    dosfstools
    fzf
    # dyndnsc # BROKEN 22.11 (from sanic)
    wireguard-tools
    unstable.bootiso
    socat
    pcsctools
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
    sox

    # Xorg
    xorg.xhost
    xorg.xdpyinfo
    glxinfo
    opencl-info
    clinfo
    vulkan-tools
    wayland-utils

    # Screen Capture & Annotation
    teamviewer

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
    wine-staging
    unstable.winetricks
    playonlinux
    xmoto
    lutris
    zeroad

    # Multimedia
    smplayer
    mpv
    # youtube-dl # BROKEN (still on version 2021)
    mkvtoolnix
    frei0r
    ffmpeg-full
    # unstable.spotify # Uses libgcrypt-1.5.6
    soundkonverter
    vlc
    # openshot-qt
    # avidemux
    # davinci-resolve
    handbrake
    qpwgraph # pipewire visualisation tool

    # Virtualisation
    # virt-manager-qt # BROKEN 24.05
    virt-manager
    qemu
    qemu_kvm
    # aqemu # BROKEN in 21.05
    x11docker
    unstable.minikube
    unstable.kubectl
    unstable.kubernetes-helm
    spice-vdagent
    win-spice

    # Antivirus
    clamav # fprot

    # Databases
    # pgadmin # disable for not
    pgmanage
    dbeaver-bin

    netflix
    unstable.jetbrains-toolbox
    #    clockify
    joplin-desktop

    html2text
  ];
}
