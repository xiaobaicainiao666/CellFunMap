% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/Colors.R
\name{scPalette2}
\alias{scPalette2}
\title{Generate colors from a customed color palette}
\usage{
scPalette2(n)
}
\arguments{
\item{n}{number of colors to generate}
}
\value{

}
\description{
Generate colors from a customed color palette
}
\examples{
scPalette2(8)
barplot(rep(1,8), col = scPalette2(8))
pals::pal.bands(scPalette2(20))

}
