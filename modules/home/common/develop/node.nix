{ pkgs, ... }:
{
  home.packages = with pkgs; [
    nodejs
    pnpm
    yarn-berry

    biome
    prettier
    eslint
  ];
}
