{
  inputs,
  ...
}:let
  system = "x86_64-linux";
in {
  home.packages = [
    inputs.astal.packages.${system}.default
  ];
}
