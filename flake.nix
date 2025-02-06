{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  name = "LFS-env";

  buildInputs = [
    pkgs.vagrant
  ];

  # Optional: Additional environment setup
  shellHook = ''
    echo "Vagrant installion successfull"
    vagrant plugin install vagrant-cachier
  '';
}