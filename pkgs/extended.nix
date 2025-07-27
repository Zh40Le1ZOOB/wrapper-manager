pkgs: pkgs.extend (final: _: import ./. { pkgs = final; })
