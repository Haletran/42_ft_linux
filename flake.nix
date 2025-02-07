{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  name = "LFS-env";

  buildInputs = [
    pkgs.vagrant
  ];

  # Optional: Additional environment setup
  shellHook = ''
    echo "Vagrant installion successfull"
    # if problem with dependencies run this : 
    # export VAGRANT_DISABLE_STRICT_DEPENDENCY_ENFORCEMENT=1
    vagrant plugin install vagrant-cachier
    vagrant plugin install vagrant-disksize
    export VAGRANT_EXPERIMENTAL=disks
  '';
}