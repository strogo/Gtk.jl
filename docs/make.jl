using Documenter, Gtk

makedocs(
    format = :html,
    modules = [Gtk],
    sitename = "Gtk.jl",
    authors = "...",
    pages = [
        "Home" => "index.md",
        "Manual" => ["manual/gettingStarted.md",
                     "manual/properties.md",
                     "manual/layout.md",
                     "manual/signals.md",
                     "manual/builder.md",
                     "manual/filedialogs.md",
                     "manual/customWidgets.md",
                     "manual/nonreplusage.md"
                    ],
    ],
)

deploydocs(repo   = "github.com/JuliaGraphics/Gtk.jl.git",
           julia  = "0.5",
           target = "build",
           deps   = nothing,
           make   = nothing)

