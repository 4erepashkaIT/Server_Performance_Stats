#!/bin/bash

print_header() {
    echo
    echo "===== $1 ====="
}

cpu_usage() {
    print_header "CPU usage"
    vmstat 1 2 | tail -n 1 | awk '{print "Total CPU usage: " 100 - $15 "%"}'
}

memory_usage() {
    print_header "Memory usage"
    free -m | awk '/^Mem:/ {
        used = $2 - $7
        printf "Memory: Used %d MB, Free %d MB, Total %d MB (%.1f%% used)\n", used, $7, $2, used/$2*100
    }'
}

total_disk_usage() {
    print_header "Total disk usage"
    df -h --total -x tmpfs -x devtmpfs -x squashfs | tail -n 1
}

top_5_processes_cpu() {
    print_header "Top 5 processes by CPU usage"
    ps -eo pid,user,comm,%cpu,%mem --sort=-%cpu | head -n 6
}

top_5_processes_memory() {
    print_header "Top 5 processes by memory usage"
    ps -eo pid,user,comm,%cpu,%mem --sort=-%mem | head -n 6
}

#Stretch goals
os_ver() {
    print_header "OS Version"
    grep '^PRETTY_NAME=' /etc/os-release | cut -d= -f2 | tr -d '"'
}

show_up_time() {
    print_header "Uptime"
    uptime -p
}

main() {
    cpu_usage
    memory_usage
    total_disk_usage
    top_5_processes_cpu
    top_5_processes_memory
    os_ver
    show_up_time
}