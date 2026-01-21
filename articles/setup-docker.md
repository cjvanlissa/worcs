# Setting up your computer for WORCS - Docker-edition

If you do not want to install R, RStudio, Latex and Git on a personal
computer (as described in
[`vignette("setup", package = "worcs")`](https://cjvanlissa.github.io/worcs/articles/setup.html)),
but would like to use Docker instead, follow these steps in order:

1.  Install [Docker](https://docs.docker.com/get-docker/)
2.  Open a terminal/cmd/shell.
3.  Start the `worcs` image:

``` bash
docker run -e PASSWORD=secret -p 8787:8787 -it cjvanlissa/worcs:latest
```

3.  Open the address `127.0.0.1:8787/` in a browser. Login using
    username=rstudio and password=secret.

Then setup the container.

``` r
renv::consent(provided = TRUE)
worcs::git_user("your_name", "your_email")
```

To terminate the container, press Ctrl + C in the terminal. To save
files from a Docker session on your disk, you have to link a directory
explicitly when starting the container.

On Unix file systems, this is done as follows:

``` bash
-v /path/on/your/pc:/home/rstudio
```

And on Windows file systems, as follows:

``` bash
-v //c/path/on/your/windows/pc:/home/rstudio
```

Then start the Docker session using this command:

``` bash
docker run -e PASSWORD=secret -p 8787:8787 -v /path/on/your/pc:/home/rstudio -it cjvanlissa/worcs:latest
```

That’s it!
