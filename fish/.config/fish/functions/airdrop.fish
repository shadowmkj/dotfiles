function airdrop --description 'Send file via macOS Shortcuts AirDrop'
    if test (count $argv) -eq 0
        echo "Usage: airdrop /path/to/file"
        return 1
    end

    set -l target_file (path resolve $argv[1])

    if not test -e "$target_file"
        echo "Error: File '$target_file' does not exist."
        return 1
    end

    shortcuts run "AirDrop File" -i "$target_file"
end
