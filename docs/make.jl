using Documenter, SpineInterface, PyCall, Dates

makedocs(
    sitename="SpineInterface.jl",
    format=Documenter.HTML(prettyurls=get(ENV, "CI", nothing) == "true"),
    pages=["Home" => "index.md", "Library" => "library.md"],
)

deploydocs(repo="github.com/Spine-project/SpineInterface.jl.git", versions=["stable" => "v^", "v#.#"])
