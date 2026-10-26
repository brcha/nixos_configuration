# Submodule for definint users
{ lib, ... }:
let
  userSubmodule = lib.types.submodule {
    options = {
      name = lib.mkOption {
        type = lib.types.str;
        description = ''
          Display name of the user
        '';
      };
      email = lib.mkOption {
        type = lib.types.str;
        description = ''
          e-mail address of the user
        '';
      };
      hashedPasswordFile = lib.mkOption {
        type = lib.types.str;
        description = ''
          Hashed password file for the user
        '';
      };
      sshKeys = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        description = ''
          SSH public keys
        '';
      };
      gpgKeys = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        description = ''
          GPG key IDs
        '';
      };
      gitSignKey = lib.mkOption {
        type = lib.types.str;
        description = ''
          Key for signing git commits

          Can be either gpg key id, or ~/.ssh/id_ed25519
        '';
      };
      gitSignFormat = lib.mkOption {
        type = lib.types.str;
        description = ''
          Use OpenPGP or OpenSSH keys for signing git commits

          Whatever goes into git's gpg.format config
        '';
      };
      location = {
        city = lib.mkOption {
          type = lib.types.str;
          description = ''
            City for weather reports (wttr.in)
          '';
        };
        latitude = lib.mkOption {
          type = lib.types.str;
          description = ''
            Latitude for sunrise and sunset
          '';
        };
        longitude = lib.mkOption {
          type = lib.types.str;
          description = ''
            Longitude for sunrise and sunset
          '';
        };
      };
      ledgerFile = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = ''
          hledger journal, relative to the home directory
        '';
      };
      todoFile = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = ''
          todo.txt file, relative to the home directory
        '';
      };
    };
  };

  peopleSubmodule = lib.types.submodule {
    options = {
      users = lib.mkOption {
        type = lib.types.attrsOf userSubmodule;
        description = ''
          All users defined for the systems
        '';
      };
      me = lib.mkOption {
        type = lib.types.str;
        description = ''
          My username
        '';
      };
    };
  };
in
{
  options = {
    people = lib.mkOption {
      type = peopleSubmodule;
    };
  };
  config = {
    people = {
      me = "brcha";
      users = import ./users.nix;
    };
  };
}
