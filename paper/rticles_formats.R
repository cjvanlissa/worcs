
  write.table(getNamespaceExports("rticles"), "clipboard", sep = "\r\n", quote = F, row.names = F, col.names= F)


rticles_formats <- eval(parse(text = 'structure(list(Function = c("ams_article", "asa_article", "biometrics_article",
"copernicus_article", "ctex", "elsevier_article", "frontiers_article",
"ieee_article", "joss_article", "jss_article", "mdpi_article",
"mnras_article", "oup_article", "peerj_article", "plos_article",
"pnas_article", "rjournal_article", "rsos_article", "sage_article",
"sim_article", "springer_article", "tf_article"), Description = c("AMS articles",
"The American Statistican (TAS)", "Biometrics articles", "Copernicus Publications journal submissions",
"CTeX documents", "Elsevier journal submissions", "Frontiers articles",
"IEEE Transaction journal submissions", "JOSS and JOSE articles",
"JSS articles", "MDPI journal submissions", "Monthly Notices of the Royal Astronomical Society articles",
"OUP articles", "PeerJ articles", "PLOS journals", "PNAS journals",
"The R Journal articles", "Royal Society Open Science journal submissions",
"Sage journal submissions", "Statistics in Medicine journal submissions",
"Springer journal submissions", "Taylor & Francis articles")), class = "data.frame", row.names = c(NA,
-22L))'))

