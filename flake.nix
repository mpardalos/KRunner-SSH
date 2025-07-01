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
          buildInputs = with pkgs; [
            bash
            wrapGAppsNoGuiHook 
          ];
          propagatedBuildInputs = with pkgs; [
            glib 
            gobject-introspection
            (python3.withPackages
              (pythonPackages: with pythonPackages; [ 
                  dbus-python 
                  pygobject3
              ]))
          ];
          src = ./.;
          installPhase = ''
            install -Dm755 ${./main.py} $out/bin/krunner-ssh
            XDG_DATA_HOME="$out/share" EXECUTABLE="$out/bin/krunner-ssh" bash ${./install.sh}
          '';
        });
    };
}
