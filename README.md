# Quickmap — Fast Nmap Wrapper

A small Bash wrapper around `nmap` to speed up common reconnaissance workflows.

---

## Table of contents
- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
- [How it works (short)](#how-it-works-short)
- [Flags & internals](#flags--internals)
- [Examples](#examples)
- [Output files](#output-files)
- [Troubleshooting](#troubleshooting)

---

## Features
- Quick TCP discovery (full-port discovery by default) and focused follow-up scanning.
- Fast UDP discovery mode using nmap's recommended faster UDP flags (`-sUV -T4 -F --version-intensity 0`).
- Robust parsing of discovery output to build a port list for the second-pass scan.
- Clean output filenames including target and scan mode.
- Simple argument validation and friendly usage messaging.

---

## Requirements
- `bash` (POSIX-style shell)
- `nmap` (tested with recent versions)
- Standard GNU utilities: `awk`, `sed`, `tr`, `grep`
- Optional: root privileges for some scan types (see note below)

---

## Installation
1. Save the script to `quickmap.sh` (or a name you prefer).
2. Make it executable:

```bash
chmod +x quickmap.sh
```

3. (Optional) Move to a directory in your `$PATH`:

```bash
sudo mv quickmap.sh /usr/local/bin/quickmap
```

---

## Usage
```bash
# TCP (default)
./quickmap.sh <target>

# UDP (fast discovery recommended by nmap)
./quickmap.sh -udp <target>
# aliases:
./quickmap.sh -u <target>
./quickmap.sh --udp <target>
```

If moved to path:
```bash
quickmap 192.0.2.10
quickmap -u example.com
```

---

## How it works (short)
1. Parse CLI arguments. Default mode is **tcp**; `-udp` / `-u` / `--udp` switches to UDP mode.  
2. Run a discovery nmap scan to find **open** ports:
   - TCP mode: full-port discovery (`-p-`) with grepable output for parsing.
   - UDP mode: `-sUV -T4 -F --version-intensity 0 -Pn --open -oG -` (fast top-100 UDP discovery).
3. Parse discovery output to extract numeric port IDs.
4. Run a focused nmap detail scan against discovered ports:
   - TCP detail: `-sV -sC -T4 -Pn`
   - UDP detail: `-sU -sV -sC --version-intensity 0 -T4 -Pn`
5. Save readable output to `nmap_<target>_<mode>.txt` in the current directory.

---

## Flags & internals (explanations)

### Discovery flags (TCP)
- `-sT` : TCP connect scan (works without root).
- `-p-` : scan all TCP ports (1–65535).
- `-T4` : faster timing.
- `-Pn` : skip host discovery (treat host as up).
- `--open` : show only open ports.
- `-oG -` : grepable output to stdout for parsing.

### Discovery flags (UDP — fast)
- `-sUV` : combined UDP + version probes (recommended to speed top-port UDP discovery).
- `-T4` : faster timing.
- `-F` : fast scan (top 100 ports) — much faster than `-p-`.
- `--version-intensity 0` : minimal version probe intensity (faster).
- `-Pn --open -oG -` : consistent parsing intent as TCP.

### Detail scans
- TCP: `-sV -sC -T4 -Pn` — service/version detection + default scripts.
- UDP: `-sU -sV -sC --version-intensity 0 -T4 -Pn` — UDP scan + reduced-intensity version detection.

---

## Examples

**1) Full TCP discovery + details (default)**
```bash
./quickmap.sh 10.0.0.5
# Output: ./nmap_10.0.0.5_tcp.txt
```

**2) Fast UDP discovery + focused UDP detail scan**
```bash
./quickmap.sh -udp 10.0.0.5
# Discovery uses: -sUV -T4 -F --version-intensity 0
# Detail uses:    -sU -sV -sC --version-intensity 0 -T4 -Pn
# Output: ./nmap_10.0.0.5_udp.txt
```

**3) Filenames**
- Safely sanitized, e.g. `nmap_example.com_udp.txt` or `nmap_192.0.2.10_tcp.txt`.

---

## Output files
Files are written to the current working directory and named:

```
nmap_<target>_<mode>.txt
```

The output is the human-readable `nmap -oN` output.

---

## Troubleshooting
- `nmap: command not found` — install nmap (`sudo apt install nmap` / macOS: `brew install nmap`).
- No ports found but host is reachable — try removing `-Pn` or test with a known open port; check firewall/IDS.
- Parsing fails — ensure `awk`, `sed`, `tr`, `grep` exist (standard on GNU/Linux/macOS).

---

*Note:* some scan types and more accurate TCP techniques (e.g., `-sS`) require root. The script defaults to non-root friendly flags so it can be used without elevated privileges unless you intentionally change it.

