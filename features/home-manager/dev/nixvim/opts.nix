{
  programs.nixvim = {
    clipboard = {
      providers.wl-copy.enable = true; 
      register = "unnamedplus";
    };

    opts = {
      number = true;
      relativenumber = true;
      cursorline = true;

      clipboard = "unnamedplus";

      shiftwidth = 2;
      tabstop = 2;
      softtabstop = 2;

      autoindent = true;
      expandtab = true;
      smartindent = true;
      breakindent = true;

      scrolloff = 10;

      showtabline = 2;
      mouse = "a";

      foldmethod = "manual";
      foldenable = false;

      linebreak = true;

      spell = false;

      swapfile = false;
      termguicolors = true;

      splitbelow = true;
      splitright = true;
      
      signcolumn = "yes";
    };
  };
}
