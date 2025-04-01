# martinbo66's dotfiles

This project contains the dotfiles and custom shell scripts that I use on my Mac.

Why keep them at GitHub? It's a way to share advanced shell tips with other developers, and more practically, a way to back up my configuration. When I get a new Mac or (knock on wood) need to recover from lost data or a corrupt OS, I can simply clone this repository and immediately be back in business.

I (Bo) forked [Matt Brictson's](https://github.com/mattbrictson/dotfiles) dotfiles, which contains this attribution.

Thank you [Ryan Bates](https://github.com/ryanb/dotfiles), [thoughtbot](http://github.com/thoughtbot/dotfiles) and [Tom Ryder](https://github.com/tejr/dotfiles) for the inspiration.

## Project Structure

::: mermaid
graph TD
    A[dotfiles] --> B[bin/]
    A --> C[zshrc.d/]
    A --> D[bashrc.d/]
    A --> E[Configuration Files]
    
    B --> B1[brew-install]
    B --> B2[bucket]
    B --> B3[defaults-install]
    B --> B4[git-pluck]
    B --> B5[git-reap]
    B --> B6[sup]
    B --> B7[docker-rmi]
    B --> B8[lirio-crypto-cli]
    
    C --> C1[aliases.zsh]
    C --> C2[completions.zsh]
    C --> C3[env.zsh]
    C --> C4[history.zsh]
    C --> C5[java.zsh]
    C --> C6[kafka.zsh]
    C --> C7[k8s.zsh]
    C --> C8[man.zsh]
    C --> C9[nvm.zsh]
    C --> C10[python.zsh]
    
    E --> E1[.bash_profile]
    E --> E2[.bashrc]
    E --> E3[.gitconfig.erb]
    E --> E4[.inputrc]
    E --> E5[.jscsrc]
    E --> E6[.liquidpromptrc]
    E --> E7[.p10k.zsh]
    E --> E8[.psqlrc]
    E --> E9[.zshrc]
    E --> E10[Brewfile]
    E --> E11[Rakefile]
:::

## Requirements

Before using these dotfiles there are a few things you'll need to install manually:

1. Your Mac needs git and Apple's command-line developer tools.
2. Homebrew.

## What's included?

### Handy scripts

These scripts will be installed to `~/.bin` and added to your `$PATH`:

* `brew-install` installs and updates my standard suite of homebrew recipes. Run it on a new machine after installing homebrew to get all the recipes needed for Rails development, node, PostgreSQL, etc.
* `bucket` is a simple command-line interface for Bitbucket, most notably providing a way to create pull requests. Run `bucket --help` for details.
* `defaults-install` uses `defaults write` on OS X to change system default behavior to my liking: e.g. don't include drop-shadows on screenshots.
* `git-pluck` adds the `pluck` command to git, which is a trick for cherry-picking a commit from another repository into the current one: `git pluck ../other-repo SHA`.
* `git-reap` adds the `reap` command to git, which deletes local and remote branches that have already been merged with the master branch and thus are no longer needed.
* `sup` uses SSH to update packages on one or more Ubuntu servers (assuming you have root access to them). In other words, `sup SERVER1 SERVER2` will SSH as root into both servers and run the appropriate `aptitude` commands to safely update all packages. It will also report whether any daemons need to be restarted for the updates to take effect.

### Shell enhancements (bash)

* Customizes the shell prompt with current directory and git status.
* Replaces `diff` with `colordiff`.
* Prettifies `ls` output and adds `l`, `la`, and `ll` shortcuts.
* Improves default `top` settings.
* Allows bash command history to be navigated with up and down arrow keys.
* Makes bash auto-completion case-insensitive.
* Sets up necessary homebrew, rbenv, and python virtualenv shell variables.
* Specifies `less` as the default pager.
* Sets better defaults for the `psql` command.

### Git configuration

* Sets up a reasonable global gitignore file to ignore things like `.DS_Store`, `Icon?`, and `*sublime-project`.
* Enables color output and line-ending checks.
* Shortens common commands: `di`, `co`, `ci`, `br`, `l`.
* Defines somes useful aliases:
    * `git hist`
    * `git ignored-files`
    * `git untracked-files`
    * `git unstage`

In addition, during installation (see below), you will be prompted for your full name and email address, which are automatically added to the git config file.

## Installation

Choose a place to store the dotfiles, like `~/Code/dotfiles`.

```
git clone git://github.com/martinbo66/dotfiles ~/Code/dotfiles
cd ~/Code/dotfiles
```

Run one of the three installation options:

```
rake install:dotfiles # Install the dotfiles and scripts
rake install:packages # Install homebrew packages and Mac defaults
rake install          # Install all of the above (recommended)
```

### Changing your bash version

Some features of the dotfiles only work with bash version 4.2. After installing bash via homebrew (which `rake install:packages` does for you), enable it as your shell as follows:

1. Add `/usr/local/bin/bash` to `/etc/shells`
2. Change your shell to `/usr/local/bin/bash` by running `chsh`
