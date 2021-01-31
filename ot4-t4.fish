#!/usr/bin/env fish

set dir (dirname (status -f))
set txdir $dir/ot4-t4

source $dir/common.fish
ensure_rg_installed
ensure_accounts_exists

if test (count $argv) -lt 2
    echo 'Usage: '(basename (status -f))' password sender [txcount]'
    exit 1
end

set password $argv[1]
set sender $argv[2]

# Usage: send_transaction 1password 2sender 3receiver
function send_transaction
    while test "$txstatus" != success
        set output (
            echo "$argv[1]" | \
                concordium-client transaction send-gtu-scheduled \
                --sender $argv[2] \
                --receiver $argv[3] \
                --amount 0.05 \
                --every Minute \
                --for 50 \
                --starting (date -ud '+1 hour' '+%FT%H:%M:%SZ') \
                --no-confirm \
                --grpc-ip 127.0.0.1 2>&1
        )

        split_output $output
        set txstatus (get_status $output)
    end
end

mkdir -p $txdir
set txids_file "$txdir/"(txids_filename)

send_transaction $password $sender (pick_receiver) >>$txdir.log 2>>$txids_file
