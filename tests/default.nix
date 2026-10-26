# Evaluation tests, run by `nix flake check` (`just check`). Only the bare host
# evaluates a whole system; every other case reads option values, which is fast.
{ self, lib, config, ... }:

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
        "kde.enable" = kde.enable;
        "hyprland.enable" = hyprland.enable;
        "hardware.sound.enable" = hardware.sound.enable;
        "hardware.printing.enable" = hardware.printing.enable;
        "hardware.razer.enable" = hardware.razer.enable;
        "virtualisation.docker" = virtualisation.docker;
        "virtualisation.virtualbox" = virtualisation.virtualbox;
        "dev.go" = dev.go;
        "apps.firefox" = apps.firefox;
      }));
      expected = [ ];
    };

    testGroupTurnsOnItsChildren = {
      expr = with (bareWith [{ my.dev.enable = true; my.dev.haskell = false; }]).my.dev; [ go rust haskell ];
      expected = [ true true false ];
    };

    testChildWorksWithTheGroupOff = {
      expr = with (bareWith [{ my.apps.gaming = true; }]).my.apps; [ enable gaming firefox ];
      expected = [ false true false ];
    };

    testGuiGroup = {
      expr = with (bareWith [{ my.gui.enable = true; }]).my.gui; [ flatpak fonts torrents ];
      expected = [ true true true ];
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

    testDesktopsRequireGui = {
      expr = guiMessages (bareWith [{ my.hyprland.enable = true; my.kde.enable = true; }]);
      expected = [ "my.hyprland.enable requires my.gui.enable" "my.kde.enable requires my.gui.enable" ];
    };

    testDesktopsWithGuiPass = {
      expr = guiMessages (bareWith [{ my.hyprland.enable = true; my.kde.enable = true; my.gui.enable = true; }]);
      expected = [ ];
    };
  };

  failures = lib.runTests tests;
in
{
  perSystem = { pkgs, ... }: {
    # Slow (builds VMs), so not under checks; run with `just vmtest`
    legacyPackages.vmTests.ssh = import ./vm-ssh.nix { inherit self pkgs me; };

    checks.eval =
      if failures == [ ] then
        pkgs.runCommand "eval-tests" { } "touch $out"
      else
        throw "evaluation tests failed:\n${builtins.toJSON failures}";
  };
}
