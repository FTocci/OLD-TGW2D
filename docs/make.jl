using Documenter
using TGW2D

makedocs(
    sitename = "TGW2D",
    format = Documenter.HTML(),
    modules = [TGW2D]
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
#=deploydocs(
    repo = "<repository url>"
)=#
