{ ... }:
{
  flake.homeModules.jujutsu =
    { ... }:
    {
      programs.jujutsu = {
        enable = true;
        settings = {
          user = {
            name = "Michael Andreas Graversen";
            email = "home@michael-graversen.dk";
          };
          template-aliases."format_short_id(id)" = "id.shortest()";
        };
      };

      programs.jjui = {
        enable = true;
        settings = {
          preview.show_at_start = true;
          ssh.hijack_askpass = true;
          actions = [
            {
              name = "parallelize-selected";
              desc = "parallelize selected changes";
              key = "alt+p";
              scope = "revisions";
              lua = ''
                local change_ids = revisions.checked()
                if #change_ids < 2 then
                  flash({ text = "Select at least two changes", error = true })
                  return
                end

                local args = { "parallelize" }
                for _, change_id in ipairs(change_ids) do
                  table.insert(args, change_id)
                end

                local _, err = jj(args)
                if err then
                  flash({ text = err, error = true, sticky = true })
                  return
                end

                flash("Parallelized " .. #change_ids .. " changes")
                revisions.refresh({ selected_revision = change_ids[1] })
              '';
            }
          ];
        };
      };
    };
}
