{ denTest, ... }:
{
  flake.tests.bogus = {

  test-conditional-in-the-first-place = denTest (
      { den, igloo, ... }:
      {
        den.hosts.x86_64-linux.igloo.users.tux = { };

        den.aspects.igloo.includes = [
          den.aspects.conditional
          den.aspects.base
        ];

        den.aspects.base.includes = [
          den.aspects.git
        ];

        den.aspects.conditional = {
          includes = [
            (den.lib.policy.when ({ host, ... }: host.hasAspect den.aspects.git) {
              nixos.environment.variables.GIT_ENABLED = "true";
            })
          ];
        };
        den.aspects.git.nixos.programs.git.enable = true;

        expr = igloo.environment.variables ? GIT_ENABLED;
        expected = true;
      }
    );
  };
}
