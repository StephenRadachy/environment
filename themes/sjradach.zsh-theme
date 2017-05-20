# sjradach:
# A Powerline-inspired theme for ZSH
#
# OS X:
# Emulator - iTerm2
# Font - 13pt inconsolata for Powerline
# Color scheme - Argonaut
#
# Linux:
# Emulator - Konsole
# Font - 9pt inconsolata-g for Powerline
# Color scheme - Argonaut

### Segment drawing
# A few utility functions to make it easy and re-usable to draw segmented prompts

CURRENT_BG='NONE'
SEGMENT_SEPARATOR=''

# Begin a segment
# Takes two arguments, background and foreground. Both can be omitted,
# rendering default background/foreground.
prompt_segment() {
  local bg fg
  [[ -n $1 ]] && bg="%K{$1}" || bg="%k"
  [[ -n $2 ]] && fg="%F{$2}" || fg="%f"
  if [[ $CURRENT_BG != 'NONE' && $1 != $CURRENT_BG ]]; then
    echo -n " %{$bg%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR%{$fg%} "
  else
    echo -n "%{$bg%}%{$fg%} "
  fi
  CURRENT_BG=$1
  [[ -n $3 ]] && echo -n $3
}

# End the prompt, closing any open segments
prompt_end() {
  if [[ -n $CURRENT_BG ]]; then
    echo -n " %{%k%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR"
  else
    echo -n "%{%k%}"
  fi
  echo -n "%{%f%}"
  CURRENT_BG=''
}

### Prompt components
# Each component will draw itself, and hide itself if no information needs to be shown

# Context: user@hostname (who am I and where am I)
prompt_context() {
	if $(! git rev-parse --is-inside-work-tree >/dev/null 2>&1); then
		if [[ $UID == 0 || $EUID == 0 ]]; then
			# root
			prompt_segment white black "root"
		else
			dt=$(date "+%l:%M")
			dt=$(echo $dt | sed 's/ //')
			aorp=$(date "+%p" | awk '{print tolower($0)}')
			prompt_segment white black "$dt$aorp"
		fi
	fi
}

# Dir: displays working directory when not in a git repo
prompt_dir() {
    if $(! git rev-parse --is-inside-work-tree >/dev/null 2>&1); then 
        # parse working directory
        display_dir=$(dirs -p | head -n 1)
        if [[ $display_dir =~ "^/" ]]; then
            display_dir=$(echo $display_dir | cut -c 2-)
            split_dir=("${(@s:/:)display_dir}")
            split_dir=("/" ${split_dir[@]})
        else
            split_dir=("${(@s:/:)display_dir}")
        fi
        
        # display each folder as a prompt segment
        for (( j=1; j <= $#split_dir; j++)); do
            if [[ $((j % 3)) == 1 ]]; then
                prompt_segment blue white "$split_dir[$j]"
            elif [[ $((j % 3)) == 2 ]]; then
                prompt_segment magenta white "$split_dir[$j]"
            elif [[ $((j % 3)) == 0 ]]; then
                prompt_segment red white "$split_dir[$j]"
            fi
        done
    fi
}

# Git: branch/detached head, dirty status
prompt_git() {
  local ref dirty mode repo_path
  repo_path=$(git rev-parse --git-dir 2>/dev/null)

  if $(git rev-parse --is-inside-work-tree >/dev/null 2>&1); then
    # set context of git repo as the name of the repo
    repo_name=$(basename `git remote show -n origin | grep Fetch | cut -d: -f2- | sed s/.git$//` | xargs)
    if [[ $UID == 0 || $EUID == 0 ]]; then
		# root
		repo_name="root | $repo_name"
	fi
	prompt_segment white black $repo_name
    
    # parse the working directory relative to the repo
    display_dir=$(git rev-parse --show-prefix)
    split_dir=("${(@s:/:)display_dir}")
    
    # display each folder as a prompt segment
    for (( j=1; j < $#split_dir; j++)); do
        if [[ $((j % 3)) == 1 ]]; then
            prompt_segment blue white "$split_dir[$j]"
        elif [[ $((j % 3)) == 2 ]]; then
            prompt_segment magenta white "$split_dir[$j]"
        elif [[ $((j % 3)) == 0 ]]; then
            prompt_segment red white "$split_dir[$j]"
        fi
    done
    
    
    dirty=$(parse_git_dirty)
    ref=$(git symbolic-ref HEAD 2> /dev/null) || ref="➦ $(git show-ref --head -s --abbrev |head -n1 2> /dev/null)"
    if [[ -n $dirty ]]; then
      prompt_segment yellow black
    else
      prompt_segment green black
    fi

    if [[ -e "${repo_path}/BISECT_LOG" ]]; then
      mode=" <B>"
    elif [[ -e "${repo_path}/MERGE_HEAD" ]]; then
      mode=" >M<"
    elif [[ -e "${repo_path}/rebase" || -e "${repo_path}/rebase-apply" || -e "${repo_path}/rebase-merge" || -e "${repo_path}/../.dotest" ]]; then
      mode=" >R>"
    fi

    setopt promptsubst
    autoload -Uz vcs_info

    zstyle ':vcs_info:*' enable git
    zstyle ':vcs_info:*' get-revision true
    zstyle ':vcs_info:*' check-for-changes true
    zstyle ':vcs_info:*' stagedstr '✚'
    zstyle ':vcs_info:git:*' unstagedstr '●'
    zstyle ':vcs_info:*' formats ' %u%c'
    zstyle ':vcs_info:*' actionformats ' %u%c'
    vcs_info
    echo -n "${ref/refs\/heads\// }${vcs_info_msg_0_%% }${mode}"
  fi
}

## Main prompt
build_prompt() {
  RETVAL=$?
  prompt_context
  prompt_dir
  prompt_git
  prompt_end
}

PROMPT='$(build_prompt) '

