{ pkgs, misc, lib, ... }:

{
  home.packages = with pkgs; [
    # Python
    (python3.withPackages (ps:
      with ps; [
        pip
        numpy
        scipy
        toolz
        matplotlib
        sphinx
        yamllint
        # Interactive Python
        ipython
        # Linter
        pylint
        # Formatter
        autopep8
        yapf
        docformatter
      ]))
#    tensorman # Excellent utility to run tensorflow through docker easily
    virtualenv
  ];
}
