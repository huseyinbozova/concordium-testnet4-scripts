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

# Usage: send_transaction command subcommand password sender [receiver]
function send_transaction
    set passwd $argv[3]
    set args --sender $argv[4] \
        --amount 0.000001 \
        --no-confirm \
        --no-wait \
        --grpc-ip 127.0.0.1

    if test "$argv[1]" = transaction
        set args --receiver $argv[5] $args
    end

    if test "$argv[2]" = send-gtu-encrypted -o "$argv[2]" = decrypt
        set passwd "$passwd\n$passwd"
    end

    echo -e "$passwd" | concordium-client $argv[1] $argv[2] $args 2>&1 >/dev/null
    echo
end

mkdir -p $dir/$txdir
set txids_file "$dir/$txdir/txids_"(date '+%Y%m%d_%H%M%S.txt')

set tx_regex '^Transaction \'(.+)\' sent.*'
set tmp (mktemp)

function save_log
    cat $tmp >>$dir/$txdir.log
    cat $tmp | rg -or '$1' $tx_regex >>$txids_file
end

send_transaction transaction send-gtu $password $sender (pick_receiver) >$tmp
save_log

send_transaction transaction send-gtu-encrypted $password $sender (pick_receiver) >$tmp
save_log

send_transaction account encrypt $password $sender >$tmp
save_log

# WARNING: Without timeout this transaction will be rejected with error:
#     Transaction rejected: the proof for the secret to public transfer doesn't validate.
sleep (random 180 256)
send_transaction account decrypt $password $sender >$tmp
save_log
