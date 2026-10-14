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
    df -h --total -x tmpfs -x devtmpfs -x squashfs | awk '/^total/ {printf "Used %s (%s), Free %s, Total %s\n", $3, $5, $4, $2}'
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

load_average() {
    print_header "Load average"
    local cores
    cores=$(nproc)
    awk -v cores="$cores" '{
        printf "1 min: %s, 5 min: %s, 15 min: %s (CPU cores: %d)\n", $1, $2, $3, cores
        printf "Load per core (1 min): %.2f\n", $1 / cores
    }' /proc/loadavg
}

logged_in_users() {
    print_header "Logged in users"
    local sessions users
    sessions=$(who | wc -l)
    users=$(who | awk '{print $1}' | sort -u | wc -l)

    echo "Active sessions: $sessions, unique users: $users"

    if [ "$sessions" -eq 0 ]; then
        echo "No users logged in"
    else
        who
    fi
}

is_root() {
    [ "$EUID" -eq 0 ]
}

failed_logins() {
    print_header "Failed login attempts"
    local count
    count=$(journalctl -u ssh -u sshd --since "24 hours ago" --no-pager |
        grep -cE "Connection closed by (authenticating|invalid) user")
    echo "Failed SSH login attempts (last 24h): $count"
}

main() {
    cpu_usage
    load_average
    memory_usage
    total_disk_usage
    top_5_processes_cpu
    top_5_processes_memory
    os_ver
    show_up_time
    logged_in_users

    if is_root; then
        failed_logins
    else
        print_header "Failed login attempts"
        echo "Run with sudo to see this section"
    fi
}

main