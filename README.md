# Make your contributor graph say Abolish ICE

![Contributor Graph](graph.png)

## Usage

0. have the `git` command installed, and (optionally) `wget` or `curl`
1. get this repo, `git clone git@github.com:rossabaker/abolish-ice-graphiti.git`
2. update `dates.txt` for current week, via `./dates.sh < dow.txt > dates.txt` or `./raster.sh` (use `./raster -h` to see all the options)
2. On Github, create a new target repo to be graffitied.  I like `abolish-ice`
3. get a local copy of the target repository with `git clone`
4. make a new branch, perhaps `git checkout -b drop-ice`
6. run `username=<user> ./<path_to_repo>/abolish-ice-graphiti/paint.sh` in the target repo, with your git user name so we get the commit count right,
   - or  `./<path_to_repo>/abolish-ice-graphiti/paint.sh` if you don't have have `curl`/`wget`
   - or `commitmax=<most_commits_in_one_day> ./<path_to_repo>/abolish-ice-graphiti/paint.sh` if you don't have `curl`/`wget` and your colors are wrong cuz you have a pre-existing day with more than 50 commits (see Troubleshooting below)
7. [optionally] switch default branch back and forth if things look wrong (see Troubleshooting below)

### refreshing
8. Visit the GitHub settings page for yor target repo (`abolish-ice`) and under the branches tab, switch the default github branch back to the one without graffiti commits
10. reset graffiti branch from placeholder branch, `git reset main`
11. update `dates.txt` for current week (2. reprised)
12. run `paint.sh`, with the users name (6. reprised)
13. `paint.sh`'s git push will fail, so do a git push -f [maybe the git push doesn't really belong in paint.sh but in a parent script?]
14. switch the default github branch back to the one with graffiti commits

## Troubleshooting

### It didn't show up

See the [guide on which contributions count](https://help.github.com/en/github/setting-up-and-managing-your-github-profile/why-are-my-contributions-not-showing-up-on-my-profile).
Specifically, make sure:

* The repository you run paint.sh in is not a fork.
* You run it on the default branch of your repository.

### It's hard to read

The script needs to generate many more commits than your busiest days to make a loud and clear statement.  You can use the environmental variable `username` to tell `paint.sh` your github user (`username=myname ./paint.sh`) and it can check your profile, provided you have `curl` or `wget` installed. Otherwise, The `maxcommit` variable directly determines the number of commits.  If your graph does not turn a crisp, dark green "ABOLISH ICE,"" try `maxcommit=100 ./paint.sh` or higher.

### Fading

If the right side of the graph is dark green but the rest is faded, then you can try switching the default branch of your `abolish-ice` repository back to `main` (or some non-graffitied branch), and then switching back to the branch with your graffiti commits. This issue is being tracked under #10.

## Credit

Bootstrapped from [github-graffiti](https://github.com/mavrk/github-graffiti).
