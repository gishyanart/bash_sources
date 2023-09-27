# bash_sources

Helper Bash scripts and functions.

## Prerequisites

- [mikefarah/yq](https://github.com/mikefarah/yq)

## Installation

Via Git clone

```bash
git clone https://github.com/gishyanart/bash_sources.git ~/.bash_sources --depth=1
```

Add to the `~/.bashrc`:

```bash
if [ -d "$HOME/.bash_sources/" ]
then
  for _source in "$HOME"/.bash_sources/*.sh
  do
    source "${_source}"
  done
fi
```
