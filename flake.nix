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

        # Version configurations
        versions = {
          "3.1.1" = {
            sha256 = {
              arm-macos = "sha256-XAS45+Av/EhTH0d1LSH2f/hRyXgb8jx2aCIyTWPSHPQ=";
              x86_64-macos = "sha256-5TIlnxPrN7fPZECpP6Rf9SxJWvNKV8b8NXSc3EpUTzY=";
              arm-linux = "sha256-XxkYdmDLV6T7KvZ1PZ6nWKZBCPLnj6qVZ7vKZJQqZg=";
              x86_64-linux = "sha256-NZijbnWU53P12Nh47NpFn70wtowB5aors9vV04/NErY=";
            };
          };
          "7.0.1" = {
            sha256 = {
              arm-macos = "17v9khbazzbxni3dv5rx94csg9pafb7ffcg0b49czj2l8yvn3368";
              x86_64-macos = "0fmp4adfgvq9651838n9nsyr05a489pgv4hmg17ybrd786g64lwb";
              arm-linux = "1qd0j2synjfc2wz5j9x296jxyignljfzkwhvwxy002lx5ippsl1m";
              x86_64-linux = "17kv3y1m8hpmxfxc1kmy09rv9wiim37la980dvd0qf3pa0vw471n";
            };
          };
        };

        # Function to create a Javy derivation for a specific version
        mkJavy = version: versionInfo:
          let
            platformKey =
              if pkgs.stdenv.isDarwin && pkgs.stdenv.isAarch64 then "arm-macos"
              else if pkgs.stdenv.isDarwin then "x86_64-macos"
              else if pkgs.stdenv.isLinux && pkgs.stdenv.isAarch64 then "arm-linux"
              else "x86_64-linux";
          in
          pkgs.stdenv.mkDerivation {
            pname = "javy";
            inherit version;

            src = pkgs.fetchurl {
              url = "https://github.com/bytecodealliance/javy/releases/download/v${version}/javy-${platformKey}-v${version}.gz";
              sha256 = versionInfo.sha256.${platformKey};
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
              description = "JavaScript to WebAssembly toolchain (version ${version})";
              homepage = "https://github.com/bytecodealliance/javy";
              platforms = pkgs.lib.platforms.unix;
            };
          };

        # Create derivations for all versions
        javyVersions = lib.mapAttrs mkJavy versions;

        # Default to the latest version
        defaultJavy = javyVersions."7.0.1";

        # Function to create a test for a specific Javy version
        mkJavyTest = name: javy:
          pkgs.runCommand "javy-${name}-hello-world-test" {
            buildInputs = [ javy pkgs.wasmtime ];
          } ''
            # Set HOME to a writable directory for wasmtime cache
            export HOME=$TMPDIR

            # Create a simple hello world JavaScript file
            cat > hello.js << 'EOF'
            console.log("Hello, World!");
            EOF

            # Compile the JavaScript to WebAssembly using Javy
            echo "Testing Javy ${name}..."
            echo "Compiling hello.js to WebAssembly..."

            # Try build command first (v4+), fallback to compile for older versions
            if javy build hello.js -o hello.wasm 2>/dev/null; then
              echo "Used 'build' command"
            elif javy compile hello.js -o hello.wasm 2>/dev/null; then
              echo "Used 'compile' command"
            else
              echo "ERROR: Failed to compile with both 'build' and 'compile' commands"
              exit 1
            fi

            # Check that the wasm file was created
            if [ ! -f hello.wasm ]; then
              echo "ERROR: hello.wasm was not created"
              exit 1
            fi

            # Run the WebAssembly module with wasmtime and capture output
            echo "Running hello.wasm with wasmtime..."
            output=$(wasmtime run hello.wasm 2>&1)

            # Check the output is correct
            expected="Hello, World!"
            if [ "$output" = "$expected" ]; then
              echo "SUCCESS: Output matches expected: $output"
            else
              echo "ERROR: Output mismatch"
              echo "Expected: $expected"
              echo "Got: $output"
              exit 1
            fi

            # Create a success marker for the derivation
            touch $out
            echo "Test passed successfully for Javy ${name}!" >> $out
          '';

        # Create tests for all versions
        javyTests = lib.mapAttrs mkJavyTest javyVersions;

      in
      {
        packages = {
          default = defaultJavy;
          javy = defaultJavy;
        } // lib.mapAttrs' (version: drv:
          lib.nameValuePair "javy-${version}" drv
        ) javyVersions;

        apps = {
          default = flake-utils.lib.mkApp {
            drv = defaultJavy;
          };
          javy = flake-utils.lib.mkApp {
            drv = defaultJavy;
          };
        } // lib.mapAttrs' (version: drv:
          lib.nameValuePair "javy-${version}" (flake-utils.lib.mkApp {
            drv = drv;
          })
        ) javyVersions;

        devShells.default = pkgs.mkShell {
          buildInputs = [ defaultJavy ];
        };

        checks = javyTests // {
          # Keep the original test name for backward compatibility
          hello-world = javyTests."7.0.1";
        };
      });
}