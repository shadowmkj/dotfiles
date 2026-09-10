function fish_greeting
	echo -e (uname -ro | awk '{print " \\\\e[1mOS: \\\\e[0;32m"$0"\\\\e[0m"}')
	echo -e (uptime | sed 's/^.*up  *\([^,]*\),.*/\1/' | awk '{print " \\\\e[1mUptime: \\\\e[0;32m"$0"\\\\e[0m"}')
	echo -e (uname -n | awk '{print " \\\\e[1mHostname: \\\\e[0;32m"$0"\\\\e[0m"}')

	echo -e " \e[1mTodos:\e[0;32m"
	if test -s ~/todo
		set_color magenta
		cat ~/todo | sed 's/^/ /'
		echo
	end
	set_color normal
end

starship init fish | source
zoxide init --cmd cd fish | source
if status is-interactive
    atuin init fish | source
end
eval "$(/opt/homebrew/bin/brew shellenv)"

fzf --fish | source

set -Ux EDITOR nvim
set -Ux VISUAL nvim
set -Ux MANPAGER "nvim +Man! -c 'set ft=man'"


# Fish git prompt
set __fish_git_prompt_showuntrackedfiles 'yes'
set __fish_git_prompt_showdirtystate 'yes'
set __fish_git_prompt_showstashstate ''
set __fish_git_prompt_showupstream 'none'
set -g fish_prompt_pwd_dir_length 3


set -gx YAZI_ADAPTER kitty

# Replace ls with eza
alias ls='eza --icons --git'

# Long format, shows all files, with headers
alias ll='eza --long --all --header --icons --git'

alias y='yazi'

alias v='nvim'
alias ta='tmux attach'
alias lg='lazygit'
alias pms='podman machine stop'
alias pmS='podman machine start'
alias gta='cd ~/Documents/Desk/Apps'
alias hideicons='defaults write com.apple.finder CreateDesktop false'
alias showicons='defaults write com.apple.finder CreateDesktop true'
alias tf="terraform"
alias ff="fastfetch"
alias tns="tmux new-session -s (pwd | path basename)"
alias tks="tmux kill-server"
alias tls="tmux list-sessions"
alias bat="bat --theme='base16-256'"
alias lc="leetrs"
alias cg="cargo"
alias agyc="agy -c"
alias ofinder="open -a Finder ."

# git aliases
alias gs="git status"
alias gd="git diff"
alias gds="git diff --staged"
alias gla="git log --oneline --graph --decorate --all"
# alias gl="git log --oneline --graph --decorate"
alias gl="serie -p kitty-unicode"
alias gll="git log --stat"
alias gsw="git switch"

alias ga="git add"
alias gaa="git add --all"
alias gr="git restore"
alias grs="git restore --staged"

alias gc="git commit"
alias gcm="git commit -m"
alias gca="git commit --amend"
alias gcan="git commit --amend --no-edit"

alias gb="git branch"
alias gba="git branch --all"
alias gbd="git branch -d"
alias gbD="git branch -D"

alias gf="git fetch"
alias gfa="git fetch --all --prune"
alias gp="git pull"
alias gP="git push"

alias gst="git stash"
alias gstp="git stash pop"
alias gstl="git stash list"
alias gundo="git reset --soft HEAD~1"

function gop
    set full_remote (git remote get-url origin)

    if string match -q "https*" $full_remote
        set user (echo $full_remote | awk -F'/' '{print $4}')
        set repo (echo $full_remote | awk -F'/' '{print $5}' | sed 's/\.git$//')
    else
        set user (echo $full_remote | awk -F'[:/]' '{print $2}')
        set repo (echo $full_remote | awk -F'[:/]' '{print $3}' | sed 's/\.git$//')
    end

    open "https://github.com/$user/$repo"
end

function gco --wraps "git switch"
    git switch $argv
end

function gnew --wraps "git switch -c"
    git switch -c $argv
end


# # Yazi cd integration
function y
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    yazi $argv --cwd-file="$tmp"
    if set cwd (command cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
        builtin cd -- "$cwd"
    end
    rm -f -- "$tmp"
end



# A function to list all tinty themes and select one (or cycle)
function theme
    if test "$argv[1]" = "cycle"
        tinty cycle
    else
        set themes (tinty list)
        set selected (printf '%s\n' $themes | fzf --prompt="Select a tinty theme: ")
        if test -n "$selected"
            tinty apply "$selected"
        end
    end

    # kitty @ set-colors --all /Users/milan/.local/share/tinted-theming/tinty/tinted-terminal-themes-kitty-file.conf
    tmux source-file ~/.tmux.conf 2>/dev/null
end

function apps
    set dirs (fd -t d -d 1 . ~/Documents/Desk/Apps ~/Documents/Desk/Learn ~/Documents/Desk/others | awk -F/ '{print $7}' | fzf)
    if test -n "$dirs"
        cd ~/Documents/Desk/Apps/$dirs
    end
end

function tnew
    set -l search_dirs ~/Documents/Desk/Apps ~/Documents/Desk/Learn ~/Documents/Desk/others
    set -l all_paths (fd -t d -d 1 . $search_dirs | sed 's#/$##')
    set -l project_name (printf '%s\n' $all_paths | path basename | fzf)

    if test -n "$project_name"
        set -l project_path (printf '%s\n' $all_paths | grep -m1 -E "/$project_name\$")
        # Replace dots with underscores because tmux parses dots as session:window separators
        set -l session_name (string replace -a '.' '_' "$project_name")

        if not tmux has-session -t "$session_name" 2>/dev/null
            if test -n "$TMUX"
                tmux new-session -d -s "$session_name" -c "$project_path"
            else
                tmux new-session -s "$session_name" -c "$project_path"
            end
        end

        if test -n "$TMUX"
            tmux switch-client -t "$session_name"
        else
            tmux attach-session -t "$session_name"
        end
    end
end

function tnewc
    set -l search_dirs ~/Documents/Desk/Apps ~/Documents/Desk/Learn ~/Documents/Desk/others
    set -l all_paths (fd -t d -d 1 . $search_dirs | sed 's#/$##')
    set -l project_name (printf '%s\n' $all_paths | path basename | sort -f | choose)

    if test -n "$project_name"
        set -l project_path (printf '%s\n' $all_paths | grep -m1 -E "/$project_name\$")
        # Replace dots with underscores because tmux parses dots as session:window separators
        set -l session_name (string replace -a '.' '_' "$project_name")

        # Create session in background if it does not already exist
        if not tmux has-session -t "$session_name" 2>/dev/null
            tmux new-session -d -s "$session_name" -c "$project_path"
        end

        # Handle attachment based on the execution environment
        if test -t 0
            # Running inside an interactive terminal (Ghostty, Kitty, etc.)
            if test -n "$TMUX"
                tmux switch-client -t "$session_name"
            else
                tmux attach-session -t "$session_name"
            end
        else
            # Running headless / outside a terminal (e.g. skhd global hotkey).
            # IMPORTANT: We must check for actual client output, not just exit code.
            # After `tmux new-session -d` the server is running so list-clients
            # exits 0 even when nobody is visually attached to a window.
            if tmux list-clients 2>/dev/null | grep -q .
                # A real terminal (Ghostty) is attached to tmux; switch it there.
                tmux switch-client -t "$session_name"
                osascript -e 'tell application "Ghostty" to activate'
            else if pgrep -q -i ghostty
                # Ghostty is open with at least one window. Open a new tab in the
                # front window and type the attach command into the running fish shell.
                # We use "perform action new_tab" (works in 1.3) + "input text" +
                # "send key enter" rather than "new tab with configuration" (broken).
                # Using input text keeps fish alive after tmux exits — the shell is
                # still running underneath; only the tmux process exited.
                osascript -e "tell application \"Ghostty\"
                    activate
                    set existingTerminal to item 1 of (terminals of front window)
                    perform action \"new_tab\" on existingTerminal
                    delay 0.4
                    set focTerm to focused terminal of (selected tab of front window)
                    input text \"tmux attach-session -t $session_name\" to focTerm
                    delay 0.1
                    send key \"enter\" to focTerm
                end tell"
            else
                # Ghostty is closed entirely. Launch it and open the session using
                # initial input (types command into fish) rather than command (which
                # replaces fish and causes the window to close when tmux exits).
                osascript -e "tell application \"Ghostty\"
                    activate
                    repeat until (exists front window)
                        delay 0.05
                    end repeat
                    set term to focused terminal of selected tab of front window
                    input text \"tmux attach-session -t $session_name\n\" to term
                end tell"
            end
        end
    end
end

function sudolast
    sudo (history --max=1)
end

function bms --description "Bookmarks"
    set bookmark_file /Users/milan/.config/bookmarks.txt
    set -l bookmark (cat $bookmark_file | fzf --prompt="Select bookmark: ")
    if test -n "$bookmark"
        set -l bookmark_name (echo $bookmark | awk '{print $1}')
        set -l bookmark_url (echo $bookmark | awk '{print $3}')
        echo $bookmark_url | pbcopy
        echo "Copied bookmark '$bookmark_name' URL to clipboard: $bookmark_url"
    end
end


function dbm --description "Delete bookmark"
    set bookmark_file /Users/milan/.config/bookmarks.txt
    set -l bookmark (cat $bookmark_file | fzf --prompt="Select a bookmark to delete: ")
    if test -n "$bookmark"
        set -l bookmark_name (echo $bookmark | awk '{print $1}')
        set -l confirm (read -P "Are you sure you want to delete the bookmark '$bookmark_name'? (y/n): ")
        if test "$confirm" = "y"
            rg -v $bookmark $bookmark_file > $bookmark_file.tmp
            mv $bookmark_file.tmp $bookmark_file
            echo "Deleted bookmark '$bookmark_name' ($bookmark_path)"
        else
            echo "Aborted deletion of bookmark '$bookmark_name' ($bookmark_path)"
        end
    end
end

bind \cr _atuin_bind_up
bind -M insert \cl forward-char
bind -M insert \cr _atuin_bind_up

bind ctrl-shift-t 'theme cycle'

bind up up-or-search
bind -M insert up up-or-search



# Added by Antigravity
fish_add_path /Users/milan/.antigravity/antigravity/bin

# LuaRocks 5.1 / Neovim paths
set -gx LUA_PATH "$HOME/.luarocks/share/lua/5.1/?.lua;$HOME/.luarocks/share/lua/5.1/?/init.lua;;"
set -gx LUA_CPATH "$HOME/.luarocks/lib/lua/5.1/?.so;;"

# Add LuaRocks binaries to your PATH
fish_add_path $HOME/.luarocks/bin


~/.local/bin/mise activate fish | source

# pnpm
set -gx PNPM_HOME "/Users/milan/Library/pnpm"
if not string match -q -- $PNPM_HOME $PATH
  set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end

# Added by Antigravity IDE
fish_add_path /Users/milan/.antigravity-ide/antigravity-ide/bin

# Added by Antigravity IDE
fish_add_path /Users/milan/.antigravity-ide/antigravity-ide/bin

# opencode
fish_add_path /Users/milan/.opencode/bin

fish_add_path /Users/milan/development/flutter/bin



# Added by Antigravity CLI installer
set -gx PATH "/Users/milan/.local/bin" $PATH


# ------------------------------------------------------------------------------
# Optional: Fuzzy Tab Completion with fzf
# Uncomment the function and bind statements below to enable fzf tab completion.
# ------------------------------------------------------------------------------
# function fzf-complete
#     set -l cmd (commandline -c)
#     test -z "$cmd"; and set cmd ""
#     set -l current_token (commandline -ct)
#
#     # Generate completion list and pipe to fzf floating menu
#     set -l completions (complete -C"$cmd")
#     test -z "$completions"; and return
#
#     set -l result (printf "%s\n" $completions | fzf --height=40% --border=rounded --layout=reverse --delimiter=\t --query="$current_token" --select-1 --exit-0)
#
#     if test -n "$result"
#         set -l val (string match -r "^[^\t]+" -- "$result")
#         if test -n "$val"
#             # Escape special characters while preserving leading ~ and $
#             set -l escaped (string escape -n -- "$val" | string replace -r "^\x5C~" "~" | string replace -r "^\\\\\\\$" "\$\$")
#             if string match -q "*/" -- "$val"
#                 commandline -rt -- "$escaped"
#             else
#                 commandline -rt -- "$escaped "
#             end
#         end
#     end
#     commandline -f repaint
# end
#
# # Bind Tab to open the fzf menu in both normal and insert modes
# bind \t fzf-complete
# bind -M insert \t fzf-complete
#
#
