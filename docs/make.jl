using Documenter
using TGW2D

makedocs(
    format = Documenter.HTML(
		prettyurls = get(ENV, "CI", nothing) == "true"
	),
    sitename="TGW2D.jl",
    pages=[
        "Informazioni generali" => "index.md",
    ],
    modules=[TGW2D]
)

deploydocs(
    repo="github.com/FTocci/TgwTwoDimensions.jl"
)
