
replace_content() {
    file="$1"
    domain="$2"
    domain_no_sub="$3"
    email="$4"

    sed -i.bak "s|\.YOURDOMAIN\.COM|.$domain_no_sub|g" "$file"
    sed -i.bak "s|YOURDOMAIN\.COM|$domain|g" "$file"
    sed -i.bak "s|YOUREMAIL|$email|g" "$file"
}


# install NAME LOC VOLUMES FILES
# Custom installation function called by docker-install.sh
# Arguments:
#   $1 - NAME:    The container/service name
#   $2 - LOC:     The installation location path
#   $3 - VOLUMES: Newline-separated list of volume names
#   $4 - FILES:   Newline-separated list of file/directory names
install() {
    local NAME="$1"
    local LOC="$2"
    local VOLUMES="$3"
    local FILES="$4"

    read -p "Please enter your domain (or subdomain): " input_domain
    if [ "$input_domain" == "" ]; then
        echo "Please specify your domain next time."
        exit 1
    fi
    if [[ ! $input_domain =~ ^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
        echo "Invalid domain format. Please enter a valid domain."
        exit 1
    fi
    domain=$input_domain
    domain_no_sub=$(echo $input_domain | awk -F'.' '{if (NF > 2) {print $(NF-1)"."$NF} else {print $0}}')

    # read -p "Please enter your email: " email

    for file in $FILES; do
        if [ -d "$LOC/$file" ]; then
            for myfile in "$LOC/$file"/*; do
                if [ -f "$myfile" ]; then
                    replace_content "$myfile" "$domain" "$domain_no_sub" "$email"
                fi
            done
        elif [ -f "$file" ]; then
            replace_content "$LOC/$file" "$domain" "$domain_no_sub" "$email"
        fi
    done
}
