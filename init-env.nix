{env-th, env0}:
with env-th.lib.shellLib;
rec {
  init-env = self:
    super@{ shellHook ? "", lib ? null, ... }:
    {  shellHook = ''
         [[ $ENVTH_ENTRY == bin ]] && ENVTH_BUILDDIR=.
         source ${mkEnvLib env0}/lib/env-0
         ${if self ? importLibsHook then self.importLibsHook else ""}
         env-PATH-nub
         ENVTH_PATHS_IN_STORE=$(env-PATH-stores)
         ''
         + env0.shellHook
         + shellHook ;
       userShellHook = shellHook;

    };
}
