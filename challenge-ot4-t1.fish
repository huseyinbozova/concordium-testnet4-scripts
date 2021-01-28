#!/usr/bin/env fish

function print_usage
    echo 'Usage: challenge-ot4-t1.fish password sender [txcount]'
end

function print_error
    echo (set_color red)$argv(set_color normal)
end

set dir (dirname (status -f))

not test -f $dir/accounts-list.txt && print_error 'accounts-list.txt not found' && exit 1

set password $argv[1]
set sender $argv[2]
set txcount $argv[3]
test -z "$password" && print_usage && exit 1
test -z "$sender" && print_usage && exit 1

if test -z "$txcount"
    set txcount 100
end

not type -q rg && print_error 'rg not found' && exit 1

set receivers (cat $dir/accounts-list.txt)

function pick_receiver
    set num (random 1 (count $receivers))
    echo $receivers[$num]
end

# Usage: sent_transaction password sender receiver
function sent_transaction
    echo "$argv[1]" | \
        concordium-client transaction send-gtu \
        --sender $argv[2] \
        --receiver $argv[3] \
        --amount 0.000001 \
        --no-confirm \
        --no-wait \
        --grpc-ip 127.0.0.1 2>&1 >/dev/null
end

mkdir -p $dir/ot4-t1
set txids_file "$dir/ot4-t1/txids_"(date '+%Y%m%d_%H%M%S.txt')

for i in (seq 1 $txcount)
    test $i -gt 1 && sleep (random 1 30)

    set tmp (mktemp)
    sent_transaction $password $sender (pick_receiver) >$tmp

    cat $tmp >>$dir/ot4-t1.log
    echo >>$dir/ot4-t1.log
    cat $tmp | rg -or '$1' '^Transaction \'(.+)\' sent.*' >>$txids_file
end
