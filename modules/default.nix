# Automatically import modules from this directory.
dirname: inputs@{ self, nixpkgs, ... }:
self.lib.__internal__.fun.importModules inputs dirname { }
