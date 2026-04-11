
install() {
    local NAME="$1"
    local LOC="$2"
    local VOLUMES="$3"
    local FILES="$4"

    touch "$LOC/machine-id"

    openssl rand -hex 16 > "$LOC/machine-id"

}
