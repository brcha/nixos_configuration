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
        tensorflow-build_2
        #        tensorflow-tensorboard_2
        tensorflow-estimator_2
        pygame
        # Qt
        pyqt6
        pyqt6-webengine
        pyqtgraph
        # Interactive Python
        ipython
        # Quantum computing
        #        qiskit
        # Linter
        pylint
        # Formatter
        autopep8
        yapf
        docformatter
        # For Spyder
        jedi
        parso
      ]))
    tensorman # Excellent utility to run tensorflow through docker easily
    virtualenv
  ];
}
