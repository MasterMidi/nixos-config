{ ... }:
{
  flake.homeModules.jujutsu =
    { ... }:
    {
      programs.jujutsu = {
        enable = true;
        settings = {
          user = { name = "Michael Andreas Graversen"; email = "home@michael-graversen.dk";};
          template-aliases."format_short_id(id)" = "id.shortest()";
        };
      };

      programs.jjui = {
        enable = true;
        settings = {
          preview.show_at_start = true;
        };
      };
    };
}
