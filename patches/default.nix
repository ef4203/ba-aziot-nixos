# Automatically import patches from this directory.
dirname: inputs@{ self, nixpkgs, ... }:
self.lib.__internal__.fun.importPatches inputs dirname { }
