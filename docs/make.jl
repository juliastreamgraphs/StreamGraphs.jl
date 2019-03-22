using Documenter
using StreamGraphs

makedocs(
         modules  = [StreamGraphs],
         format   = :html,
         sitename = "StreamGraphs",
         doctest  = false,
         pages    = Any[
                        "Getting Started" => "index.md",
                        "LinkStreams vs. StreamGraphs" => "streamtypes.md"
                        ]
         )

deploydocs(
           deps   = nothing,
           make   = nothing,
           repo   = "github.com/NicolasGensollen/StreamGraphs.jl.git",
           target = "build",
           julia  = "1.0",
           osname = "linux"
           )
