get_numeric_dev() {
(
    fmt="%d:%d"
    if [ "$1" = "hex" ]; then
        fmt="%x:%x"
    fi
    ls -lH "$2" | awk '{ sub(/,/, "", $5); printf("'"$fmt"'", $5, $6); }'
) 2>/dev/null
}