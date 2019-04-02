push!(LOAD_PATH,"../src/")
using Documenter
using StreamGraphs

makedocs(
         modules  = [StreamGraphs],
         format   = :html,
         sitename = "StreamGraphs.jl",
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
           branch = "gh-pages",
           target = "build",
           osname = "linux"
           )
