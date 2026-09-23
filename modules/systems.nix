# The platforms this flake evaluates for. Checks and VM tests are built for
# every system listed here, so keep this to systems you can actually build
# for (add aarch64-linux once a builder for it exists).
{ lib, ... }:
{
  systems = [ "x86_64-linux" ];
}
