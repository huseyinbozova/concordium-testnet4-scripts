#!/usr/bin/env fish

function print_usage
    echo 'Usage: '(basename (status -f))' txfile [txfile]'
end

function print_error
    echo (set_color red)$argv(set_color normal)
end

set count_success 0
set count_rejected 0
set total 0

if test (count $argv) -lt 1
    print_usage
    exit 1
end

for file in $argv
    if not test -f $file
        print_error 'File not found: '$file
        continue
    end

    for txid in (cat $file)
        echo -n $txid' ... '
        set txst (
            concordium-client transaction status $txid --grpc-ip 127.0.0.1 |\
                rg -or '$1' '^Transaction is finalized into block .+ with status "(.+)".*'
        )

        switch $txst
            case success
                set count_success (math "$count_success+1")
            case rejected
                set count_rejected (math "$count_rejected+1")
        end

        set total (math "$total+1")
        echo $txst
    end
end

echo
echo 'Total transactions: '$total
echo '           Succeed: '$count_success
echo '          Rejected: '$count_rejected
