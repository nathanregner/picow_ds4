{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-parts.url = "github:hercules-ci/flake-parts";
  };
  outputs =
    inputs@{ devshell, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ devshell.flakeModule ];

      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "i686-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];

      perSystem = (
        { pkgs, ... }:
        {
          devshells.default = {
            packages = with pkgs; [
              clang
              clang-tools
              cmake
              gcc-arm-embedded
              gnumake
              picotool
              python3
            ];

            commands = [
              {
                name = "setup-clangd";
                command = "m compile-commands";
              }
              {
                name = "c";
                command = "cmake -S $PRJ_ROOT -B $PRJ_ROOT/build";
              }
              {
                name = "m";
                command = "make -C $PRJ_ROOT/build -j$(nproc)";
              }
              {
                name = "clean";
                command = "rm -rf $PRJ_ROOT/build";
              }
            ];

            env = [
              {
                name = "CMAKE_CXX_COMPILER";
                eval = "clang++";
              }
              {
                name = "PICO_SDK_PATH";
                eval = "$PRJ_ROOT/pico-sdk/";
              }
              {
                name = "PICO_PLATFORM";
                value = "rp2350";
              }
              {
                name = "PICO_BOARD";
                value = "pico2_w";
              }
            ];
          };
        }
      );
    };
}
