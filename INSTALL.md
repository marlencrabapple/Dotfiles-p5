# NAME

Dotfiles::p5 - A collection of tools in the same vein as configuration files,
convenience/provisioning override files, et all.

## SYNOPSIS
 - `epoch`: Find and process/transport files whiie avoiding possible race-
   conditions in an near-unique, ordered, and metadata containing convention.
   ```
   $ fd -u -t f -e mp4 -e flv -e avi -e mkv '.+' \
        -x cp -vaf "{}" "$(epoch)_{/}" \;
   ```

 - `md2html`: Convert markdown and supported dialects with optional templating
   and further converstion to PDF and POD built in, and other formats supported
   via Pandoc.
   ```
   ```
   The script is supported by a library `use`-able with APIs supporting out-of-
   the box usage in mostexisting imperative, functional, and OOP paradigms

 - 

## DESCRIPTION
...

## INSTALLATION
### GNU/Linux
 - Arch Linux (AUR)
   ```
   $ git clone https://aur.archlinux.org/dotfiles-p5.git
   $ cd dotfiles-p5
   $ makechrootpkg -Cunc - -SCcfLi
   $ pacman -U $PKGDEST/perl-dotfiles-p5*.pkg.tar.zst
   ```
 - ...

### macOS
  ```
  brew tap ...
  ...
  ```

### Windows (WSL2)
 - *Something to do with choco and pacman somehow...*
...

### CPAN
`cpanm Dotfiles::p5` or `cpm install -g Dotfiles::p5`

### Build From Repo
Install plenv, a perl version mananger similar to its many cross-language
contemporaries pyenv, nvm, rustup, etc.  

```
$ plenv install <version>
$ plenv {shell|global|local} <version>
$ plenv install-cpanm
```

Install the bundled dependencies in ./vendor with Carton, Carmel, or App::cpm

`$ carton install --cache`, or `carmel install \
     && cpanm -Llocal --from ./vendor/cache

Or in the case only cpam is available, you can make due with it alone.

`$ cpanm -L local --from "$PWD/vendor/cache" --installdeps .`

