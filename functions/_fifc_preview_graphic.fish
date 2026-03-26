function _fifc_preview_graphic -d "Preview media using the best terminal graphics protocol available"
    set -l file "$argv[1]"
    set -l dim "$FZF_PREVIEW_COLUMNS"x"$FZF_PREVIEW_LINES"
    set -l is_kitty_like 0

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

    if set -q KITTY_WINDOW_ID
        set is_kitty_like 1
    else if set -q GHOSTTY_RESOURCES_DIR
        set is_kitty_like 1
    else if test "$TERM_PROGRAM" = ghostty
        set is_kitty_like 1
    end

    if test $is_kitty_like -eq 1
        if type -q kitten
            sleep 0.05
            _fifc_clear_graphics
            kitten icat --clear --transfer-mode=memory --unicode-placeholder --stdin=no --place="$dim@0x0" "$file" | sed '$d' | sed 's/\[m$//'
        else if type -q chafa
            sleep 0.05
            _fifc_clear_graphics
            chafa --clear --format kitty --passthrough=none --animate=off --size "$dim" "$file"
            echo
        else
            return 1
        end
    else if set -q SIXEL_SUPPORT; and test "$SIXEL_SUPPORT" = 1; and type -q chafa
        sleep 0.05
        chafa --clear --format sixels --animate=off --size "$dim" "$file"
        echo
    else if type -q chafa
        sleep 0.05
        chafa --clear --format symbols --animate=off --size "$dim" "$file"
        echo
    else
        return 1
    end
end
