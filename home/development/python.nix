{ pkgs, misc, lib, config, ... }:

{
  config = lib.mkIf config.my.dev.python {
    home.packages = with pkgs; [
      # Python
      (python3.withPackages (ps:
        with ps; [
          pip
          yamllint
          # Interactive Python
          ipython
          # Formatter
          autopep8
          # Language server
          python-lsp-server
        ]))
      #    tensorman # Excellent utility to run tensorflow through docker easily
    ];
  };
}
