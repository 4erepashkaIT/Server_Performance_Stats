# Server Performance Stats

A simple Bash script for checking Linux server performance.

This project is my solution to the [Server Performance Stats](https://roadmap.sh/projects/server-stats) challenge on **roadmap.sh**.

The goal was to build a script that collects basic server performance statistics without installing any additional monitoring tools.

I wrote the script while learning Bash and working with my own Linux VPS. It helped me better understand how Linux manages CPU, memory, disk space, and running processes.

## Project Requirements

The original challenge requires five main metrics:

- **Total CPU usage** — CPU usage percentage.
- **Total memory usage** — used and available RAM, including percentage.
- **Total disk usage** — used and available disk space, including percentage.
- **Top 5 processes by CPU usage** — processes consuming the most CPU.
- **Top 5 processes by memory usage** — processes consuming the most RAM.

I also implemented the optional stretch goals:

- OS version
- System uptime
- Load average (1, 5, and 15 minutes)
- Load per CPU core
- Logged-in users and active sessions
- Failed SSH login attempt monitoring

Original project: https://roadmap.sh/projects/server-stats

## How to Run

Clone the repository and navigate to the project directory.

**1. Make the script executable:**

```bash
chmod +x server-stats.sh
```

**2. Run the script:**

```bash
./server-stats.sh
```

**3. Run with sudo to include SSH login statistics:**

```bash
sudo ./server-stats.sh
```

### Why sudo?

Most performance metrics can be collected without root privileges.

However, the failed SSH login section uses `journalctl` to read SSH service logs. On Ubuntu, access to these logs may be restricted.

The script checks whether it's running as root. Without `sudo`, it simply displays:

```text
===== Failed login attempts =====
Run with sudo to see this section
```

Everything else still works normally.

## Example Output

Example of what the report looks like (values are illustrative):

```text
===== CPU usage =====
Total CPU usage: 2%
I/O wait: 0%

===== Load average =====
1 min: 0.08, 5 min: 0.06, 15 min: 0.03 (CPU cores: 2)
Load per core (1 min): 0.04

===== Memory usage =====
Memory: Used 359 MB, Free 509 MB, Total 868 MB (41.4% used)

===== Total disk usage =====
Used 5.0G (27%), Free 14G, Total 20G

===== Top 5 processes by CPU usage =====
    PID USER     COMMAND         %CPU %MEM
   1234 root     python3          5.2  2.1
    567 root     systemd          1.3  1.0
    890 root     sshd             0.8  0.6
    321 root     cron             0.3  0.2
    654 root     bash             0.1  0.4

===== Top 5 processes by memory usage =====
    PID USER     COMMAND         %CPU %MEM
   1234 root     python3          5.2  2.1
    567 root     systemd          1.3  1.0
    890 root     sshd             0.8  0.6
    654 root     bash             0.1  0.4
    321 root     cron             0.3  0.2

===== OS Version =====
Ubuntu 24.04 LTS

===== Uptime =====
up 3 days, 2 hours, 15 minutes

===== Logged in users =====
Active sessions: 1, unique users: 1
user pts/0 2026-10-14 10:42 ([REDACTED])

===== Failed login attempts =====
Failed SSH login attempts (last 24h): 7
```

## How It Works

A few implementation details worth mentioning.

### CPU Usage

I used `vmstat 1 2` to measure CPU usage.

The first output shows averages since the system started. The second output represents the most recent one-second interval.

The script uses the second measurement and calculates:

```text
CPU usage = 100 - idle% - I/O wait%
```

I/O wait is displayed separately to distinguish time spent waiting for I/O operations from actual CPU activity.

### Memory Usage

Linux uses unused RAM for caching, so looking only at the `free` column can be misleading.

Instead, I used the `available` column from the `free` command.

```text
Used = Total - Available
Usage (%) = Used / Total * 100
```

This gives a better picture of how much memory the system can still use without significant swapping.

In the report, "Free" refers to available memory, not just completely unused RAM.

### Disk Usage

The script uses `df` with the `--total` option to summarize disk usage.

It excludes:

- `tmpfs` — temporary memory-backed filesystems.
- `devtmpfs` — virtual device filesystems.
- `squashfs` — read-only compressed filesystems often used by Snap packages.

This keeps the report focused on actual storage filesystems rather than temporary or virtual ones.

### Top Processes

I used `ps` to list running processes, sorted by CPU or memory usage.

The script displays the top five processes along with their PID, user, command name, CPU percentage, and memory percentage.

### Failed SSH Login Attempts

This was one of the optional challenges I wanted to try.

The script reads SSH logs from the last 24 hours using `journalctl` and searches for:

```text
Connection closed by (authenticating|invalid) user
```

My server uses SSH key-based authentication, so I chose a pattern relevant to that setup.

It's worth noting that this isn't a complete failed-login detector. Some connections may close before authentication finishes, and other authentication failures won't necessarily match this pattern.

## Limitations

- Tested on **Ubuntu 24.04 LTS**.
- Designed for Linux, not macOS.
- Uses GNU/Linux-specific commands and options.
- The SSH login pattern is tailored to a server using SSH key-based authentication.
- SSH log monitoring requires access to systemd journal entries.
- CPU percentages from `ps` are averages over the lifetime of each process, not instantaneous measurements.
- The disk total includes the filesystems reported by `df` after filtering, so it may not represent unique physical disk capacity.

## What I Learned

This project gave me hands-on practice with:

- Bash scripting and functions
- Working with `awk`, `grep`, `cut`, `head`, and other command-line tools
- Understanding Linux CPU, memory, and disk statistics
- Inspecting running processes
- Reading system logs with `journalctl`
- Using Git and GitHub to develop locally and deploy updates to a Linux server

It's a small project, but it helped me connect a lot of Linux concepts with something practical.

## Environment

- **OS:** Ubuntu 24.04 LTS
- **Shell:** Bash
- **Tools:** `vmstat`, `free`, `df`, `ps`, `awk`, `journalctl`, and standard Linux utilities

No additional monitoring services required.

---

Built as part of the [roadmap.sh DevOps projects](https://roadmap.sh/projects/server-stats).