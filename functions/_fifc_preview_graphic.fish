function _fifc_preview_graphic -d "Preview media using the best terminal graphics protocol available"
    set -l file "$argv[1]"
    set -l dim "$FZF_PREVIEW_COLUMNS"x"$FZF_PREVIEW_LINES"
    set -l is_kitty_like 0

    function __fifc_clear_preview_graphics
        printf '\e[2J\e[H'
        printf '\e_Ga=d,d=A\e\\'
    end

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
            __fifc_clear_preview_graphics
            kitten icat --clear --transfer-mode=memory --unicode-placeholder --stdin=no --place="$dim@0x0" "$file" | sed '$d' | sed 's/\[m$//'
        else if type -q chafa
            __fifc_clear_preview_graphics
            chafa --clear --format kitty --passthrough=none --animate=off --size "$dim" "$file"
            echo
        else
            functions -e __fifc_clear_preview_graphics
            return 1
        end
    else if set -q SIXEL_SUPPORT; and test "$SIXEL_SUPPORT" = 1; and type -q chafa
        chafa --clear --format sixels --animate=off --size "$dim" "$file"
        echo
    else if type -q chafa
        chafa --clear --format symbols --animate=off --size "$dim" "$file"
        echo
    else
        functions -e __fifc_clear_preview_graphics
        return 1
    end

    functions -e __fifc_clear_preview_graphics
end
