{
  pkgs,
  ...
}: {
  programs.gh = {
    enable = true;
    extensions = [ pkgs.gh-markdown-preview ];
    settings = {
      version = "1";
      git_protocol = "ssh";
      prompt = "enabled";
    };
  };
}
