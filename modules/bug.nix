{ denTest, ... }:
{
  flake.tests.bogus = {
    test-conditional-in-mutual-provider = denTest (
      { den, igloo, lib, ... }: let
        inherit (den.lib) policy;
      in
      {
        den.hosts.x86_64-linux.igloo.users = {
          tux = { };
          pingu = { };
        };

        den.aspects.features = {
          includes = with den.aspects.features; [
            starship
            jujutsu
          ];
          _.starship = {
            homeManager.programs.starship.enable = true;
          };

          _.jujutsu = {
            homeManager.programs.jujutsu.enable = true;

            includes = [
              (policy.when ({ user, ... }: user.hasAspect den.aspects.features.starship)
                (policy.include den.aspects.features.jujutsu.starship)
              )
            ];
            _.starship = {
              homeManager = { pkgs, ... }:
              {
                home.packages = [ pkgs.starship-jj ];
                programs.starship.settings.custom.jj = {
                  command = "prompt";
                  format = "$output";
                  ignore_timeout = true;
                  shell = ["starship-jj" "--ignore-working-copy" "starship"];
                  use_stdin = false;
                  when = true;
                };
              };
            };
          };
        };

        den.aspects.igloo = {
          includes = [ den.aspects.igloo.policies.to-users ];
          policies.to-users = { user, ... }: [
            (policy.include den.aspects.features)
          ] ++ lib.optional (user.userName == "tux")
            (policy.exclude den.aspects.features.starship);
        };

        expr.tux-starship-enabled = igloo.home-manager.users.tux.programs.starship.enable;
        expr.pingu-starship-enabled = igloo.home-manager.users.pingu.programs.starship.enable;
        expr.tux-starship-include-jj = igloo.home-manager.users.tux.programs.starship.settings ? custom.jj;
        expr.pingu-starship-include-jj = igloo.home-manager.users.pingu.programs.starship.settings ? custom.jj;

        expected.tux-starship-enabled = false;
        expected.pingu-starship-enabled = true;
        expected.tux-starship-include-jj = false;
        expected.pingu-starship-include-jj = true;
      }
    );
  };
}
