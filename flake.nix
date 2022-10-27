{
  description = "purescript-electron-example";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:nixos/nixpkgs";
    npmlock2nix-src = {
      flake = false;
      url = "github:nix-community/npmlock2nix";
    };
    pre-commit-hooks = {
      url = "github:tfc/pre-commit-hooks.nix?ref=purs-tidy";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    purs-nix-input.url = "github:ursi/purs-nix";
  };

  outputs =
    { self
    , flake-parts
    , nixpkgs
    , npmlock2nix-src
    , pre-commit-hooks
    , purs-nix-input
    }:
    flake-parts.lib.mkFlake { inherit self; } {
      systems = [ "x86_64-linux" ];
      perSystem = { config, self', inputs', pkgs, system, ... }:
        let
          purs-nix = purs-nix-input { inherit system; };
          npmlock2nix = import npmlock2nix-src { inherit pkgs; };

          filteredSrc = pkgs.lib.sourceByRegex ./. [
            "^src.*"
            "^package.json$"
            "^package-lock.json$"
          ];

          ps = purs-nix.purs {
            dependencies = with purs-nix.ps-pkgs; [
              console
              effect
              prelude

              # electron lib
              yoga-json
              web-events
              untagged-union
              node-path
              aff
              aff-promise
              node-buffer

              # renderer stuff
              web-html
              react-basic-hooks
              react-basic-dom
            ];

            dir = filteredSrc;
          };
        in
        {
          devShells.default = pkgs.mkShell {
            shellHook = ''
              ${config.checks.pre-commit-check.shellHook}
            '';
            nativeBuildInputs = with pkgs; [
              (ps.command { })
              nodejs
              electron
            ];
          };

          packages = {
            default = config.packages.bundle;
            inherit (ps) bundle;
          };

          checks = {
            pre-commit-check = pre-commit-hooks.lib.${system}.run {
              src = ./.;
              hooks = {
                nixpkgs-fmt.enable = true;
                purs-tidy.enable = true;
                statix.enable = true;
              };
            };
          };
        };
    };
}
