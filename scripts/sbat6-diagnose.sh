#!/bin/sh
# Read-only SBAT6/KnOS diagnostic. Prints sanitized state to stdout only.
# POSIX sh / BusyBox compatible; never reads credential file contents.

PATH=/sbin:/bin:/usr/sbin:/usr/bin
export PATH

section() { printf '\n== %s ==\n' "$1"; }
value() { printf '%s: %s\n' "$1" "${2:-unavailable}"; }
have() { command -v "$1" >/dev/null 2>&1; }

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
if have ss; then value ssh-port-22-listeners "$(ss -lnt 2>/dev/null | awk 'NR>1 && $4 ~ /:22$/ {n++} END {print n+0}')"
elif have netstat; then value ssh-port-22-listeners "$(netstat -lnt 2>/dev/null | awk 'NR>2 && $4 ~ /:22$/ {n++} END {print n+0}')"
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
    for cmd in getrole dump_topology bh_conn_status bh_conn_type; do
        out=$(mapd_cli /tmp/mapd_ctrl "$cmd" 2>/dev/null)
        case "$cmd" in
            getrole)
                case "$out" in *Controller*|*controller*) value mapd-role Controller;; *Agent*|*agent*) value mapd-role Agent;; *) value mapd-role unknown;; esac ;;
            dump_topology)
                distances=$(printf '%s\n' "$out" | awk -F '[:,=[:space:]]+' 'tolower($0) ~ /distance/ {for (i=1; i<NF; i++) if (tolower($i) == "distance" && $(i+1) ~ /^[0-9]+$/) print $(i+1)}' | tr '\n' ' ')
                value topology-distances "${distances:-unavailable}" ;;
            bh_conn_status|bh_conn_type)
                numeric=$(printf '%s\n' "$out" | tr -cd '0123456789\n' | head -n 1)
                value "mapd-$cmd" "${numeric:-unavailable}" ;;
        esac
    done
else value mapd-cli unavailable; fi

section 'APCLI state (names only; no SSID/BSSID)'
for ifn in apcli0 apclii0 apclix0; do
    if [ -d "/sys/class/net/$ifn" ]; then
        oper=$(cat "/sys/class/net/$ifn/operstate" 2>/dev/null)
        carrier=$(cat "/sys/class/net/$ifn/carrier" 2>/dev/null)
        value "$ifn" "present operstate=${oper:-unknown} carrier=${carrier:-unknown}"
    else value "$ifn" absent; fi
done
printf '\nNote: this report is a point-in-time read-only diagnostic; absence of management connectivity does not by itself prove EasyMesh failure.\n'
