# write_worcsfile(filename = ".worcs",
#                 worcs_version = "0.1.1",
#                 creator = Sys.info()["effective_user"],
#                 checksums = list(ckone = "1334", cktwo = "5y54")
# )
write_worcsfile <- function(filename, ..., level = 1, modify = FALSE){
  new_contents <- list(...)
  if(modify & file.exists(filename)){
      old_contents <- read_worcsfile(filename)
      new_contents <- mod_nested_list(old_contents, new_contents)
    }
  file_lines <- add_indentations(new_contents)
  write(file_lines, filename, append = FALSE)
}


add_indentations <- function(x, level = 0){
  is_char <- sapply(x, is.character)
  out <- vector(mode = "list", length = length(x))
  out[is_char] <- paste0(rep("  ", level), names(x)[is_char], ": ", x[is_char])
  out[!is_char] <- lapply(names(x[!is_char]), function(element_name){
    the_element <- x[!is_char][[element_name]]
    c(paste0(rep("  ", level), element_name, ": "),
    do.call(add_indentations, list(
      the_element,
      level = level+1
      )))})
  unlist(out)
}

read_worcsfile <- function(filename){
  inp <- readLines(filename)
  modify_list(inp)
}

modify_list <- function(inp) {
  val_key <- strsplit(inp, split = "\\s{0,}:\\s{0,}")
  noindent <- !startsWith(inp, "  ")
  this_level <- val_key[noindent]
  out <- vector(mode = "list", length = length(this_level))
  names(out) <- sapply(this_level, `[`, 1)
  value_key_pair <- sapply(this_level, length) == 2
  out[value_key_pair] <- sapply(this_level[value_key_pair], `[`, 2)

  # Define groups of spaced lines
  n <- which(startsWith(inp, "  "))
  if(length(n) > 0){
    grps <- list()

    for (i in 1:length(n)) {
      #i = 2
      if (i == 1) {
        grps[[1]] <- c(n[i])
      } else {
        if (n[i] - n[i - 1] > 1) {
          grps[[length(grps)]] <- c(grps[[length(grps)]], n[i - 1])
          grps[[length(grps) + 1]] <- c(n[i])
        }
      }
    }
    grps[[length(grps)]] <- c(grps[[length(grps)]], tail(n, 1))

    new_list <- lapply(grps, function(this_grp) {
      substring(inp[this_grp[1]:this_grp[2]], first = 3)
    })
    out[!value_key_pair] <- lapply(new_list, modify_list)
  }
  return(out)
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
