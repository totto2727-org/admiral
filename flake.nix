{
  description = "Standalone MoonBit Admiral library";

  inputs = {
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1";
    moonbit-overlay = {
      url = "github:moonbit-community/moonbit-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, moonbit-overlay, ... }:
    let
      supportedSystems = [
        "aarch64-darwin"
        "x86_64-linux"
      ];
      forEachSystem = nixpkgs.lib.genAttrs supportedSystems;
      mkPkgs =
        system:
        import nixpkgs {
          inherit system;
          overlays = [ moonbit-overlay.overlays.default ];
        };
    in
    {
      devShells = forEachSystem (
        system:
        let
          pkgs = mkPkgs system;
        in
        rec {
          default = pkgs.mkShell {
            packages = [
              # Keep the existing compiler while changing the toolchain provider.
              pkgs.moonbit-bin."v0.10.9+6e6c44045+fc2a4ee"
            ];
            shellHook = ''
              # Enable Git Hook
              vp config
            '';
          };
          ci = default.overrideAttrs (_: { shellHook = ""; });
        }
      );
    };
}
