function _fifc_preview_file -d "Preview the selected file with the right tool depending on its type"
    set -l file_type (_fifc_file_type "$fifc_candidate")

    switch $file_type
        case txt json archive binary
            _fifc_clear_graphics
    end

    switch $file_type
        case txt
            _fifc_clear_graphics
            if type -q bat
                bat --color=always $fifc_bat_opts "$fifc_candidate"
            else
                cat "$fifc_candidate"
            end
        case json
            _fifc_clear_graphics
            if type -q bat
                bat --color=always -l json $fifc_bat_opts "$fifc_candidate"
            else
                cat "$fifc_candidate"
            end
        case image
            if _fifc_preview_graphic "$fifc_candidate"
            else if type -q exiftool
                exiftool "$fifc_candidate"
            else
                _fifc_preview_file_default "$fifc_candidate"
            end
        case pdf
            if type -q pdftoppm
                set -l preview_png (_fifc_preview_cache_file "$fifc_candidate" pdf png)
                if not test -f "$preview_png"
                    set -l preview_dir (mktemp -d)
                    set -l preview_base "$preview_dir/preview"
                    pdftoppm -f 1 -singlefile -png "$fifc_candidate" "$preview_base" >/dev/null 2>&1
                    if test -f "$preview_base.png"
                        mv "$preview_base.png" "$preview_png"
                    end
                    rm -rf "$preview_dir"
                end

                if test -f "$preview_png"; and _fifc_preview_graphic "$preview_png"
                else if type -q pdftotext
                    _fifc_clear_graphics
                    pdftotext -l 10 -nopgbrk "$fifc_candidate" - 2>/dev/null
                else
                    _fifc_preview_file_default "$fifc_candidate"
                end
            else if type -q pdftotext
                _fifc_clear_graphics
                pdftotext -l 10 -nopgbrk "$fifc_candidate" - 2>/dev/null
            else
                _fifc_preview_file_default "$fifc_candidate"
            end
        case video
            if type -q ffmpegthumbnailer
                set -l thumbnail (_fifc_preview_cache_file "$fifc_candidate" video jpg)
                if not test -f "$thumbnail"
                    set -l temp_thumbnail (mktemp -t fifc-video-preview.XXXXXX.jpg)
                    ffmpegthumbnailer -i "$fifc_candidate" -o "$temp_thumbnail" -s 0 -q 8 >/dev/null 2>&1
                    if test -f "$temp_thumbnail"
                        mv "$temp_thumbnail" "$thumbnail"
                    else
                        rm -f "$temp_thumbnail"
                    end
                end

                if test -f "$thumbnail"; and _fifc_preview_graphic "$thumbnail"
                else if type -q mediainfo
                    _fifc_clear_graphics
                    mediainfo "$fifc_candidate"
                else if type -q exiftool
                    _fifc_clear_graphics
                    exiftool "$fifc_candidate"
                else
                    _fifc_preview_file_default "$fifc_candidate"
                end
            else if type -q mediainfo
                _fifc_clear_graphics
                mediainfo "$fifc_candidate"
            else if type -q exiftool
                _fifc_clear_graphics
                exiftool "$fifc_candidate"
            else
                _fifc_preview_file_default "$fifc_candidate"
            end
        case archive
            if type -q 7z
                7z l ""$fifc_candidate"" | tail -n +17 | awk '{ print $6 }'
            else
                _fifc_preview_file_default "$fifc_candidate"
            end
        case binary
            if type -q hexyl
                hexyl $fifc_hexyl_opts "$fifc_candidate"
            else
                _fifc_preview_file_default "$fifc_candidate"
            end

    end
end
