#!/usr/bin/env fish

set count_success 0
set count_rejected 0
set total 0

for file in $argv
    set transactions (cat $file)

    for txid in $transactions
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
