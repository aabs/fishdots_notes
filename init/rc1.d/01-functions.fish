define_command note "A simple plugin for managing a large hierarchy of textual notes"

define_subcommand note home on_note_home "go to the root of the notes collection"
define_subcommand note info on_note_info "display config details of note plugin"
define_subcommand_nonevented note ls note_ls "list all notes (maybe long)"
define_subcommand note tasks on_note_tasks ""
define_subcommand_nonevented note edit note_edit "edit the note identified by the path"
define_subcommand_nonevented note find note_find "find the note by searching file names"
define_subcommand_nonevented note search note_search "perform a full text search for patterns"
define_subcommand note create on_note_create "create a new note"
define_subcommand note pcreate on_note_pcreate "create a new note within a project area"
define_subcommand note save on_note_save "save any new or modified notes locally (to git)"
define_subcommand note sync on_note_sync "save notes and push to origin"
define_subcommand note move on_note_move "rename or move the note"

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

function note_tasks -e on_note_tasks  -d "find all tasks"
  ag --markdown -Q -- '- [ ]' $FD_NOTES_HOME 
end

function note_create -e on_note_create -a title -d "create a new text note"
  set escaped_file_name (_escape_string $title)
  set d (date --iso-8601)
  set p "$FD_NOTES_HOME/$d-$escaped_file_name.md"
  note_edit $p
  echo wrote "$p" to notes
end

function note_create_project_note -e on_note_pcreate  -a title -d "create a new text note within a project area"
  set escaped_file_name (_escape_string $title)
  set d (date --iso-8601)
  set p "$FD_NOTES_HOME/$CURRENT_PROJECT_SN/$d-$escaped_file_name.md"
  note_edit $p
  echo wrote "$p" to notes
end

function _note_search -a pattern -d "find note by full text search"
  fishdots_search $FD_NOTES_HOME $pattern

end

function note_home -e on_note_home
  cd $FD_NOTES_HOME
end

function note_move -e on_note_move -a from_basename to_basename -d "change the name of a note"
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

function note_edit -a file_path -d "open the file in nvim"
  if test $file_path = '-'
    read -l x
    echo "editing $x"
    nvim $x
  else
    nvim $file_path
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

function note_ls -d "just list every markdown based note"
  _note_find '*.md'
end

function note_find -a search_pattern -d "file name search for <pattern>, opens selection in default editor"
  fishdots_find_select $FD_NOTES_HOME $search_pattern
  note_edit $fd_selected_file
end

function note_search -a search_pattern -d "full text search for <pattern>, opens selection in default editor"
  fishdots_search_select $FD_NOTES_HOME $search_pattern
  note_edit $fd_selected_file
end

function get_file_relative_path -a path_to_note -d "description"
  set filename (string replace $FD_NOTES_HOME "" $path_to_note)
  echo $filename
end

function _note_find -a pattern -d "find note by note name"
    fishdots_find $FD_NOTES_HOME $pattern
end

function note_sync -e on_note_sync -d "save all notes to origin repo"
  fishdots_git_sync $FD_NOTES_HOME "notes updates and additions"
end

function note_info -e on_note_info -d "display note plugin config info"
  echo -e "Home Dir:\t\t$FD_NOTES_HOME"
end