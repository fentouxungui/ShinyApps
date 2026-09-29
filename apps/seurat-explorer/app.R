library(SeuratExplorer)
options(shiny.launch.browser = FALSE, shiny.deprecation.messages = FALSE)
launchSeuratExplorer(verbose = FALSE,
  ReductionKeyWords = c("umap","tsne","pca"),
  SplitOptionMaxLevel = 12, MaxInputFileSize = 30 * 1024^3)

