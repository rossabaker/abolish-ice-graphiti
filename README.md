# Make your contributor graph say Abolish ICE

![Contributor Graph](graph.png)

## Usage

1. Create a new repo.  I like `abolish-ice`
1. Run it.

```sh
./paint.sh
```

## Troubleshooting

### It didn't show up

See the [guide on which contributions count](https://help.github.com/en/github/setting-up-and-managing-your-github-profile/why-are-my-contributions-not-showing-up-on-my-profile).
Specifically, make sure:

* The repository you run paint.sh in is not a fork.
* You run it on the default branch of your repository.

### It's hard to read

The script needs to generate many more commits than your busiest days to make a loud and clear statement.  The `$I` variable determines the number of commits.  If your graph does not turn a crisp, dark green "ABOLISH ICE,"" try increasing `$I`.

## Credit

Bootstrapped from [github-graffiti](https://github.com/mavrk/github-graffiti).
