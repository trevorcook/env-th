self: super:
with builtins; with self.lib;
let
  callPackage = self.callPackage;
  envs-dir =
      let
        envsdir = filterAttrs (n: v: n != "README.md") (readDir ./envs);
        mkEnv = n: _: callPackage (./envs + "/${n}") {};
      in
        mapAttrs mkEnv envsdir;

  mkenv-th =  makeOverridable ({envs ? envs-dir }:
    # callPackage will use the original `env-th`. To pick up the overridden
    # definition, an updated `env-th` must be supplied--hence the following.
    let env-th = env-th0.override {inherit envs;}; in
    rec {
    # This is all the utilities going into making it work.
    lib = rec {
      env0 = callPackage ./env-0.nix {};
      init-attrs = callPackage ./init-attrs.nix {};
      init-env = callPackage ./init-env.nix { inherit env0 env-th; };
      add-envs = callPackage ./add-envs.nix { inherit env-th; };
      imports = callPackage ./imports.nix { inherit env-th;};
      builder = callPackage ./build.nix {};
      resources = callPackage ./resources.nix {};
      shellLib = callPackage ./shellLib.nix {};
      make-environment = callPackage ./make-environment.nix { inherit env-th; };
      };

    # These are the exported utilities that people will use.
    inherit envs;
    addEnvs = lib.add-envs.addEnvs;
    mkSrc = lib.resources.mkSrc;
    mkEnvironment = lib.make-environment.mkEnvironment;
  });
  env-th0 = mkenv-th {};
  in env-th0
