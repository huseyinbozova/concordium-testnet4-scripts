#!/usr/bin/env fish

set dir (dirname (status -f))
set script (basename (status -f))
set txdir (string replace 'challenge-' '' (basename $script .fish))

function print_usage
    echo "Usage: $script password sender"
end

function print_error
    echo (set_color red)$argv(set_color normal)
end

not test -f $dir/accounts-list.txt && print_error 'accounts-list.txt not found' && exit 1

set password $argv[1]
set sender $argv[2]
test -z "$password" && print_usage && exit 1
test -z "$sender" && print_usage && exit 1

not type -q rg && print_error 'rg not found' && exit 1

set receivers (cat $dir/accounts-list.txt)

function pick_receiver
    set num (random 1 (count $receivers))
    echo $receivers[$num]
end

# Usage: send_transaction password sender receiver
function send_transaction
    echo "$argv[1]" | \
        concordium-client transaction send-gtu-scheduled \
        --sender $argv[2] \
        --receiver $argv[3] \
        --amount 0.05 \
        --every Minute \
        --for 50 \
        --starting (date -d '+1 hour' '+%Y-%m-%dT%H:%M:%SZ') \
        --no-confirm \
        --no-wait \
        --grpc-ip 127.0.0.1 2>&1 >/dev/null
end

mkdir -p $dir/$txdir
set txids_file "$dir/$txdir/txids_"(date '+%Y%m%d_%H%M%S.txt')

set tmp (mktemp)
send_transaction $password $sender (pick_receiver) >$tmp

cat $tmp >>$dir/$txdir.log
echo >>$dir/$txdir.log
cat $tmp | rg -or '$1' '^Transaction \'(.+)\' sent.*' >>$txids_file
