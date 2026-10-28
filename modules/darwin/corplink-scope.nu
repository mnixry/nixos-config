def sc [commands: list<string>] {
    $commands | str join "\n" | ^/usr/sbin/scutil -p
}

def service [key: string] {
    sc [$"show ($key)"]
    | lines
    | parse --regex '^  (?<key>\S+)\s*:\s*(?<value>\S+)\s*$'
    | reduce --fold {} {|row, result|
        $result | upsert $row.key $row.value
    }
}

def scope-corplink [] {
    for file in (glob '/usr/local/corplink/vpn.utun*.conf') {
        let vpn = try {
            open --raw $file | from json
        } catch {
            null
        }
        if $vpn == null { continue }

        let tun = $vpn.TunName? | default ''
        if $tun !~ '^utun[0-9]+$' { continue }

        let key = $"State:/Network/Service/($tun)"
        let endpoints = $vpn.ProtectedRoute | get Network
        let active = ['IPv4' 'IPv6'] | any {|family|
            let ip = service $"($key)/($family)"
            ($ip.InterfaceName? == $tun) and ($ip.ServerAddress? in $endpoints)
        }
        if not $active { continue }

        let rank = (service $key).PrimaryRank?
        if $rank == null or $rank == 'Scoped' { continue }

        # Corplink's Never rank scopes only the default; Scoped covers every route.
        sc [$"get ($key)" 'd.add PrimaryRank Scoped' $"set ($key)"] | ignore
        if (service $key).PrimaryRank? != 'Scoped' {
            error make {msg: $"Failed to scope Corplink service ($tun)"}
        }
        print $"Corplink ($tun): Scoped"
    }
}

def main [] {
    let parent = job id
    job spawn {
        try {
            watch /usr/local/corplink --quiet --recursive false --glob '**/vpn.utun*.conf'
            | prepend {operation: 'Initial'}
            | each {|_| {event: 'snapshot'} | job send $parent }
            | ignore
        } catch {|err|
            {error: $err.msg} | job send $parent
        }
    } | ignore

    job spawn {
        try {
            loop {
                # Subscribe before scanning; n.wait blocks until the next change.
                sc [
                    'n.add ^State:/Network/Service/utun[0-9]+(/IPv4|/IPv6)?$ pattern'
                    'list ^State:/Network/Service/utun[0-9]+$'
                    'n.wait'
                ]
                | lines
                | each {|line|
                    if ($line | str contains 'subKey [') {
                        {event: 'service'} | job send $parent
                    } else if ($line | str trim) not-in ['' 'no keys.'] {
                        error make {msg: $"scutil: ($line)"}
                    }
                }
                | ignore
            }
        } catch {|err|
            {error: $err.msg} | job send $parent
        }
    } | ignore

    loop {
        let event = job recv
        if $event.error? != null { error make {msg: $event.error} }
        scope-corplink
    }
}
