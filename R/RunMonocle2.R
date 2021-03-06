RunMonocle2 <- function(SeuratObj, 
                        max_components = 2, 
                        root_clusters = NULL, 
                        cell_size = 0.5, 
                        BEAM_branch_point = 1,
                        BEAM_num_clusters = 3,
                        save_plot = TRUE) {
  
  #### create CellDataSet object
  data <- GetAssayData(SeuratObj, slot = "data") 
  pd <- SeuratObj@meta.data
  pd$cds_cluster <- unname(Idents(SeuratObj)[rownames(pd)])
  fData <- data.frame(gene_short_name = rownames(data), geneID=rownames(data), row.names = rownames(data))
  mycds <- newCellDataSet(data,
                          phenoData = new('AnnotatedDataFrame', data = pd),
                          featureData = new('AnnotatedDataFrame', data = fData),
                          expressionFamily = negbinomial.size())
  #### run Monocle2 pipeline
  mycds <- estimateSizeFactors(mycds)
  mycds <- estimateDispersions(mycds, relative_expr = TRUE)
  # we use marker genes obtained from Seurat pipeline
  diff.genes <- slot(object = SeuratObj, name = 'misc')[["Allmarkers"]]
  sig_diff.genes <- subset(diff.genes, p_val_adj<0.01 & abs(avg_logFC)>0.5)$gene
  sig_diff.genes <- unique(as.character(sig_diff.genes))
  
  mycds <- setOrderingFilter(mycds, sig_diff.genes)
  mycds <- reduceDimension(mycds, max_components = max_components, method = 'DDRTree')
  mycds <- orderCells(mycds)
  # select root state
  if (!is.null(root_clusters)) {
    root_state <- function(mycds){
      if (length(unique(pData(mycds)$State)) > 1){
        R_counts <- table(pData(mycds)$State, pData(mycds)$cds_cluster)[,as.character(root_clusters)] %>% rowSums()
        # return(as.numeric(names(R_counts)[which(R_counts == max(R_counts))]))
        return(as.numeric(names(R_counts)[which.max(R_counts)]))
      } else {
        return(1)
      }
    }
    mycds <- orderCells(mycds, root_state = root_state(mycds)) 
  }
  
  p1 <- plot_cell_trajectory(mycds, color_by = "State", cell_size = cell_size)
  p2 <- plot_cell_trajectory(mycds, color_by = "cds_cluster", cell_size = cell_size)
  p3 <- plot_cell_trajectory(mycds, color_by = "Pseudotime", cell_size = cell_size)
  p4 <- plot_cell_trajectory(mycds, color_by = "State", cell_size = cell_size) + facet_wrap(~State, ncol = 2)
  p5 <- plot_cell_trajectory(mycds, color_by = "cds_cluster", cell_size = cell_size) + facet_wrap(~cds_cluster, ncol = 4)
  
  #### differential genes across pseudotime
  diff_test <- differentialGeneTest(mycds[sig_diff.genes,], cores = 1, 
                                    fullModelFormulaStr = "~sm.ns(Pseudotime)")
  sig_gene_names <- row.names(subset(diff_test, qval < 0.01))
  p6 <- plot_pseudotime_heatmap(mycds[sig_gene_names,], num_clusters=3, use_gene_short_name = TRUE, 
                               show_rownames=T, return_heatmap=T)
  
  #### BEAM analysis
  disp_table <- dispersionTable(mycds)
  disp.genes <- subset(disp_table, mean_expression >= 0.5 & dispersion_empirical >= 1*dispersion_fit)
  disp.genes <- as.character(disp.genes$gene_id)
  mycds_sub <- mycds[disp.genes,]
  beam_result <- BEAM(mycds_sub, branch_point = 1, cores = 1)
  beam_res <- beam_result[order(beam_result$qval),]
  beam_res <- beam_res[,c("gene_short_name", "pval", "qval")]
  mycds_sub_beam <- mycds_sub[row.names(subset(beam_res, qval < 1e-4)),]
  p7 <- plot_genes_branched_heatmap(mycds_sub_beam,  branch_point = BEAM_branch_point, num_clusters = BEAM_num_clusters, 
                                    show_rownames = T, use_gene_short_name = TRUE, return_heatmap = TRUE) +
    ggtitle(paste0("branch_point ", BEAM_branch_point))
  
  #### save plots
  if (save_plot) {
    if (!dir.exists(paths = "./scFunMap_output/plots/RunMonocle2")) {
      dir.create("./scFunMap_output/plots/RunMonocle2", recursive = TRUE)
    }
    pdf(file = "./scFunMap_output/plots/RunMonocle2/cell_trajectory.pdf", width = 15, height = 13)
    print(p1)
    print(p2)
    print(p3)
    dev.off()
    pdf(file = "./scFunMap_output/plots/RunMonocle2/cell_trajectory_facet.pdf", width = 10, height = 20)
    print(p4)
    print(p5)
    dev.off()
    ggsave("./scFunMap_output/plots/RunMonocle2/pseudotime_heatmap.pdf", plot = p6, width = 11, height = 17)
    ggsave("./scFunMap_output/plots/RunMonocle2/branched_heatmap.pdf", plot = p7, width = 11, height = 17)
  }
  
  return(list(CellDataSet=mycds, Gene_acrossPseudotime=diff_test, beam_result=beam_result, 
              pseudotime_heatmap=p6, branched_heatmap=p7))
}
















