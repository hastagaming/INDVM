#!/bin/bash

# Path
DIR="$HOME/INDVM"
VM_DIR="$DIR/vms"
ISO_DIR="$DIR/iso"
CONF_DIR="$DIR/configs"

# Main Menu
main_menu() {
    cmd=$(dialog --backtitle "INDVM v1.0 - Nasa Project" --title " MAIN MENU " --menu "Pilih Modul:" 15 50 5 \
    "1" "ROM Manager (Vectras Style)" \
    "2" "Create OS (Limbo Style)" \
    "3" "Boot Virtual Machine" \
    "4" "Sync to GitHub" \
    "5" "Exit" 2>&1 >/dev/tty)

    case $cmd in
        1) rom_manager ;;
        2) create_os ;;
        3) boot_vm ;;
        4) sync_github ;;
        5) clear; exit ;;
    esac
}

# --- VECTRAS STYLE: ROM MANAGER ---
rom_manager() {
    sub=$(dialog --title "ROM Manager" --menu "Aksi:" 12 45 3 \
    "A" "Download ISO (Alpine/Debian)" \
    "B" "List Local ISO" 2>&1 >/dev/tty)

    if [ "$sub" == "A" ]; then
        url=$(dialog --inputbox "Masukkan Link Direct Download ISO:" 8 50 2>&1 >/dev/tty)
        name=$(dialog --inputbox "Simpan sebagai (contoh: debian.iso):" 8 50 2>&1 >/dev/tty)
        clear
        curl -L "$url" -o "$ISO_DIR/$name"
        dialog --msgbox "Download Selesai!" 6 30
    elif [ "$sub" == "B" ]; then
        list=$(ls "$ISO_DIR")
        dialog --title "Daftar ISO" --msgbox "$list" 15 50
    fi
    main_menu
}

# --- LIMBO STYLE: CREATE OS ---
create_os() {
    NAME=$(dialog --inputbox "Nama VM (tanpa spasi):" 8 40 2>&1 >/dev/tty)
    RAM=$(dialog --inputbox "Jumlah RAM (MB):" 8 40 "512" 2>&1 >/dev/tty)
    CPU=$(dialog --inputbox "CPU Cores:" 8 40 "1" 2>&1 >/dev/tty)
    PARAMS=$(dialog --inputbox "Custom QEMU Params (Limbo Style):" 10 50 "-vga virtio" 2>&1 >/dev/tty)
    
    # Save Config
    echo "RAM=$RAM" > "$CONF_DIR/$NAME.conf"
    echo "CPU=$CPU" >> "$CONF_DIR/$NAME.conf"
    echo "PARAMS='$PARAMS'" >> "$CONF_DIR/$NAME.conf"
    
    # Create Disk
    SIZE=$(dialog --inputbox "Ukuran Disk (contoh: 5G):" 8 40 2>&1 >/dev/tty)
    qemu-img create -f qcow2 "$VM_DIR/$NAME.qcow2" "$SIZE"
    
    dialog --msgbox "Konfigurasi VM $NAME Disimpan!" 6 40
    main_menu
}

# --- BOOT ENGINE ---
boot_vm() {
    VM_FILE=$(ls "$VM_DIR" | sed 's/\.qcow2//')
    SELECTED=$(dialog --menu "Pilih VM untuk Boot:" 15 45 10 $(for f in $VM_FILE; do echo "$f" "VM"; done) 2>&1 >/dev/tty)
    
    if [ ! -z "$SELECTED" ]; then
        source "$CONF_DIR/$SELECTED.conf"
        clear
        echo "Starting $SELECTED with INDVM Engine..."
        # Eksekusi QEMU dengan parameter yang sudah diinput tadi
        qemu-system-x86_64 \
            -m $RAM \
            -smp $CPU \
            -drive file="$VM_DIR/$SELECTED.qcow2",format=qcow2 \
            $PARAMS \
            -nographic
    fi
    main_menu
}

main_menu
