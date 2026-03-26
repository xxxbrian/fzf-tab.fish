function _fifc_preview_file -d "Preview the selected file using the configured external preview script"
    set -l preview_script

    if set -q FIFC_PREVIEW_SCRIPT; and test -x "$FIFC_PREVIEW_SCRIPT"
        set preview_script "$FIFC_PREVIEW_SCRIPT"
    else if set -q XDG_CONFIG_HOME; and test -x "$XDG_CONFIG_HOME/fzf/executable_fzf-preview.sh"
        set preview_script "$XDG_CONFIG_HOME/fzf/executable_fzf-preview.sh"
    else if test -x "$HOME/.config/fzf/fzf-preview.sh"
        set preview_script "$HOME/.config/fzf/fzf-preview.sh"
    end

    if test -z "$preview_script"
        _fifc_preview_file_default "$fifc_candidate"
        return
    end

    "$preview_script" "$fifc_candidate"
    or _fifc_preview_file_default "$fifc_candidate"
end
