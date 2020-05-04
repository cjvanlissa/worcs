# write_worcsfile(filename = ".worcs",
#                 worcs_version = "0.1.1",
#                 creator = Sys.info()["effective_user"],
#                 checksums = list(ckone = "1334", cktwo = "5y54")
# )
write_worcsfile <- function(filename, ..., level = 1){
  Args <- list(...)
  #if(any(names(Args) == "")) stop("Must provide a name for each argument when calling 'write_worcsfile()'.", call. = FALSE)
  if(!file.exists(filename)){
    file.create(filename)
  }
  for(this_arg in names(Args)){
    value <- Args[[this_arg]]
    if(length(value) > 1 | is.list(value)){
      write(paste0(rep("  ", (level-1)), paste0(this_arg, ": ")), filename, append = TRUE)
      cl <- c(list(filename = filename),
              as.list(value),
              list(level = level+1))
      do.call(write_worcsfile, cl)
    } else {
      write(paste0(rep("  ", (level-1)), paste(this_arg, value, sep = ": ")), filename, append = TRUE)
    }
  }
}

read_worcsfile <- function(filename){
  inp <- readLines(filename)
  append_list(inp)
}

append_list <- function(inp){
  val_key <- strsplit(inp, split = ": ")
  noindent <- !grepl("^  ", inp)
  simplevalue <- sapply(val_key, length) == 2
  if(all(noindent & simplevalue)){
    out <- lapply(val_key, `[`, 2)
    names(out) <- sapply(val_key, `[`, 1)
  } else {
    out <- vector(mode = "list", length = sum(noindent))
    names(out) <- gsub(":\\s{0,}$", "", sapply(val_key[noindent], `[`, 1))
    out[which(noindent & simplevalue)] <- lapply(val_key[noindent & simplevalue], `[`, 2)
    # Where groups start
    grp_start <- which(noindent & !simplevalue)
    grp_end <- sapply(grp_start, function(x){which(c(noindent[(x+1):length(noindent)], TRUE))[1]+(x-1)})
    new_list <- mapply(function(first, last){
      gsub("^  ", "", inp[first:last])
    }, first = grp_start+1, last = grp_end, SIMPLIFY = FALSE)
    out[which(sapply(out, is.null))] <- lapply(new_list, append_list)
  }
  return(out)
}
