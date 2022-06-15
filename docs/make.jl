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

Themes.compile("docs/src/documenter-dark.scss", "docs/build/assets/themes/documenter-dark.css")
Themes.compile("docs/src/documenter-light.scss", "docs/build/assets/themes/documenter-light.css")
