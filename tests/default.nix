# Evaluation tests, run by `nix flake check` (`just check`). Only the bare host
# and the everything-on case evaluate a whole system; every other case reads
# option values, which is fast.
{ self, inputs, lib, config, ... }:

let
  me = config.people.me;
  hosts = import ./lib.nix { inherit self; };
  inherit (hosts) bare bareWith withHomeWith;

  # Messages of the assertions that fail
  failing = config: map (a: a.message) (lib.filter (a: !a.assertion) config.assertions);
  guiMessages = config: lib.filter (lib.hasSuffix "requires my.gui.enable") (failing config);

  tests = {
    testBareHostEvaluates = {
      expr = lib.hasSuffix ".drv" bare.config.system.build.toplevel.drvPath;
      expected = true;
    };

    # Names the switches that are on, so a failure says which one
    testSwitchesAreOffByDefault = {
      expr = lib.attrNames (lib.filterAttrs (_: on: on) (with bare.config.my; {
        "gui.enable" = gui.enable;
        "gui.fonts" = gui.fonts;
        "gui.sshAgent" = gui.sshAgent;
        "kde.enable" = kde.enable;
        "hyprland.enable" = hyprland.enable;
        "hardware.sound.enable" = hardware.sound.enable;
        "hardware.printing.enable" = hardware.printing.enable;
        "hardware.razer.enable" = hardware.razer.enable;
        "virtualisation.docker" = virtualisation.docker;
        "virtualisation.virtualbox" = virtualisation.virtualbox;
        "dev.go" = dev.go;
        "apps.firefox" = apps.firefox;
      } // lib.mapAttrs' (name: s: lib.nameValuePair "servers.${name}.enable" s.enable) servers));
      expected = [ ];
    };

    # Modules no host uses must keep evaluating; one evaluation with everything on
    testEverythingEvaluates = {
      expr = lib.hasSuffix ".drv"
        (withHomeWith [{
          my = {
            servers = lib.mapAttrs (_: _: { enable = true; }) bare.config.my.servers;
            gui.enable = true;
            kde.enable = true;
            hyprland.enable = true;
            hardware = {
              sound.enable = true;
              printing.enable = true;
              razer.enable = true;
            };
            virtualisation = {
              enable = true;
              virtualbox = true;
            };
            dev.enable = true;
            apps = {
              enable = true;
              jetbrains = true;
              vscode = true;
            };
          };
        }]).system.build.toplevel.drvPath;
      expected = true;
    };

    # System defaults apply everywhere, ZFS maintenance only with ZFS, and a machine can override
    testSystemDefaults = {
      expr = [
        bare.config.zramSwap.memoryPercent
        bare.config.services.zfs.autoScrub.enable
        (bareWith [{ zramSwap.memoryPercent = 50; }]).zramSwap.memoryPercent
        bare.config.time.timeZone
        (bareWith [{ time.timeZone = "UTC"; }]).time.timeZone
      ];
      expected = [ 25 false 50 "Europe/Belgrade" "UTC" ];
    };

    testGroupTurnsOnItsChildren = {
      expr = with (bareWith [{ my.dev.enable = true; my.dev.haskell = false; }]).my.dev; [ go rust haskell ];
      expected = [ true true false ];
    };

    testChildWorksWithTheGroupOff = {
      expr = with (bareWith [{ my.apps.gaming = true; }]).my.apps; [ enable gaming firefox ];
      expected = [ false true false ];
    };

    # SmartDNS answers every name; only the tailnet goes to MagicDNS
    testTailscaleDns = {
      expr = with (bareWith [{ my.servers.tailscale.enable = true; }]); [
        networking.nameservers
        services.resolved.settings.Resolve.Domains
        services.resolved.dnsDelegates.tailnet.Delegate
        (lib.elem "--accept-dns=false" services.tailscale.extraSetFlags)
      ];
      expected = [
        [ "127.0.0.1" ]
        [ "~." ]
        { DNS = "100.100.100.100"; Domains = "polecat-grue.ts.net"; }
        true
      ];
    };

    testGuiGroup = {
      expr = with (bareWith [{ my.gui.enable = true; }]).my.gui; [ flatpak fonts sshAgent torrents ];
      expected = [ true true true true ];
    };

    # gcr 3, not gcr_4, ships the passphrase prompter gcr-ssh-agent uses
    testGuiSshAgent =
      let
        on = bareWith [{ my.gui.enable = true; }];
        off = bareWith [{ my.gui.enable = true; my.gui.sshAgent = false; }];
        hasGcr3 = config: lib.any (p: (p.pname or "") == "gcr" && lib.versionOlder p.version "4") config.services.dbus.packages;
      in
      {
        expr = [ on.services.gnome.gcr-ssh-agent.enable (hasGcr3 on) off.services.gnome.gcr-ssh-agent.enable ];
        expected = [ true true false ];
      };

    testVirtualisationGroupLeavesVirtualboxOff =
      let config = bareWith [{ my.virtualisation.enable = true; }];
      in {
        expr = [
          config.virtualisation.docker.enable
          config.virtualisation.vmware.host.enable
          config.virtualisation.virtualbox.host.enable
        ];
        expected = [ true true false ];
      };

    testSwitchesReachHomeManager =
      let
        config = withHomeWith [{ my.dev.go = true; my.hyprland.enable = true; my.gui.enable = true; }];
        home = config.home-manager.users.${me}.my;
      in
      {
        expr = [ home.dev.go home.dev.rust home.hyprland.enable home.kde.enable ];
        expected = [ true false true false ];
      };

    # Hardware tools are on by default and reach home-manager; WSL turns them off
    testHardwareToolsSwitch =
      let
        hasZfs = config: lib.any (p: lib.hasPrefix "zfs-" (p.name or ""))
          config.home-manager.users.${me}.home.packages;
      in
      {
        expr = [
          (hasZfs (withHomeWith [ ]))
          (hasZfs (withHomeWith [{ my.tools.hardware = false; }]))
        ];
        expected = [ true false ];
      };

    testDesktopsRequireGui = {
      expr = guiMessages (bareWith [{ my.hyprland.enable = true; my.kde.enable = true; }]);
      expected = [ "my.hyprland.enable requires my.gui.enable" "my.kde.enable requires my.gui.enable" ];
    };

    testDesktopsWithGuiPass = {
      expr = guiMessages (bareWith [{ my.hyprland.enable = true; my.kde.enable = true; my.gui.enable = true; }]);
      expected = [ ];
    };

    # KWallet's ksecretd is the only Secret Service provider, in both desktops
    testOneSecretService =
      let config = bareWith [{ my.hyprland.enable = true; my.kde.enable = true; my.gui.enable = true; }];
      in {
        expr = [
          config.services.gnome.gnome-keyring.enable
          config.security.pam.services.login.enableGnomeKeyring
          config.services.gnome.gcr-ssh-agent.enable
          config.xdg.portal.config.hyprland."org.freedesktop.impl.portal.Secret"
        ];
        expected = [ false false true "kwallet" ];
      };
  };

  failures = lib.runTests tests;

  platformHomes = import ./platforms.nix { inherit self inputs me; };
in
{
  # Activation packages of the Darwin and WSL homes, built for real by CI
  # (the Darwin one on a macOS runner)
  flake.platformHomes = lib.mapAttrs (_: home: home.activationPackage) platformHomes;

  perSystem = { pkgs, ... }:
    let
      # Evaluation only: the text forces each home's activation package to evaluate
      platformChecks = lib.mapAttrs
        (name: home: pkgs.writeText "${name}-evaluates"
          (builtins.unsafeDiscardStringContext home.activationPackage.drvPath))
        platformHomes;
    in
    {
      # Slow (builds VMs), so not under checks; run with `just vmtest`
      legacyPackages.vmTests.ssh = import ./vm-ssh.nix { inherit self pkgs me; };
      # A quick local check of both homes, run with `just platformcheck`
      legacyPackages.platformChecks = platformChecks;

      # The Darwin home can only be evaluated here (CI builds it on a macOS runner);
      # the WSL home is built for real
      checks.darwin-home = platformChecks.darwin;
      checks.wsl-home = platformHomes.wsl.activationPackage;

      checks.eval =
        if failures == [ ] then
          pkgs.runCommand "eval-tests" { } "touch $out"
        else
          throw "evaluation tests failed:\n${builtins.toJSON failures}";
    };
}
