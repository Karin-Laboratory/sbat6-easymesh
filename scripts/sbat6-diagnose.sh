#!/bin/sh
# Read-only SBAT6/KnOS diagnostic. Prints sanitized state to stdout only.
# POSIX sh / BusyBox compatible; never reads credential file contents.

PATH=/sbin:/bin:/usr/sbin:/usr/bin
export PATH

section() { printf '\n== %s ==\n' "$1"; }
value() { printf '%s: %s\n' "$1" "${2:-unavailable}"; }
have() { command -v "$1" >/dev/null 2>&1; }

parse_role() {
    printf '%s\n' "$1" | awk '
        { s=tolower($0)
          if (s ~ /controller/) { print "Controller"; exit }
          if (s ~ /agent/) { print "Agent"; exit }
          if (s ~ /device role|dev_role/) {
              for (i=1; i<=NF; i++) if ($i ~ /^[0-9][0-9]?$/) {
                  n=$i+0
                  if (n==1) { print "Controller"; exit }
                  if (n==2) { print "Agent"; exit }
              }
          }
          if (NF==1 && $1 ~ /^[0-9][0-9]?$/) {
              n=$1+0
              if (n==1) { print "Controller"; exit }
              if (n==2) { print "Agent"; exit }
          }
        }
        END { if (NR==0) print "unknown" }
    ' | sed -n '1p'
}

parse_distances() {
    printf '%s\n' "$1" | awk '{s=tolower($0); if (s ~ /distance/) {sub(/^.*distance/,"",s); if (match(s,/[0-9]+/)) print substr(s,RSTART,RLENGTH)}}' | tr '\n' ' '
}

parse_medium() {
    lower=$(printf '%s\n' "$1" | tr '[:upper:]' '[:lower:]')
    case "$lower" in *6g*|*6\ ghz*) printf '6G\n';; *5g*|*5\ ghz*) printf '5G\n';; *2.4g*|*2.4\ ghz*) printf '2.4G\n';; *) printf 'unknown\n';; esac
}

parse_number() { printf '%s\n' "$1" | tr -cd '0123456789\n' | sed -n '1p'; }

fixture_section() {
    awk -v section="$2" '$0=="[" section "]" {on=1; next} /^\[[^]]+\]$/ {on=0} on {print}' "$1"
}

# Parser self-check uses only a sanitized, report-transcribed fixture. It never
# inspects or invokes a router and can be run from this repository's tests.
if [ "${1:-}" = "--self-test" ]; then
    fixture=${2:-}
    [ -r "$fixture" ] || { printf 'fixture unavailable\n'; exit 2; }
    role=$(parse_role "$(fixture_section "$fixture" getrole-agent)")
    controller_role=$(parse_role "$(fixture_section "$fixture" getrole-controller)")
    distances=$(parse_distances "$(fixture_section "$fixture" dump_topology)")
    medium=$(parse_medium "$(fixture_section "$fixture" dump_topology)")
    status=$(parse_number "$(fixture_section "$fixture" bh_conn_status)")
    bh_type=$(parse_number "$(fixture_section "$fixture" bh_conn_type)")
    printf 'agent_role=%s controller_role=%s distances=%s medium=%s bh_status=%s bh_type=%s\n' "$role" "$controller_role" "$distances" "$medium" "${status:-unknown}" "${bh_type:-unknown}"
    [ "$role" = Agent ] && [ "$controller_role" = Controller ] && [ "$distances" = "1 " ] && [ "$medium" = 6G ] && [ "$status" = 1 ] && [ "$bh_type" = 4 ]
    exit $?
fi

# Replace IPv4 and MAC-like strings before displaying command output.
sanitize() {
    sed -e 's/\([0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\)/<IP>/g' \
        -e 's/\([[:xdigit:]][[:xdigit:]]:[[:xdigit:]][[:xdigit:]]:[[:xdigit:]][[:xdigit:]]:[[:xdigit:]][[:xdigit:]]:[[:xdigit:]][[:xdigit:]]:[[:xdigit:]][[:xdigit:]]\)/<MAC>/g' \
        -e 's/\([[:xdigit:]][[:xdigit:]]-\)\{5\}[[:xdigit:]][[:xdigit:]]/<MAC>/g' \
        -e 's/\([Ss][Ss][Ii][Dd][^=:]*[=:][[:space:]]*\).*/\1<REDACTED>/g' \
        -e 's/\([Bb][Ss][Ss][Ii][Dd][^=:]*[=:][[:space:]]*\).*/\1<REDACTED>/g'
}

section 'Device'
if have hostname; then value hostname "$(hostname 2>/dev/null)"; else value hostname unavailable; fi
if [ -r /proc/sys/kernel/hostname ]; then value kernel-hostname "$(cat /proc/sys/kernel/hostname 2>/dev/null)"; fi
if have uname; then value kernel "$(uname -sr 2>/dev/null)"; fi
if [ -r /etc/os-release ]; then
    os_id=$(sed -n 's/^ID=//p' /etc/os-release | head -n 1 | tr -d '\"')
    os_ver=$(sed -n 's/^VERSION_ID=//p' /etc/os-release | head -n 1 | tr -d '\"')
    value os-id "$os_id"; value os-version "$os_ver"
elif [ -r /etc/openwrt_release ]; then
    os_id=$(sed -n 's/^DISTRIB_ID=//p' /etc/openwrt_release | head -n 1 | tr -d "'\"")
    os_ver=$(sed -n 's/^DISTRIB_RELEASE=//p' /etc/openwrt_release | head -n 1 | tr -d "'\"")
    value firmware-id "$os_id"; value firmware-version "$os_ver"
fi
if have uptime; then value uptime "$(uptime 2>/dev/null | sanitize)"; fi

section 'Management interfaces (addresses redacted)'
if have ip; then ip -o addr show 2>/dev/null | awk '{print $2, $3, "<IP-redacted>"}' | head -n 40
elif have ifconfig; then ifconfig -a 2>/dev/null | awk '/^[^[:space:]]/ {print $1, "<address-redacted>"}' | head -n 40
else value interfaces unavailable; fi

section 'SSH and procd'
if have ps; then
    ps w 2>/dev/null | awk 'NR>1 {s=tolower($0); if (s ~ /dropbear/) d++; if (s ~ /sshd/) o++; if (s ~ /procd/) p++} END {printf "dropbear-processes: %d\nopenssh-processes: %d\nprocd-processes: %d\n", d, o, p}'
fi
if have ss; then
    ports=$(ss -lntp 2>/dev/null | awk 'NR>1 && tolower($0) ~ /dropbear|sshd/ {local=$4; sub(/^.*:/,"",local); gsub(/[^0-9]/,"",local); if (local!="") print local}' | sort -u | tr '\n' ' ')
    if [ -n "$ports" ]; then value ssh-listener-ports "$ports"; else value ssh-listener-ports unknown; fi
elif have netstat; then
    ports=$(netstat -lntp 2>/dev/null | awk 'tolower($0) ~ /dropbear|sshd/ {local=$4; sub(/^.*:/,"",local); gsub(/[^0-9]/,"",local); if (local!="") print local}' | sort -u | tr '\n' ' ')
    if [ -n "$ports" ]; then value ssh-listener-ports "$ports"; else value ssh-listener-ports unknown; fi
else value ssh-listener unavailable; fi
if [ -x /etc/init.d/dropbear ]; then /etc/init.d/dropbear status 2>&1 | sanitize
else value dropbear-init unavailable; fi
if have ubus; then
    service=$(ubus call service list '{"name":"dropbear"}' 2>/dev/null)
    if [ -n "$service" ]; then value procd-dropbear-service-record present; else value procd-dropbear-service-record unavailable; fi
fi
if have uci; then value dropbear-uci-enabled "$(uci -q get dropbear.@dropbear[0].enable 2>/dev/null || printf unknown)"; fi

section 'Firewall (sanitized runtime summary; no rules dumped)'
if have iptables; then
    value iptables-input-policy "$(iptables -S INPUT 2>/dev/null | awk '$1=="-P" {print $3; exit}')"
    value iptables-input-rule-count "$(iptables -S INPUT 2>/dev/null | awk 'END {print NR+0}')"
else value iptables unavailable; fi
if have nft; then value nft-ruleset-present "$(nft list ruleset 2>/dev/null | awk 'END {if (NR > 0) print "yes"; else print "no"}')"; fi
if have uci; then
    # Count firewall sections only; never emit option values or network identifiers.
    value uci-firewall-section-count "$(uci -q show firewall 2>/dev/null | awk -F= '/^firewall\.[^.=]+=/ {n++} END {print n+0}')"
    value uci-firewall-include-count "$(uci -q show firewall 2>/dev/null | awk -F= '/\.type=.include/ {n++} END {print n+0}')"
fi

section 'Credential path metadata (contents are never read)'
for p in /etc/passwd /etc/shadow; do
    if [ -L "$p" ] && have readlink; then value "$p-symlink-target" "$(readlink "$p" 2>/dev/null)"
    elif [ -e "$p" ]; then value "$p" regular-or-overlay-file
    else value "$p" missing; fi
done
if have uci; then value knos-system-mode "$(uci -q get knos.knos.system_mode 2>/dev/null || printf unknown)"; fi

section 'EasyMesh processes and role'
if have ps; then
    ps w 2>/dev/null | awk 'NR>1 {s=tolower($0); if (s ~ /mapd/) m++; if (s ~ /p1905_managerd/) p++; if (s ~ /wapp/) w++} END {printf "mapd-processes: %d\np1905-managerd-processes: %d\nwapp-processes: %d\n", m, p, w}'
fi
if have uci; then
    for key in DeviceRole MapMode; do
        v=$(uci -q get "mapd.mapd_cfg.$key" 2>/dev/null)
        [ -n "$v" ] || v=$(uci -q get "mapd.mapd_user.$key" 2>/dev/null)
        value "mapd-$key" "${v:-unknown}"
    done
fi
if have mapd_cli; then
    for cmd in getrole agent_list dump_topology dump_topology_v1 bh_info bh_conn_status bh_conn_type; do
        out=$(mapd_cli /tmp/mapd_ctrl "$cmd" 2>/dev/null)
        case "$cmd" in
            getrole) value mapd-role "$(parse_role "$out")" ;;
            agent_list) value agent-list-records "$(printf '%s\n' "$out" | awk 'NF {n++} END {print n+0}')" ;;
            dump_topology|dump_topology_v1|bh_info)
                distances=$(parse_distances "$out")
                [ -n "$distances" ] && value topology-distances "$distances"
                medium=$(parse_medium "$out")
                [ "$medium" != unknown ] && value topology-backhaul-medium "$medium"
                status=$(printf '%s\n' "$out" | awk -F '[ :=]+' 'tolower($0) ~ /backhaul connection status|bh_conn_status/ {for (i=1;i<=NF;i++) if ($i ~ /^[0-9]+$/) {print $i; exit}}')
                [ -n "$status" ] && value mapd-bh-status "$status"
                type=$(printf '%s\n' "$out" | awk -F '[ :=]+' 'tolower($0) ~ /backhaul connection type|bh_conn_type/ {for (i=1;i<=NF;i++) if ($i ~ /^[0-9]+$/) {print $i; exit}}')
                [ -n "$type" ] && value mapd-bh-type "$type" ;;
            bh_conn_status|bh_conn_type)
                numeric=$(parse_number "$out")
                value "mapd-$cmd" "${numeric:-unavailable}" ;;
        esac
    done
else value mapd-cli unavailable; fi

section 'APCLI state (names only; no SSID/BSSID)'
for ifn in apcli0 apclii0 apclix0; do
    if [ -d "/sys/class/net/$ifn" ]; then
        oper=$(cat "/sys/class/net/$ifn/operstate" 2>/dev/null)
        carrier=$(cat "/sys/class/net/$ifn/carrier" 2>/dev/null)
        rx=$(cat "/sys/class/net/$ifn/statistics/rx_bytes" 2>/dev/null)
        tx=$(cat "/sys/class/net/$ifn/statistics/tx_bytes" 2>/dev/null)
        value "$ifn" "present operstate=${oper:-unknown} carrier=${carrier:-unknown} rx_bytes=${rx:-unknown} tx_bytes=${tx:-unknown}"
    else value "$ifn" absent; fi
done
printf '\nNote: this report is a point-in-time read-only diagnostic; absence of management connectivity does not by itself prove EasyMesh failure.\n'
