function _fifc_preview_cache_file -d "Return a stable cache file path for preview artifacts"
    set -l source_file "$argv[1]"
    set -l kind "$argv[2]"
    set -l ext "$argv[3]"

    set -l source_real "$source_file"
    if type -q realpath
        set source_real (realpath "$source_file" 2>/dev/null)
        or set source_real "$source_file"
    end

    set -l stamp (stat -f '%m-%z' "$source_file" 2>/dev/null)
    or set stamp unknown

    set -l digest_line (printf '%s' "$kind|$source_real|$stamp" | shasum -a 256)
    set -l digest (string split ' ' -- "$digest_line")[1]

    set -l cache_dir "$HOME/.cache/fifc-preview/$kind"
    mkdir -p "$cache_dir"
    echo "$cache_dir/$digest.$ext"
end
