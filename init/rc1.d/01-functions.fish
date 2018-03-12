function find_matching_notes -a pattern -d " find files containing string and return sorting by number of matches desc"
    ag -lc --markdown "$pattern" $FD_NOTES_HOME | sort -t: -nrk2 | cut -d':' -f1
end

function notes_find -a pattern
  set -l results (find_matching_notes $pattern)
# if there is only one result then just open it
  if test (count $results) -ge 0
    edit_note (head -1 $results)
  end
end

function edit_best_note -a file_path -d "open the file in vim"
  vim $file_path
end
