
# find notes
# edit note
# create new note
# create note within project
# delete note
# rename note

function note_create -a title -d "create a new text note"
  set escaped_file_name (_escape_string $title)
  set d (date --iso-8601)
  set p "$FD_NOTES_HOME/$d-$escaped_file_name.md"
  note_edit $p
  echo wrote "$p" to notes
end

function note_create_project_note  -a title -d "create a new text note within a project area"
  set escaped_file_name (_escape_string $title)
  set d (date --iso-8601)
  set p "$FD_NOTES_HOME/$CURRENT_PROJECT_SN/$d-$escaped_file_name.md"
  note_edit $p
  echo wrote "$p" to notes
end

function _note_search -a pattern -d "find note by full text search"
    ag -lc --markdown "$pattern" $FD_NOTES_HOME | sort -t: -nrk2 | cut -d':' -f1
end

function note_move -d "change the name of a note"
  
end

function note_edit -a file_path -d "open the file in vim"
  if test $file_path = '-'
    read -l x
    echo "editing $x"
    vim $x
  else
    vim $file_path
  end
end

function _escape_string -a title -d "remove non-path characters"
  set r $title
  set replacements_performed 1 # set to 1 initially to get into the loops
  while test $replacements_performed > 0
    set replacements_performed 0
    for c in " " ":" "/" "\\" "\t" "\n" ";" "." "," "__"
      set r (string replace $c '_' $r)
      if test $status -eq 0
        set replacements_performed (math $replacements_performed + 1)
      end
    end
    # if no replacements were possible then stop
    if test $replacements_performed -eq 0
      break
    end
  end  
  echo $r
end

function note_find -a search_pattern -d "file name search for <pattern>, opens selection in default editor"
  set matches (_note_find "$search_pattern")
  if test 1 -eq (count $matches)
    note_edit $matches[1]
    return
  end
  set -g dcmd "dialog --stdout --no-tags --menu 'select the file to edit' 20 60 20 " 
  set c 1
  for option in $matches
    set l (get_file_relative_path $option)
    set -g dcmd "$dcmd $c '$l'"
    set c (math $c + 1)
  end
  set choice (eval "$dcmd")
  clear
  if test $status -eq 0
    note_edit $matches[$choice]
  end
end

function note_search -a search_pattern -d "full text search for <pattern>, opens selection in default editor"
  set matches (_note_search "$search_pattern")
  if test 1 -eq (count $matches)
    note_edit $matches[1]
    return
  end
  set -g dcmd "dialog --stdout --no-tags --menu 'select the file to edit' 20 60 20 " 
  set c 1
  for option in $matches
    set l (get_file_relative_path $option)
    set -g dcmd "$dcmd $c '$l'"
    set c (math $c + 1)
  end
  set choice (eval "$dcmd")
  clear
  if test $status -eq 0
    note_edit $matches[$choice]
  end
end

function get_file_relative_path -a path_to_note -d "description"
  set filename (string replace $FD_NOTES_HOME "" $path_to_note)
  echo $filename
end

function _note_find -a pattern -d "find note by note name"
    find $FD_NOTES_HOME/ -iname "*$pattern*"
end

