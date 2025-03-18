{pkgs, ...}: {
  extraPlugins = [
    (pkgs.vimUtils.buildVimPlugin {
      name = "project-todo.nvim";
      src = ../.;
    })
  ];
  extraConfigLua = ''
    require('project-todo').setup()
  '';
}
