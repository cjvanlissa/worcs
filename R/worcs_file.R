# write_worcsfile(filename = ".worcs",
#                 worcs_version = "0.1.1",
#                 creator = Sys.info()["effective_user"],
#                 checksums = list(ckone = "1334", cktwo = "5y54")
# )
#' @importFrom yaml write_yaml read_yaml
write_worcsfile <- function(filename, ..., modify = FALSE){
  new_contents <- list(...)
  if(modify & file.exists(filename)){
      old_contents <- read_yaml(filename)
      new_contents <- mod_nested_list(old_contents, new_contents)
    }
  write_yaml(new_contents, filename)
}

mod_nested_list <- function(old, new){
  for(i in 1:length(new)){
    if(depth(new[i]) == 1){
      if(names(new)[i] %in% names(old)){
        old[names(new)[i]] <- new[i]
      } else {
        old <- c(old, new[i])
      }
    } else {
      old[[names(new)[i]]] <- mod_nested_list(old[[names(new)[i]]], new[[i]])
    }
  }
  old
}

depth <- function(this,thisdepth=0){
  if(!is.list(this)){
    return(thisdepth)
  }else{
    return(max(unlist(lapply(this,depth,thisdepth=thisdepth+1))))
  }
}
