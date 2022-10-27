{
  description = "purescript-electron-example";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:nixos/nixpkgs";
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
    , pre-commit-hooks
    , purs-nix-input
    }:
    flake-parts.lib.mkFlake { inherit self; } {
      systems = [ "x86_64-linux" ];
      perSystem = { config, self', inputs', pkgs, system, ... }:
        let
          purs-nix = purs-nix-input { inherit system; };

          filteredSrc = pkgs.lib.sourceByRegex ./. [
            "^src.*"
            "^package.json$"
            "^package-lock.json$"
            "^build.mjs$"
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

          ps-command = ps.command {
            bundle.esbuild = {
              outfile = "bundle.js";
              minify = true;
            };
          };

          nodeDependencies =
            let
              env = { nativeBuildInputs = [ pkgs.node2nix ]; };
              drv = pkgs.runCommand "node-dependencies" env ''
                mkdir $out
                cd $out
                node2nix --input ${filteredSrc}/package.json \
                         --lock ${filteredSrc}/package-lock.json \
                         --nodejs-18 \
                         --development
              '';
            in
            (import drv { inherit pkgs; inherit (pkgs) nodejs; }).nodeDependencies;
        in
        {
          devShells.default = pkgs.mkShell {
            shellHook = ''
              ${config.checks.pre-commit-check.shellHook}
            '';
            nativeBuildInputs = with pkgs; [
              electron
              node2nix
              nodejs
              ps-command
            ];
          };

          packages = {
            default = config.packages.electron-purescript-example;
            bundle = pkgs.stdenv.mkDerivation {
              name = "electron-purescript-example-bundle";
              src = filteredSrc;
              nativeBuildInputs = with pkgs; [
                nodejs
                ps-command
              ];
              buildPhase = ''
                ln -s ${nodeDependencies}/lib/node_modules ./node_modules
                export PATH="${nodeDependencies}/bin:$PATH"

                npm run build
                eval "$postBuild"
              '';
              installPhase = ''
                cp -r dist $out
              '';
            };
            asar = config.packages.bundle.overrideAttrs (_: {
              name = "electron-purescript-example.asar";
              postBuild = ''
                npx asar pack dist app.asar
              '';
              installPhase = ''
                cp app.asar $out
              '';
            });
            electron-purescript-example = pkgs.writeShellApplication {
              name = "electron-purescript-example";
              runtimeInputs = [ pkgs.electron ];
              text = "electron ${config.packages.bundle}";
            };
          };

          apps = {
            default = config.apps.electron-purescript-example;
            electron-purescript-example = {
              type = "app";
              program = "${config.packages.electron-purescript-example}/bin/electron-purescript-example";
            };
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
