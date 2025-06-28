{
  description =
    "A KRunner backend for connecting to SSH hosts listed in your known_hosts file";

  inputs.nixpkgs.url = "nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      pkgsFor = system: import nixpkgs { inherit system; };
      systems = [ "aarch64-linux" "x86_64-linux" ];
      forAllSystems = f:
        nixpkgs.lib.genAttrs systems (system: f (pkgsFor system));
    in {
      defaultPackage = forAllSystems (pkgs:
        pkgs.stdenv.mkDerivation {
          name = "krunner-ssh";
          propagatedBuildInputs = [
            (pkgs.python3.withPackages
              (pythonPackages: with pythonPackages; [ dbus-python ]))
          ];
          buildInputs = [ pkgs.bash ];
          src = ./.;
          installPhase = ''
            install -Dm755 ${./main.py} $out/main.py
            XDG_DATA_HOME="$out/share" BASE_DIR="$out" bash ${./install.sh}
          '';
        });
    };
}
