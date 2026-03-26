function _fifc_preview_graphic -d "Preview media using the best terminal graphics protocol available"
    set -l file "$argv[1]"
    set -l dim "$FZF_PREVIEW_COLUMNS"x"$FZF_PREVIEW_LINES"

    if test "$dim" = x
        set dim (stty size </dev/tty | string split ' ' | awk '{ print $2 "x" $1 }')
    else if not set -q KITTY_WINDOW_ID
        set -l tty_size (stty size </dev/tty | string split ' ')
        if test (count $tty_size) -ge 1
            set -l tty_lines $tty_size[1]
            set -l preview_bottom (math "$FZF_PREVIEW_TOP + $FZF_PREVIEW_LINES")
            if test "$preview_bottom" -eq "$tty_lines"
                set dim "$FZF_PREVIEW_COLUMNS"x(math "$FZF_PREVIEW_LINES - 1")
            end
        end
    end

    if begin; set -q KITTY_WINDOW_ID; or set -q GHOSTTY_RESOURCES_DIR; end
        if type -q kitten
            kitten icat --clear --transfer-mode=memory --unicode-placeholder --stdin=no --place="$dim@0x0" "$file"
        else if type -q chafa
            chafa --clear --format kitty --passthrough=none --size "$dim" "$file"
            echo
        else
            return 1
        end
    else if set -q SIXEL_SUPPORT; and test "$SIXEL_SUPPORT" = 1; and type -q chafa
        chafa --clear --format sixels --size "$dim" "$file"
        echo
    else if type -q chafa
        chafa --clear --size "$dim" "$file"
        echo
    else
        return 1
    end
end
