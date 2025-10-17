{
  description = "Javy - JavaScript to WebAssembly toolchain";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = pkgs.lib;

        # Fetch Javy binary from GitHub releases
        javy = pkgs.stdenv.mkDerivation {
          name = "javy";
          version = "3.1.1";

          src = pkgs.fetchurl {
            url = "https://github.com/bytecodealliance/javy/releases/download/v3.1.1/javy-${
              if pkgs.stdenv.isDarwin && pkgs.stdenv.isAarch64 then "arm-macos"
              else if pkgs.stdenv.isDarwin then "x86_64-macos"
              else if pkgs.stdenv.isLinux && pkgs.stdenv.isAarch64 then "arm-linux"
              else "x86_64-linux"
            }-v3.1.1.gz";
            sha256 = if pkgs.stdenv.isDarwin && pkgs.stdenv.isAarch64 then "sha256-XAS45+Av/EhTH0d1LSH2f/hRyXgb8jx2aCIyTWPSHPQ="
              else if pkgs.stdenv.isDarwin then "sha256-5TIlnxPrN7fPZECpP6Rf9SxJWvNKV8b8NXSc3EpUTzY="
              else if pkgs.stdenv.isLinux && pkgs.stdenv.isAarch64 then "sha256-XxkYdmDLV6T7KvZ1PZ6nWKZBCPLnj6qVZ7vKZJQqZg="
              else "sha256-NZijbnWU53P12Nh47NpFn70wtowB5aors9vV04/NErY=";
          };

          nativeBuildInputs = [ pkgs.gzip ] ++ lib.optionals pkgs.stdenv.isLinux [
            pkgs.autoPatchelfHook
          ];

          buildInputs = lib.optionals pkgs.stdenv.isLinux [
            pkgs.stdenv.cc.cc.lib
          ];

          unpackPhase = ''
            gunzip -c $src > javy
          '';

          installPhase = ''
            mkdir -p $out/bin
            cp javy $out/bin/javy
            chmod +x $out/bin/javy
          '';

          meta = {
            description = "JavaScript to WebAssembly toolchain";
            homepage = "https://github.com/bytecodealliance/javy";
            platforms = pkgs.lib.platforms.unix;
          };
        };
      in
      {
        packages = {
          default = javy;
          javy = javy;
        };

        apps = {
          default = flake-utils.lib.mkApp {
            drv = javy;
          };
          javy = flake-utils.lib.mkApp {
            drv = javy;
          };
        };

        devShells.default = pkgs.mkShell {
          buildInputs = [ javy ];
        };
      });
}