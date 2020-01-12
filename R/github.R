#' @title Connect a project with a git repository to GitHub
#' @description This function adds the https address of a GitHub repository
#' as a remote to a local project, and pushes to local project to that remote
#' repository.
#' @param https https address of a GitHub repository, provided by GitHub when
#' creating a new Repository.
#' @rdname connect_github
#' @export
connect_github <- function(https){
  cmnd <- paste0("git remote add origin ", https)
  system(cmnd, ignore.stdout = TRUE)
  system('git add .')
  system('git commit -m "Initial commit of WORCS project"')
  system("git push -u origin master", ignore.stdout = TRUE)
}


has_git <- function(){
  system("git", ignore.stdout = TRUE) == 1
}


#use_github(private = TRUE, protocol = "https", credentials = git2r::cred_env())
