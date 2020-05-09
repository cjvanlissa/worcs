worcs_badge <- function(filename = "README.md", worcs_directory = "."){
  if(!file.exists(filename)){
    col_message("Could not find README.md", success = FALSE)
    invisible(return(FALSE))
  } else {
    text <- readLines(filename)
    first_heading <- which(startsWith(text, "#"))[1]
    append(x = text,
           values = switch(worcs_level,
                  fail = c("", "[![WORCS](https://img.shields.io/badge/WORCS-fail-red)](https://osf.io/zcvbs/)", ""),
                  limited = c("", "[![WORCS](https://img.shields.io/badge/WORCS-limited-orange)](https://osf.io/zcvbs/)", ""),
                  open = c("", "[![WORCS](https://img.shields.io/badge/WORCS-open%20science-brightgreen)](https://osf.io/zcvbs/)", "")),
           after = first_heading
           )
  }
}

worcs_level <- function(path){
  if(!file.exists(file.path(path, ".worcs"))){
    col_message("No WORCS project found in directory '", path, "'", success = FALSE)
    invisible(return(FALSE))
  }
}
