{ pkgs, inputs, ... }:
{
  imports = [
    inputs.noctalia.nixosModules.default
  ];

  # Enable the Noctalia shell service/module
  services.noctalia-shell.enable = true;

  # Optional: also install the package (nice for having the CLI/wrapper available)
  environment.systemPackages = [
    inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}