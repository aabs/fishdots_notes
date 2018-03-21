function note
  if test 0 -eq (count $argv)
    note_help
    return
  end
  switch $argv[1]
    case home
      cd $FD_NOTES_HOME
    case tasks
      note_tasks
    case edit
      note_edit $argv[2]
    case find
      note_find $argv[2]
    case search
      note_search $argv[2]
    case create
      note_create $argv[2]
    case pcreate
      note_create_project_note $argv[2]
    case save
      note_save
    case sync
      note_sync
    case move
      note_move $argv[2..3]
    case '*'
      note_help
  end
end

function _validate_args -a argc argv -d "description"
  if test $argc -eq (count $argv)
    true
  else
    false
  end
end

function _not_implemented_warning
  warn "This function has not yet been implemented"
end

function note_help -d "display usage info"
  echo "Fishdots Notes Usage"
  echo "===================="
  echo "note <command> [options] [args]"
  echo ""
  echo "note edit pattern"
  echo "  edit the note identified by the path"
  echo ""
  echo "note find pattern"
  echo "  find the note by searching file names"
  echo ""
  echo "note search pattern"
  echo "  perform a full text search for patterns"
  echo ""
  echo "note create title"
  echo "  create a new note"
  echo ""
  echo "note pcreate title"
  echo "  create a new note within a project area"
  echo ""
  echo "note save"
  echo "  save any new or modified notes locally"
  echo ""
  echo "note move"
  echo "  explain,,,"
  echo ""
  echo "note sync"
  echo "  synchronise notes with origin git repo"
  echo ""
  echo "note home"
  echo "  cd to the notes directory"
  echo ""
  echo "note help"
  echo "  EXPL"
end

function note_tasks -d "find all tasks"
  ag --markdown -Q -- '- [ ]' $FD_NOTES_HOME 
end

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

function note_move -a from_basename to_basename -d "change the name of a note"
  if test -f $FD_NOTES_HOME/$from_basename
    mv $FD_NOTES_HOME/$from_basename $FD_NOTES_HOME/$to_basename  
  else
    set -l matches (_note_find "$from_basename")
    if test 1 -eq (count $matches)
      set -l rpl_path (string replace $from_basename $to_basename $matches[1])
      mv $matches[1] $rpl_path
    else
      echo "too many matches for note"
    end
  end
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

function note_save -d "save all new or modified notes locally"
  _enter_notes_home
  git add -A .
  git commit -m "notes updates and additions"
  _leave_notes_home
end

function note_sync -d "save all notes to origin repo"
  note_save
  _enter_notes_home
  git fetch --all -t
  git push origin (git branch-name)
  _leave_notes_home
end

function _enter_notes_home
  pushd .
  cd $FD_NOTES_HOME  
end

function _leave_notes_home
  popd
end