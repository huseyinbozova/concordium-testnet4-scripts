#!/usr/bin/env fish

set dir (dirname (status -f))
set txdir $dir/ot4-t1

source $dir/common.fish
ensure_rg_installed
ensure_accounts_exists

if test (count $argv) -lt 2
    echo 'Usage: '(basename (status -f))' password sender [txcount]'
    exit 1
end

set password $argv[1]
set sender $argv[2]
set txcount $argv[3]

if test -z "$txcount"
    set txcount (random 110 115)
end

mkdir -p $txdir
set txids_file "$txdir/"(txids_filename)

for i in (seq 1 $txcount)
    call_client transaction send-gtu $password $sender (pick_receiver) >>$txdir.log 2>>$txids_file
end
