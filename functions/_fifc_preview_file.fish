function _fifc_preview_file -d "Preview the selected file with the right tool depending on its type"
    set -l file_type (_fifc_file_type "$fifc_candidate")

    switch $file_type
        case txt
            if type -q bat
                bat --color=always $fifc_bat_opts "$fifc_candidate"
            else
                cat "$fifc_candidate"
            end
        case json
            if type -q bat
                bat --color=always -l json $fifc_bat_opts "$fifc_candidate"
            else
                cat "$fifc_candidate"
            end
        case image
            if type -q chafa
                chafa $fifc_chafa_opts "$fifc_candidate"
            else if type -q exiftool
                exiftool "$fifc_candidate"
            else
                _fifc_preview_file_default "$fifc_candidate"
            end
        case pdf
            if type -q pdftoppm; and type -q chafa
                set -l preview_dir (mktemp -d)
                set -l preview_base "$preview_dir/preview"
                pdftoppm -f 1 -singlefile -png "$fifc_candidate" "$preview_base" >/dev/null 2>&1
                if test -f "$preview_base.png"
                    chafa $fifc_chafa_opts "$preview_base.png"
                else if type -q pdftotext
                    pdftotext -l 10 -nopgbrk "$fifc_candidate" - 2>/dev/null
                else
                    _fifc_preview_file_default "$fifc_candidate"
                end
                rm -rf "$preview_dir"
            else if type -q pdftotext
                pdftotext -l 10 -nopgbrk "$fifc_candidate" - 2>/dev/null
            else
                _fifc_preview_file_default "$fifc_candidate"
            end
        case video
            if type -q ffmpegthumbnailer; and type -q chafa
                set -l thumbnail (mktemp -t fifc-video-preview.XXXXXX.jpg)
                ffmpegthumbnailer -i "$fifc_candidate" -o "$thumbnail" -s 0 -q 8 >/dev/null 2>&1
                if test -f "$thumbnail"
                    chafa $fifc_chafa_opts "$thumbnail"
                else if type -q mediainfo
                    mediainfo "$fifc_candidate"
                else if type -q exiftool
                    exiftool "$fifc_candidate"
                else
                    _fifc_preview_file_default "$fifc_candidate"
                end
                rm -f "$thumbnail"
            else if type -q mediainfo
                mediainfo "$fifc_candidate"
            else if type -q exiftool
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
