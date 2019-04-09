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
SEGMENT_COLOR='006'
SEGMENT_START='%F{$SEGMENT_COLOR}['
SEGMENT_END='%F{$SEGMENT_COLOR}]'
SEGMENT_SEPARATOR="$SEGMENT_END$SEGMENT_START"

# Begin a segment
# Takes two arguments, background and foreground. Both can be omitted,
# rendering default background/foreground.
prompt_segment() {
    local bg fg
    [[ -n $1 ]] && bg="%K{$1}" || bg="%k"
    [[ -n $2 ]] && fg="%F{$2}" || fg="%f"
    if [[ $CURRENT_BG == 'SPLIT' || $CURRENT_BG != 'NONE' && $1 != $CURRENT_BG ]]; then
        echo -n " %{$bg%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR%{$fg%} "
    else
        echo -n "%{$bg%}%{$fg%} "
    fi
    CURRENT_BG=$1
    [[ -n $3 ]] && echo -n $3
}

prompt_segment_nospace() {
    local bg fg
    [[ -n $1 ]] && bg="%K{$1}" || bg="%k"
    [[ -n $2 ]] && fg="%F{$2}" || fg="%f"
    if [[ $CURRENT_BG == 'SPLIT' || $CURRENT_BG != 'NONE' && $1 != $CURRENT_BG ]]; then
        echo -n "%{$bg%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR%{$fg%}"
    else
        echo -n "%{$bg%}%{$fg%}"
    fi
    CURRENT_BG=$1
    [[ -n $3 ]] && echo -n $3
}

# End the prompt, closing any open segments
prompt_end() {
    if [[ -n $CURRENT_BG ]]; then
        echo -n " %{%k%F{$CURRENT_BG}%}"
    else
        echo -n "%{%k%}"
    fi
    echo -n "%{%f%}"
    CURRENT_BG=''
}

### Prompt components
# Each component will draw itself, and hide itself if no information needs to be shown

# Dir: displays relative working path
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
        # don't display relative path 1st time around when it will be
        # shown with git
        elif [ -z "$1" ]; then
        return 0
    else
        # set context of git repo as the name of the repo
        repo_name=$(basename `git remote show -n origin | grep Fetch | cut -d: -f2- | sed s/.git$//` | xargs)
        
        # parse the working directory relative to the repo
        display_dir=$(git rev-parse --show-prefix | sed s'/.$//')
        if [ -n "${display_dir}" ]; then
            prompt_segment 'NONE' $SEGMENT_COLOR "|"
            split_dir=(${(@s:/:)display_dir})
        else
            return 0
        fi
    fi
    
    # display each folder as a prompt segment
    for (( j=1; j <= $#split_dir; j++)); do
        if [[ $((j % 3)) == 1 ]]; then
            prompt_segment 'NONE' blue "$split_dir[$j]"
            elif [[ $((j % 3)) == 2 ]]; then
            prompt_segment 'NONE' magenta "$split_dir[$j]"
            elif [[ $((j % 3)) == 0 ]]; then
            prompt_segment 'NONE' red "$split_dir[$j]"
        fi
        if [[ $((j)) != $(($#split_dir)) ]]; then
            prompt_segment 'NONE' $SEGMENT_COLOR "|"
            elif [ -z "$1" ]; then
            # if last and not a part of git, add in a section splitter
            prompt_segment_nospace 'SPLIT'
        fi
    done
}

# Git: branch/detached head, dirty status
prompt_git() {
    local ref dirty mode repo_path
    repo_path=$(git rev-parse --git-dir 2>/dev/null)
    
    if $(git rev-parse --is-inside-work-tree >/dev/null 2>&1); then
        dirty=$(parse_git_dirty)
        ref=$(git symbolic-ref HEAD 2> /dev/null) || ref="➦ $(git show-ref --head -s --abbrev |head -n1 2> /dev/null)"
        if [[ -n $dirty ]]; then
            git_segment_color='yellow'
        else
            git_segment_color='green'
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
        prompt_segment 'NONE' white "$(basename "$(git rev-parse --absolute-git-dir | sed 's/\/\.git$//')")"
        prompt_dir 'relative-git-path' # show relative git path
        prompt_segment 'NONE' $SEGMENT_COLOR "|"
        prompt_segment 'NONE' $git_segment_color "${ref/refs\/heads\//ϒ }${vcs_info_msg_0_%% }${mode}"
    fi
}

## Main prompt
build_prompt() {
    RETVAL=$?
    echo -n "${SEGMENT_START}"
    prompt_dir
    prompt_git
    echo -n " ${SEGMENT_END}"
    prompt_end
}

PROMPT='$(build_prompt)'

