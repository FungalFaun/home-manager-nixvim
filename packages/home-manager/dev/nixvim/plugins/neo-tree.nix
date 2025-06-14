{self, ...}: {
  programs.nixvim = {
    keymaps = [
      {
        mode = "n";
        key = "<leader>n";
        action = ":Neotree action=focus reveal<CR>";
        options.silent = true;
      }
    ];

    plugins = {
      neo-tree = {
        enable = true;
        closeIfLastWindow = true;
      };
    };
  };
}
