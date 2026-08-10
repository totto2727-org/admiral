{
  description = "Standalone MoonBit Admiral library";

  inputs = {
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1";
    moonbit-overlay = {
      url = "github:totto2727/moonbit-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    moon-registry = {
      url = "git+https://mooncakes.io/git/index";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, moonbit-overlay, moon-registry }:
    let
      supportedSystems = [
        "aarch64-darwin"
        "x86_64-linux"
      ];
      forEachSystem = nixpkgs.lib.genAttrs supportedSystems;
      mkPkgs = system: import nixpkgs {
        inherit system;
        overlays = [ moonbit-overlay.overlays.default ];
      };
      mkMoonHome = pkgs:
        pkgs.moonPlatform.bundleWithRegistry {
          cachedRegistry = pkgs.moonPlatform.buildCachedRegistry {
            moonModDepsSet = {
              "mizchi/tui" = "0.10.0";
              "moonbitlang/async" = "0.20.3";
              "moonbitlang/x" = "0.4.47";
              "totto2727/lens" = "0.4.0";
            };
            registryIndexSrc = moon-registry;
          };
        };
      mkMoonCheck = pkgs: name: command:
        let
          moonHome = mkMoonHome pkgs;
        in
        pkgs.runCommand name {
          nativeBuildInputs = [ moonHome pkgs.nodejs pkgs.stdenv.cc ];
        } ''
          export HOME="$TMPDIR/home"
          mkdir -p "$HOME" "$TMPDIR/repository"
          cp -r ${self}/. "$TMPDIR/repository"
          chmod -R u+w "$TMPDIR/repository"
          cd "$TMPDIR/repository"
          ${command}
          touch "$out"
        '';
    in
    {
      devShells = forEachSystem (
        system:
        let
          pkgs = mkPkgs system;
          moonHome = mkMoonHome pkgs;
        in
        {
          default = pkgs.mkShell {
            packages = [
              moonHome
              pkgs.clang
              pkgs.nodejs_24
            ];
          };
        }
      );

      checks = forEachSystem (
        system:
        let
          pkgs = mkPkgs system;
        in
        {
          moon = mkMoonCheck pkgs "admiral-moon-check" ''
            moon info
            moon check --target native
            moon test --target native
          '';
          package-list = mkMoonCheck pkgs "admiral-package-list" ''
            moon package --list
          '';
        }
      );
    };
}
