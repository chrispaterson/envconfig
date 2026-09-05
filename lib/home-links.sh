#!/bin/bash
: "${project_dir:?}" "${home_dir:?}" "${backup_dir:?}"
# Shared ownership rules keep install and uninstall symmetric.
home_items=(.bashrc .ctags .gitconfig .gitignore .hammerspoon .p10k.zsh .profile
            .shrc .tmux.conf .vim .vimrc .zshrc bin AGENTS.md CLAUDE.md)

source_for() {
  if [[ $1 == CLAUDE.md ]]; then
    printf '%s/AGENTS.md\n' "$project_dir"
  else
    printf '%s/%s\n' "$project_dir" "$1"
  fi
}

owns_link() {
  [[ -L $1 ]] && { [[ $1 -ef $2 ]] || [[ $(readlink "$1") == "$2" ]]; }
}

backup_path() {
  local destination=$1 name=${1##*/}
  if [[ -L $backup_dir || ( -e $backup_dir && ! -d $backup_dir ) ]]; then
    printf 'Invalid backup directory: %s\n' "$backup_dir" >&2
    return 1
  fi
  mkdir -p "$backup_dir"
  if [[ -e $backup_dir/$name || -L $backup_dir/$name ]]; then
    printf 'Backup already exists; preserving both paths: %s\n' "$destination" >&2
    return 1
  fi
  mv "$destination" "$backup_dir/$name"
  printf 'Backed up %s to %s\n' "$destination" "$backup_dir/$name"
}

install_home_links() {
  local name source destination
  for name in "${home_items[@]}"; do
    source=$(source_for "$name")
    [[ -e $source || -L $source ]] || continue
    destination=$home_dir/$name
    owns_link "$destination" "$source" && continue
    # Local Git includes hold private routing; replacing this file loses that layer.
    if [[ $name == .gitconfig && ( -e $destination || -L $destination ) ]]; then
      printf 'Preserved local Git config: %s (include %s for public defaults)\n' "$destination" "$source"
      continue
    fi
    if [[ -e $destination || -L $destination ]]; then
      backup_path "$destination"
    fi
    ln -s "$source" "$destination"
  done
  # Only retire the obsolete alias when it belongs to this checkout.
  if owns_link "$home_dir/agents" "$project_dir/agents"; then
    unlink "$home_dir/agents"
  fi
}

uninstall_home_links() {
  local name source destination entry backup_root
  for name in "${home_items[@]}" agents; do
    source=$(source_for "$name")
    destination=$home_dir/$name
    if owns_link "$destination" "$source"; then
      unlink "$destination"
    fi
  done
  # Restore only known home entries, including dotfiles, without overwriting replacements.
  for backup_root in "$backup_dir" "$project_dir/.bak"; do
    [[ -d $backup_root && ! -L $backup_root ]] || continue
    for name in "${home_items[@]}" agents; do
      entry=$backup_root/$name
      destination=$home_dir/$name
      [[ -e $entry || -L $entry ]] || continue
      if [[ -e $destination || -L $destination ]]; then
        printf 'Preserved backup %s; destination is occupied\n' "$entry"
      else
        mv "$entry" "$destination"
      fi
    done
  done
}
