# LaTeX toolchain for academic publishing, scientific diagrams (TikZ/PGF),
# and presentations (Beamer).
#
# Tailored through texlive.withPackages to deliver comprehensive capabilities
# without the multi-gigabyte footprint of texliveFull:
#   - Engines: pdflatex, xelatex, lualatex (via scheme-medium)
#   - Build automation: latexmk
#   - Bibliographies: biber, biblatex
#   - Academic classes: revtex4, ieeetran, acmart
#   - Math & algorithms: mathtools, algorithm2e, algorithmicx, algorithms, siunitx
#   - Schemes & diagrams: pgf/tikz, pgfplots, circuitikz, tikz-cd, standalone, tcolorbox
#   - Presentations: beamer
#   - Cyrillic / Russian support: babel-russian, hyphen-russian, lh, cyrillic
#   - Styling & layout: booktabs, caption, cleveref, microtype, titlesec, enumitem, geometry
#   - Companion CLI tools: poppler-utils (pdftoppm, pdfinfo), ghostscript
{ pkgs, ... }:
let
  texlivePackage = pkgs.texlive.withPackages (ps: [
    # Core TeX Live distribution and standard engines (pdflatex, xelatex, lualatex)
    ps.scheme-medium

    # Build automation & bibliography
    ps.latexmk
    ps.biber
    ps.biblatex
    ps.csquotes

    # Russian / Cyrillic language & hyphenation
    ps.babel-russian
    ps.hyphen-russian
    ps.lh
    ps.cyrillic

    # Scientific journal document classes & styles
    ps.revtex4
    ps.ieeetran
    ps.acmart
    ps.siunitx
    ps.mathtools
    ps.algorithm2e
    ps.algorithmicx
    ps.algorithms
    ps.cleveref
    ps.microtype

    # Tables & document layout
    ps.booktabs
    ps.multirow
    ps.makecell
    ps.caption
    ps.titlesec
    ps.enumitem
    ps.geometry
    ps.fancyhdr
    ps.listings
    ps.wrapfig
    ps.environ

    # Diagrams & schemes (TikZ / PGF / Circuitikz)
    ps.pgfplots
    ps.circuitikz
    ps.tikz-cd
    ps.standalone
    ps.tcolorbox

    # Presentations
    ps.beamer
  ]);
in
{
  home.packages = [
    texlivePackage
    pkgs.poppler-utils
    pkgs.ghostscript
  ];
}
