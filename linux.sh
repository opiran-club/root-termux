#!/data/data/com.termux/files/usr/bin/bash
# run with your responsibility

print_ew() {
    local msg_type="$1"
    local msg_text="$2"
    local color_code=""

    case "$msg_type" in
        error)    color_code="1"; prefix="[ERROR]:" ;;
        warn)     color_code="220"; prefix="[WARNING]:" ;;
        question) color_code="128"; prefix="[QUESTION]:" ;;
        info)     color_code="83"; prefix="[Installer thread/INFO]:" ;;
        *)        color_code="31"; prefix="[$msg_type]:" ;;
    esac

    local current_time
    current_time="$(date +"%H:%M:%S")"

    printf "\x1b[38;5;214m[%s] \x1b[38;5;%sm%s\x1b[0m \x1b[38;5;87m%s\x1b[0m\n" "$current_time" "$color_code" "$prefix" "$msg_text"
}

# Ensure the script is running on Termux (Android)
if [[ "$(uname -o)" != "Android" ]]; then
    print_ew "error" "This script is for Termux." && exit 1
fi

fn_install() {
    clear
    local directory="ubuntu-fs"
    local UBUNTU_VERSION="jammy"

    if [[ -d "$directory" ]]; then
        print_ew "warn" "Skipping the download and extraction as the directory already exists."
        return
    fi

    for cmd in proot wget; do
        if ! command -v "$cmd" > /dev/null; then
            print_ew "error" "Please install $cmd." && exit 1
        fi
    done

    # Remove any existing ubuntu.tar.gz file
    [[ -f "ubuntu.tar.gz" ]] && rm -f ubuntu.tar.gz

    print_ew "info" "Downloading the Ubuntu rootfs, please wait..."

    local ARCHITECTURE
    ARCHITECTURE=$(dpkg --print-architecture)

    case "$ARCHITECTURE" in
        aarch64) ARCHITECTURE="arm64" ;;
        arm)     ARCHITECTURE="armhf" ;;
        amd64|x86_64) ARCHITECTURE="amd64" ;;
        *)
            print_ew "error" "Unknown architecture: $ARCHITECTURE" && exit 1 ;;
    esac

    wget -q -O ubuntu.tar.gz "https://partner-images.canonical.com/core/${UBUNTU_VERSION}/current/ubuntu-${UBUNTU_VERSION}-core-cloudimg-${ARCHITECTURE}-root.tar.gz"
    print_ew "info" "Download complete!"

    # Decompress Ubuntu rootfs
    mkdir -p "$directory"
    print_ew "info" "Decompressing the Ubuntu rootfs, please wait..."
    proot --link2symlink tar -zxf ubuntu.tar.gz --exclude='dev' -C "$directory"
    print_ew "info" "The Ubuntu rootfs has been successfully decompressed!"

    # Configure resolv.conf
    print_ew "info" "Configuring DNS settings..."
    printf "nameserver 8.8.8.8\nnameserver 8.8.4.4\n" > "$directory/etc/resolv.conf"

    # Write stubs
    print_ew "info" "Writing stubs..."
    echo -e "#!/bin/sh\nexit" > "$directory/usr/bin/groups"
    print_ew "info" "Successfully wrote stubs!"

    # Create start.sh script
    local bin="start.sh"
    print_ew "info" "Creating the start script, please wait..."

    cat > "$bin" <<- EOM
#!/bin/bash
# -*- coding: utf-8 -*-

cd \$(dirname \$0)

# Unset LD_PRELOAD in case termux-exec is installed
unset LD_PRELOAD
command="proot --link2symlink -0 -r $directory"

# Bind necessary directories
for dir in /dev /proc /sys ubuntu-fs/tmp:/dev/shm /data/data/com.termux /:/host-rootfs /sdcard /storage /mnt; do
    command+=" -b \$dir"
done

# Set environment variables
command+=" -w /root /usr/bin/env -i HOME=/root PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/games:/usr/local/games TERM=\$TERM LANG=C.UTF-8 /bin/bash --login"

# Execute the command
if [[ -z "\$1" ]]; then
    exec \$command
else
    \$command -c "\$@"
fi
EOM

    print_ew "info" "The start script has been successfully created!"
    
    # Fix the shebang and make the script executable
    print_ew "info" "Fixing the shebang of start.sh..."
    termux-fix-shebang "$bin" > /dev/null
    print_ew "info" "Successfully fixed the shebang!"

    print_ew "info" "Making start.sh executable..."
    chmod +x "$bin"
    print_ew "info" "Successfully made start.sh executable!"

    # Clean up
    print_ew "info" "Cleaning up..."
    rm -f ubuntu.tar.gz
    print_ew "info" "Successfully cleaned up!"
    print_ew "info" "Installation completed! Run => bash start.sh"
}

# Installation process
trap '' 2

if [[ "$1" == "-y" ]]; then
    fn_install
elif [[ -z "$1" ]]; then
    print_ew "question" "Do you want to install Ubuntu-in-Termux? [Y/n] " && read -r cmd
    if [[ "$cmd" =~ ^[Yy]$ ]]; then
        fn_install
    else
        print_ew "error" "Installation aborted."
    fi
else
    print_ew "error" "Invalid option. Installation aborted."
fi
