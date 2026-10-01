# Python development toolchain for ML/CV engineering.
# Global lightweight utilities: uv manages Python installations and venvs,
# ruff provides instant linting and formatting, and basedpyright acts as
# the fast static type checker / LSP server.
# Heavy packages (PyTorch, OpenCV, CUDA wheels) live inside project-local .venv
# and resolve system libraries via nix-ld.
{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    uv
    ruff
    basedpyright
  ];
}
