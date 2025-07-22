# Pulled from EmergentMind's config
{lib, ...}: {
  # use path relative to the root of the project
  relativeToRoot = lib.path.append ../.;
}
