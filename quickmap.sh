#!/bin/bash
# Quickmap - quick Nmap wrapper
# Usage:
#   ./quickmap.sh <target>              # TCP (default)
#   ./quickmap.sh -udp <target>         # UDP (uses nmap-recommended fast flags)
#   ./quickmap.sh -u <target>
#   ./quickmap.sh --udp <target>

set -euo pipefail

if [ "$#" -lt 1 ]; then
  echo "Usage: $0 [-udp|--udp|-u] <target>"
  exit 1
fi

# parse args (support -udp, --udp, -u)
MODE="tcp"
TARGET=""
while (( "$#" )); do
  case "$1" in
    -udp|--udp|-u)
      MODE="udp"
      shift
      ;;
    -*)
      echo "Unknown option: $1"
      echo "Usage: $0 [-udp|--udp|-u] <target>"
      exit 1
      ;;
    *)
      TARGET="$1"
      shift
      ;;
  esac
done

if [ -z "$TARGET" ]; then
  echo "Please provide an IP address or hostname as an argument."
  exit 1
fi

echo "Quickmap"
echo "Target: $TARGET"
echo "Mode: $MODE"

# Build discovery flags based on mode
if [ "$MODE" = "udp" ]; then
  # Use the nmap recommendation you quoted to speed up UDP discovery:
  # -sUV : combined UDP scan + version probes (speeds service detection for UDP)
  # -T4  : faster timing
  # -F   : scan top 100 ports (much faster than -p-)
  # --version-intensity 0 : minimize version probe intensity (faster)
  # We still use --open and -oG - to extract open ports reliably
  DISCOVERY_FLAGS="-sUV -T4 -F --version-intensity 0 -Pn --open -oG -"
  DETAIL_FLAGS="-sU -sV -sC --version-intensity 0 -T4 -Pn"
  MODE_TAG="udp"
else
  # TCP default: full-port discovery, quicker TCP method (can be adjusted)
  DISCOVERY_FLAGS="-sT -p- -T4 -Pn --open -oG -"
  DETAIL_FLAGS="-sV -sC -T4 -Pn"
  MODE_TAG="tcp"
fi

echo "Running discovery: nmap $DISCOVERY_FLAGS $TARGET"
# Run discovery and extract port numbers
ports=$(
  # shellcheck disable=SC2086
  nmap $DISCOVERY_FLAGS "$TARGET" \
    | awk -F'Ports: ' '/Ports:/{print $2}' \
    | tr ',' '\n' \
    | awk -F'/' '{print $1}' \
    | grep -E '^[0-9]+$' \
    | tr '\n' ',' \
    | sed 's/,$//'
)

if [ -z "$ports" ]; then
  echo "No open $MODE ports found on $TARGET."
  exit 2
fi

echo "Open ports: $ports"

directory=$(pwd)
safe_target=$(echo "$TARGET" | tr '/' '_' | tr ':' '_')
outfile="$directory/nmap_${safe_target}_${MODE_TAG}.txt"

echo "Running detailed scan: nmap $DETAIL_FLAGS -p $ports $TARGET -oN $outfile"
# shellcheck disable=SC2086
nmap $DETAIL_FLAGS -p "$ports" "$TARGET" -oN "$outfile"

echo "Done. Output saved to: $outfile"

