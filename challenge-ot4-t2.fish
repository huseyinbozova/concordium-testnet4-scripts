#!/usr/bin/env fish

set dir (dirname (status -f))
set txdir $dir/ot4-t2

source $dir/common.fish
ensure_rg_installed
ensure_accounts_exists

if test (count $argv) -ne 2
    echo 'Usage: '(basename (status -f))' password sender'
    exit 1
end

set password $argv[1]
set sender $argv[2]

mkdir -p $txdir
set txids_file "$txdir/"(txids_filename)

call_client transaction send-gtu-encrypted $password $sender (pick_receiver) >>$txdir.log 2>>$txids_file
