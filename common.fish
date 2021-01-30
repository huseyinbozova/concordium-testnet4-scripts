set status_regex '^Transaction is .+ into block .+ with status "(.+)"'
set txid_regex "Transaction '(.+)' sent.*"
set receivers (cat $dir/accounts-list.txt)
set receivers_count (count $receivers)

function print_error
    echo (set_color red)$argv(set_color normal)
end

function ensure_accounts_exists
    if not test -f $dir/accounts-list.txt
        print_error $dir'/accounts-list.txt not found'
        exit 1
    end

    if test $receivers_count -lt 2
        print_error 'Required at least two accounts in accounts-list.txt'
        exit 1
    end
end

function ensure_rg_installed
    not type -q rg && print_error 'rg not found' && exit 1
end

function txids_filename
    echo 'txids_'(date '+%Y%m%d_%H%M%S.txt')
end

function split_output
    string split0 -- $argv
    echo
    string split0 -- $argv | rg -or '$1' $txid_regex 1>&2
end

function get_status
    string split0 -- $argv | rg -or '$1' $status_regex
end

function pick_receiver
    set num (random 1 $receivers_count)
    echo $receivers[$num]
end

# Usage: call_client 1command 2subcommand 3password 4sender 5[receiver]
function call_client
    set input $argv[3]
    set args --sender $argv[4] \
        --amount 0.000001 \
        --no-confirm \
        --grpc-ip 127.0.0.1

    if test "$argv[1]" = transaction
        set args --receiver $argv[5] $args
    end

    if test "$argv[2]" = send-gtu-encrypted -o "$argv[2]" = decrypt
        set input "$argv[3]\n$argv[3]"
    end

    while test "$txstatus" != success
        set output (
            echo -e "$input" | concordium-client $argv[1] $argv[2] $args 2>&1
        )

        split_output $output
        set txstatus (get_status $output)
    end
end
