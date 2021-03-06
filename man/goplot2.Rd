% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/Plots.R
\name{goplot2}
\alias{goplot2}
\title{Hierarchy chart of GO}
\usage{
goplot2(
  SeuratObj,
  cluster = NULL,
  pathwayIDs = NULL,
  ont = "BP",
  showCategory = 10,
  color = "p.adjust",
  layout = "sugiyama",
  geom = "text",
  label_size = 3
)
}
\arguments{
\item{SeuratObj}{Object of class "Seurat"}

\item{cluster}{GSEA result of which cluster to show}

\item{pathwayIDs}{IDs of pathways to show}

\item{ont}{gene ontology, "BP","CC","MF"}

\item{showCategory}{number of top pathways of each cluster}

\item{color}{which column to color the nodes, "p.adjust" by default}

\item{layout}{network layout}

\item{geom}{"text", "label"}

\item{label_size}{size of label}
}
\value{

}
\description{
Hierarchy chart of GO
}
\examples{
\dontrun{
goplot2(SeuratObj)
goplot2(SeuratObj, ont = "MF")
}


}
