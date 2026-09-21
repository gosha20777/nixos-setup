# Oh My Pi (omp) — Terminal AI coding agent.
{
  inputs,
  pkgs,
  ...
}:
{
  home.packages = [
    inputs.oh-my-pi.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
