#!/bin/bash
#
# time_fixer.sh - bootstrap the system clock when the hardware/CMOS clock is unreliable.
#
# Strategy:
#   1. Grab the current time from a public site over plain HTTP (the Date: header).
#      HTTP is used on purpose: if the clock is wildly wrong, HTTPS/TLS would fail
#      certificate validation ("not yet valid" / "expired"), so we cannot rely on it
#      to bootstrap the time. The HTTP Date header is in GMT and is good to ~1 second.
#   2. Step the system clock to that (rough) time.
#   3. Now that the clock is sane, sync precisely against NTP.
#   4. Write the result back to the hardware clock (best effort).
#
# Run as root (this is how the systemd unit invokes it). For manual testing: sudo ./time_fixer.sh

set -u

LOG_TAG="time_fixer"
HTTP_URLS=("http://google.com" "http://cloudflare.com" "http://example.com")
NTP_SERVER="pool.ntp.org"

log() {
  echo "$@"
  logger -t "$LOG_TAG" "$@" 2>/dev/null || true
}

# Fetch the current time from a public site's HTTP Date: header (GMT).
get_http_time() {
  local url http_date
  for url in "${HTTP_URLS[@]}"; do
    http_date=$(curl -sI --max-time 10 "$url" 2>/dev/null \
                  | grep -i '^date:' | head -n1 | cut -d' ' -f2- | tr -d '\r')
    if [ -n "$http_date" ]; then
      printf '%s' "$http_date"
      return 0
    fi
  done
  return 1
}

log "Starting time fix. Current system time: $(date)"

# 1 + 2: HTTP bootstrap (no TLS, so a wildly-off clock can't break it)
http_time=$(get_http_time)
if [ -n "$http_time" ]; then
  if date -s "$http_time" >/dev/null 2>&1; then
    log "Clock stepped from HTTP Date header to: $(date)"
  else
    log "Failed to parse/set time from HTTP Date header: '$http_time'"
  fi
else
  log "Could not obtain time over HTTP from any source; continuing to NTP anyway."
fi

# 3: precise NTP sync (now that the clock is roughly correct)
if command -v ntpdate >/dev/null 2>&1; then
  if ntpdate -b -u "$NTP_SERVER" >/dev/null 2>&1; then
    log "NTP sync succeeded against $NTP_SERVER: $(date)"
  else
    log "NTP sync against $NTP_SERVER failed; keeping HTTP-derived time."
  fi
else
  log "ntpdate not found; skipping NTP sync."
fi

# 4: persist to hardware clock (CMOS may be flaky, so this is best effort)
if command -v hwclock >/dev/null 2>&1; then
  if hwclock --systohc >/dev/null 2>&1; then
    log "Hardware clock updated from system time."
  else
    log "Could not write hardware clock (may be expected on flaky CMOS)."
  fi
fi

log "Time fix complete. Final system time: $(date)"
