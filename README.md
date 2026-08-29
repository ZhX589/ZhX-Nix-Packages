# ZhX Nix Packages

我的 NUR (Nix User Repository) 包集合。Fork 自 [NUR 模板仓库](https://github.com/nix-community/nur-packages-template)。

## 使用方法

### 使用 NUR

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    my-packages.url = "github:ZhX589/ZhX-Nix-Packages";
  };

  outputs = { self, nixpkgs, my-packages }: {
    nixosConfigurations.my-machine = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ({ config, pkgs, ... }: {
          environment.systemPackages = [
            my-packages.packages.${pkgs.system}.vutronmusic
          ];
        })
      ];
    };
  };
}
