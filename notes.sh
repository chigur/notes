#!/usr/bin/env bash

dropbox_dir=~/"Dropbox/work/notes"
notes_dirname=".notes"
# switch to commit the notes dir
((commit_notes='0'))
# has to be regex escaped
note_done_marker='✔'
first_todo="tasks.todo"

gen_patch() {
	git diff --no-index -- "$1" "$2"
}

parse_done() {
	echo "";
	grep -E -h "+\s+$note_done_marker";
}

sanitize_commit_msg() {
	sed -i -r "s:\+\s+$note_done_marker:*:g" "$1"
	sed -i -r "s:@.*$::g" "$1"
}

to_win_path() {
	if [[ "${1:0:1}" = '/' ]]; then
		path="${1:2}"
		drive_letter="${1:1:1}"
		path="${drive_letter^^}:$path"
		# if leading slash is provided
		# then change drive letters
	else
		# assume that this is a relative path
		# and henve no drive letter changing is done
		path="$1"
	fi

	path="${path//\//\\}"
	echo "$path"
}

create_link() {
	path="$(to_win_path $1)"
	# don't forget to quote the path
	./create_link.cmd "$notes_dirname" "$path"
}

init() {
	name="$(pwd)"
	name="${name##*/}"
	notes_dir="$dropbox_dir/$name"

	if ! git status &>/dev/null; then
		git init
	fi

	if ! [[ -d "$notes_dir" ]]; then
		mkdir "$notes_dir"
		touch "$notes_dir/$first_todo"
		which subl &>/dev/null && subl "$notes_dir/$first_todo"
	fi

	create_link "$notes_dir"
	mkdir "$notes_dirname/prev"

	# we don't care if the no '.gitignore' file is present
	# so squash the error
	if ! grep "$notes_dirname" '.gitignore' &>/dev/null && ! ((commit_notes)); then
		echo "$notes_dirname" >> '.gitignore'
		git add '.gitignore'
		git commit -m "add .notes dir"
		echo ""
		echo "================================"
		echo "To change the commit message run"
		echo "git commit --amend"
		echo "================================"
	fi
}

commit() {
	for file in "$notes_dirname"/*; do
		if ! [[ -f "$file" ]]; then
			continue
		fi

		name="${file##*/}"
		prev_file="$notes_dirname/prev/$name"

		if ! [[ -f "$prev_file" ]]; then
			touch "$prev_file"
		fi

		gen_patch "$prev_file" "$file" | parse_done > commit_template

		sanitize_commit_msg commit_template

		git commit -t commit_template

		if [[ "$?" = "0" ]]; then
			cp "$file" "$prev_file"
		fi

		rm commit_template
	done
}

help() {
	cat <<EOF
usage: notes <command>

Following commands can be used

init 	init a new note for the current project
help 	print this help message
EOF
}

command="$1"

case "$command" in
	"init") init ;;
	"commit") commit ;;
	"") help ;;
esac
