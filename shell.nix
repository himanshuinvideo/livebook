{ sources ? import ./nix/sources.nix
, pkgs ? import sources.nixpkgs { overlays = [ (import ./nix/rust-overlay.nix) ]; }
}:

with pkgs;
let
  inherit (lib) optional optionals;

  rust = pkgs.rust-bin.stable."1.67.0".default.override {
    # for rust-analyzer
    extensions = [ "rust-src" ];
    targets = [ "wasm32-unknown-unknown" "aarch64-apple-ios" ];
  };

  basePackages = [
    (import ./nix/default.nix { inherit pkgs; })
    pkgs.niv
    cmake
    gcc12
    clang_13
    faiss
    rust
  ];

  inputs = basePackages ++ lib.optionals stdenv.isLinux [ inotify-tools ]
    ++ lib.optionals stdenv.isDarwin
    (with darwin.apple_sdk.frameworks; [ CoreFoundation CoreServices Security SystemConfiguration Foundation ]);

  hooks = ''
    mkdir -p .nix-mix .nix-hex .livebook
    export MIX_HOME=$PWD/.nix-mix
    export HEX_HOME=$PWD/.nix-hex

    export MIX_PATH="${beam.packages.erlangR25.hex}/lib/erlang/lib/hex/ebin"
    export PATH=${erlangR25}/bin:$MIX_HOME/bin:$HEX_HOME/bin:$MIX_HOME/escripts:bin:$PATH

    export LD_LIBRARY_PATH=${pkgs.stdenv.cc.cc.lib}/lib:$LD_LIBRARY_PATH

    export LANG=C.UTF-8
    # keep your shell history in iex
    export ERL_AFLAGS="-kernel shell_history enabled"

    export MIX_ENV=dev
  '';
in

mkShell {
  buildInputs = inputs;
  shellHook = hooks;

  LOCALE_ARCHIVE = if pkgs.stdenv.isLinux then "${pkgs.glibcLocales}/lib/locale/locale-archive" else "";
}
