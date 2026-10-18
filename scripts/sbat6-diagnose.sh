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
          if (s ~ /controller/) { print "Controller"; found=1; exit }
          if (s ~ /agent/) { print "Agent"; found=1; exit }
          if (s ~ /device role|dev_role/) {
              for (i=1; i<=NF; i++) if ($i ~ /^[0-9][0-9]?$/) {
                  n=$i+0
                  if (n==1) { print "Controller"; found=1; exit }
                  if (n==2) { print "Agent"; found=1; exit }
              }
          }
          if (NF==1 && $1 ~ /^[0-9][0-9]?$/) {
              n=$1+0
              if (n==1) { print "Controller"; found=1; exit }
              if (n==2) { print "Agent"; found=1; exit }
          }
        }
        END { if (!found) print "unknown" }
    ' | sed -n '1p'
}

parse_distances() {
    printf '%s\n' "$1" | awk 'tolower($0) ~ /distance/ {s=$0; sub(/^.*[Dd]istance[^0-9]*/,"",s); if (s ~ /^[0-9]+/) {match(s,/^[0-9]+/); print substr(s,RSTART,RLENGTH)}}' | tr '\n' ' ' | sed 's/[[:space:]]*$//'
}

parse_medium() {
    medium=$(printf '%s\n' "$1" | awk 'tolower($0) ~ /backhaul medium/ {s=tolower($0); sub(/^.*backhaul medium type[[:space:]]*[:=]?[[:space:]]*/,"",s); print s; exit}')
    case "$medium" in *6g*|*6\ ghz*) printf '6G\n';; *5g*|*5\ ghz*) printf '5G\n';; *2.4g*|*2.4\ ghz*) printf '2.4G\n';; *) printf 'unknown\n';; esac
}

parse_labeled_number() {
    printf '%s\n' "$2" | awk -v label="$1" '
        tolower($0) ~ tolower(label) {s=tolower($0); sub(/^.*(bh_conn_status|backhaul connection status|bh_conn_type|backhaul connection type|type)[[:space:]]*[:=]?[[:space:]]*/,"",s); if (s ~ /^[0-9]+([[:space:]]|$)/) {match(s,/^[0-9]+/); print substr(s,RSTART,RLENGTH); found=1; exit}}
        NF {nonempty++; only=$0}
        END {if (!found && nonempty==1 && only ~ /^[[:space:]]*[0-9]+[[:space:]]*$/) {gsub(/[[:space:]]/,"",only); print only}}
    '
}

parse_mld_bands() {
    printf '%s\n' "$1" | awk 'tolower($0) ~ /band_idx/ {s=$0; sub(/^.*band_idx[^0-9]*/,"",s); if (s ~ /^[0-9]+/) {match(s,/^[0-9]+/); print substr(s,RSTART,RLENGTH)}}' | sort -u | tr '\n' ' ' | sed 's/[[:space:]]*$//'
}

parse_mld_refs() {
    printf '%s\n' "$1" | awk 'tolower($0) ~ /ref_cnt/ {s=$0; sub(/^.*ref_cnt[^0-9]*/,"",s); if (s ~ /^[0-9]+/) {match(s,/^[0-9]+/); print substr(s,RSTART,RLENGTH)}}' | sort -u | tr '\n' ' ' | sed 's/[[:space:]]*$//'
}

fixture_section() {
    awk -v section="$2" '$0=="[" section "]" {on=1; next} /^\[[^]]+\]$/ {on=0} on {print}' "$1"
}

# Parser self-check uses only a sanitized, report-transcribed fixture. It never
# inspects or invokes a router and can be run from this repository's tests.
if [ "${1:-}" = "--self-test" ]; then
    fixture=${2:-}
    [ -r "$fixture" ] || { printf 'fixture unavailable\n'; exit 2; }
    role=$(parse_role "$(fixture_section "$fixture" getrole-agent)")
    role_text=$(parse_role "$(fixture_section "$fixture" getrole-text)")
    controller_role=$(parse_role "$(fixture_section "$fixture" getrole-controller)")
    distances=$(parse_distances "$(fixture_section "$fixture" dump_topology)")
    medium=$(parse_medium "$(fixture_section "$fixture" dump_topology)")
    false_medium=$(parse_medium "$(fixture_section "$fixture" topology-with-unrelated-6g)")
    status=$(parse_labeled_number 'bh_conn_status|backhaul connection status' "$(fixture_section "$fixture" bh_conn_status)")
    bh_type=$(parse_labeled_number 'bh_conn_type|backhaul connection type|type[[:space:]]+[0-9]+' "$(fixture_section "$fixture" bh_conn_type)")
    invalid_status=$(parse_labeled_number 'bh_conn_status|backhaul connection status' "$(fixture_section "$fixture" bh-invalid)")
    empty_cli=$(fixture_section "$fixture" missing-command)
    [ -n "$empty_cli" ] || empty_cli=unavailable
    bands=$(parse_mld_bands "$(fixture_section "$fixture" mlo)")
    refs=$(parse_mld_refs "$(fixture_section "$fixture" mlo)")
    empty_role=$(parse_role "$(fixture_section "$fixture" empty)")
    printf 'agent_role=%s agent_text_role=%s controller_role=%s distances=%s medium=%s unrelated_medium=%s bh_status=%s bh_type=%s invalid_bh_status=%s empty_cli=%s mlo_bands=%s mlo_ref_counts=%s empty_role=%s\n' "$role" "$role_text" "$controller_role" "${distances:-unknown}" "$medium" "$false_medium" "${status:-unknown}" "${bh_type:-unknown}" "${invalid_status:-unknown}" "$empty_cli" "${bands:-unknown}" "${refs:-unknown}" "$empty_role"
    [ "$role" = Agent ] && [ "$role_text" = Agent ] && [ "$controller_role" = Controller ] && [ "$distances" = '0 1 2' ] && [ "$medium" = 6G ] && [ "$false_medium" = unknown ] && [ "$status" = 1 ] && [ "$bh_type" = 4 ] && [ -z "$invalid_status" ] && [ "$empty_cli" = unavailable ] && [ "$bands" = '1 2' ] && [ "$refs" = 2 ] && [ "$empty_role" = unknown ]
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
if have hostname; then value hostname set-redacted; else value hostname unavailable; fi
if [ -r /proc/sys/kernel/hostname ]; then value kernel-hostname set-redacted; fi
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
if have ip; then ip -o addr show 2>/dev/null | awk 'END {printf "address-records: %d (addresses redacted)\n", NR}'
elif have ifconfig; then ifconfig -a 2>/dev/null | awk '/^[^[:space:]]/ {n++} END {printf "interfaces: %d (addresses redacted)\n", n+0}'
else value interfaces unavailable; fi

section 'SSH and procd'
if have ps; then
    ps w 2>/dev/null | awk 'NR>1 {s=tolower($0); if (s ~ /dropbear/) d++; if (s ~ /sshd/) o++; if (s ~ /procd/) p++} END {printf "dropbear-processes: %d\nopenssh-processes: %d\nprocd-processes: %d\n", d, o, p}'
fi
if have ss; then
    ports=$(ss -lntp 2>/dev/null | awk 'NR>1 && tolower($0) ~ /dropbear|sshd/ {endpoint=$4; sub(/^.*:/,"",endpoint); gsub(/[^0-9]/,"",endpoint); if (endpoint!="") print endpoint}' | sort -u | tr '\n' ' ')
    if [ -n "$ports" ]; then value ssh-listener-ports "$ports"; value ssh-listener-state listening-correlated
    else value ssh-listener-ports unknown; value ssh-listener-state unknown-process-owner-not-visible-or-not-listening; fi
elif have netstat; then
    ports=$(netstat -lntp 2>/dev/null | awk 'tolower($0) ~ /dropbear|sshd/ {endpoint=$4; sub(/^.*:/,"",endpoint); gsub(/[^0-9]/,"",endpoint); if (endpoint!="") print endpoint}' | sort -u | tr '\n' ' ')
    if [ -n "$ports" ]; then value ssh-listener-ports "$ports"; value ssh-listener-state listening-correlated
    else value ssh-listener-ports unknown; value ssh-listener-state unknown-process-owner-not-visible-or-not-listening; fi
else value ssh-listener-ports unavailable; value ssh-listener-state unavailable; fi
if [ -x /etc/init.d/dropbear ]; then /etc/init.d/dropbear status 2>&1 | sanitize
else value dropbear-init unavailable; fi
if have ubus; then
    service=$(ubus call service list '{"name":"dropbear"}' 2>/dev/null)
    if [ -n "$service" ]; then value procd-dropbear-service-record present; else value procd-dropbear-service-record unavailable; fi
fi
if have uci; then value dropbear-uci-enabled "$(uci -q get dropbear.@dropbear[0].enable 2>/dev/null || printf unknown)"; fi

section 'Firewall (sanitized runtime summary; no rules dumped)'
if have iptables; then
    input_rules=$(iptables -S INPUT 2>/dev/null)
    if [ -n "$input_rules" ]; then
        value iptables-input-policy "$(printf '%s\n' "$input_rules" | awk '$1=="-P" {print $3; exit}')"
        value iptables-input-rule-count "$(printf '%s\n' "$input_rules" | awk '$1=="-A" && $2=="INPUT" {n++} END {print n+0}')"
    else value iptables-input-query unavailable; fi
else value iptables unavailable; fi
if have nft; then
    if nft list ruleset >/dev/null 2>&1; then value nft-ruleset-query success; else value nft-ruleset-query unavailable; fi
fi
if have uci; then
    # Count firewall sections only; never emit option values or network identifiers.
    firewall_uci=$(uci -q show firewall 2>/dev/null)
    if [ -n "$firewall_uci" ]; then
        value uci-firewall-section-count "$(printf '%s\n' "$firewall_uci" | awk -F= '/^firewall\.[^.=]+=/ {n++} END {print n+0}')"
        value uci-firewall-include-count "$(printf '%s\n' "$firewall_uci" | awk -F= '/\.type=.include/ {n++} END {print n+0}')"
    else value uci-firewall-query unavailable; fi
fi

section 'Credential path metadata (contents are never read)'
for p in /etc/passwd /etc/shadow; do
    if [ -L "$p" ]; then value "$p" symlink-target-redacted
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
    value knos-easymesh-enabled "$(uci -q get knos.network.easymesh 2>/dev/null || printf unknown)"
    value knos-mesh-flag "$(uci -q get knos.flags.mesh 2>/dev/null || printf unknown)"
fi
if have mapd_cli; then
    for cmd in getrole agent_list dump_topology dump_topology_v1 bh_info bh_conn_status bh_conn_type; do
        out=$(mapd_cli /tmp/mapd_ctrl "$cmd" 2>/dev/null)
        case "$cmd" in
            getrole) if [ -n "$out" ]; then value mapd-role "$(parse_role "$out")"; else value mapd-role unavailable; fi ;;
            agent_list) if [ -n "$out" ]; then value agent-list-response present; else value agent-list-response unavailable; fi ;;
            dump_topology|dump_topology_v1|bh_info)
                if [ -n "$out" ]; then
                    distances=$(parse_distances "$out")
                    value topology-distances "${distances:-unknown}"
                    medium=$(parse_medium "$out")
                    value topology-backhaul-medium "$medium"
                    status=$(parse_labeled_number 'backhaul connection status|bh_conn_status' "$out")
                    value topology-bh-status "${status:-unknown}"
                    type=$(parse_labeled_number 'backhaul connection type|bh_conn_type|type[[:space:]]+[0-9]+' "$out")
                    value topology-bh-type "${type:-unknown}"
                else value "$cmd" unavailable; fi ;;
            bh_conn_status|bh_conn_type)
                numeric=$(parse_labeled_number "$cmd|backhaul connection|type[[:space:]]+[0-9]+" "$out")
                if [ -n "$out" ]; then value "mapd-$cmd" "${numeric:-unparsed}"; else value "mapd-$cmd" unavailable; fi ;;
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
if [ -d /sys/kernel/debug/mtk_hwifi/wsys/mld_sta ]; then
    mld_count=0; mld_bands=; mld_refs=
    for mld_file in /sys/kernel/debug/mtk_hwifi/wsys/mld_sta/*; do
        [ -r "$mld_file" ] || continue
        mld_count=$((mld_count + 1))
        file_bands=$(parse_mld_bands "$(cat "$mld_file" 2>/dev/null)")
        [ -n "$file_bands" ] && mld_bands="$mld_bands $file_bands"
        file_refs=$(parse_mld_refs "$(cat "$mld_file" 2>/dev/null)")
        [ -n "$file_refs" ] && mld_refs="$mld_refs $file_refs"
    done
    value mld-object-count "$mld_count"
    value mld-band-indices "$(printf '%s\n' "$mld_bands" | tr ' ' '\n' | sort -u | awk 'NF {printf "%s%s",sep,$0;sep=" "}')"
    value mld-ref-counts "$(printf '%s\n' "$mld_refs" | tr ' ' '\n' | sort -u | awk 'NF {printf "%s%s",sep,$0;sep=" "}')"
else value mld-debugfs unavailable; fi
printf '\nNote: this report is a point-in-time read-only diagnostic; absence of management connectivity does not by itself prove EasyMesh failure.\n'
