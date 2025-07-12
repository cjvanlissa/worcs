# quizz <- function(..., render_if = knitr::is_html_output(), title = "Quiz", show_box = TRUE, show_check = TRUE){
#   if(render_if){
#     if(requireNamespace("webexercises", quietly = TRUE)){
#       dots <- list(...)
#       # Check if a file is provided instead of multiple questions
#       if(length(dots) == 1){
#         if(file.exists(dots[[1]])){
#           txt <- readLines(dots[[1]])
#           questionz <- lapply(txt, function(q){
#             spl <- regexpr("=", q)
#             trimws(substring(q, c(1, spl+1), c(spl-1, nchar(q))))
#           })
#           dots <- lapply(questionz, function(q){
#             eval(parse(text = q[2]))
#           })
#           names(dots) <- trimws(sapply(questionz, `[`, 1))
#         }
#       }
#       # Now, prepare the HTML code
#       if(show_box | show_check){
#         classes <- paste0(' class = "',
#                           trimws(paste0(c(c("", "webex-check")[show_check+1L],
#                                           c("", "webex-box")[show_box+1L]), collapse = " ")), '"')
#       }
#       intro <- paste0('<div class="webex-check webex-box">\n<span>\n<p style="margin-top:1em; text-align:center">\n<b>', title, '</b></p>\n<p style="margin-left:1em;">\n')
#       outro <- '\n</p>\n</span>\n</div>'
#
#       questions <- sapply(dots, function(q){
#         switch(class(q)[1],
#                "character" = {
#                  opts <- q
#                  names(opts)[1] <- "answer"
#                  browser()
#                  webexercises::mcq(sample(opts))
#                },
#                "logical" = {
#                  webexercises::torf(q)
#                },
#                "numeric" = {
#
#                  if(length(q) == 1){
#                    webexercises::fitb(answer = q)
#                  } else {
#                    webexercises::fitb(answer = q[1], tol = q[2])
#                  }
#
#                },
#                "integer" = {
#                  webexercises::fitb(answer = q[1], tol = 0)
#                })})
#
#       txt <- paste0(
#         intro,
#         paste(paste(names(dots), questions), collapse = "\n\n"),
#         outro
#       )
#     } else {
#       txt = ""
#     }
#     cat(txt)
#   }
# }
