abbr --add fdn note home

function search_notes_fuzzy -d "ripgrep and fzf"
  set -l file (rg --files $FD_NOTES_HOME/**/*.md | fzf)
  eval "$EDITOR $file"
end

abbr -a fen search_notes_fuzzy
