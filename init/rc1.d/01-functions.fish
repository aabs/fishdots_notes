
# find notes
# edit note
# create new note
# create note within project
# delete note
# rename note

function note_create -a title -d "create a new text note"
  set -l escaped_file_name (_escape_file_name $title)
  set -l p $FD_NOTES_HOME/(date --iso-8601)
end

function note_create_project_note -d "create a new text note within a project area"
  
end

function note_find -a pattern -d "find note by note name"
    find $FD_NOTES_HOME/ -iname "*$pattern*"
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

function _escape_file_name -a title -d "remove non-path characters"
  echo (string replace ' ' '_')  
end

function note_search -a search_pattern
  set matches (_note_search "$search_pattern")
  set -g dcmd "dialog --stdout --menu 'select the file to edit' 20 60 20 " 
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

function pick_note
  set x (dialog "$FD_NOTES_HOME" 20 20)
  vim $x
end

function get_file_relative_path -a path_to_note -d "description"
  set filename (string replace $FD_NOTES_HOME "" $path_to_note)
  echo $filename
end