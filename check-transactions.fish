#!/usr/bin/env fish

set transactions (cat $argv[1])
set count_success 0
set count_rejected 0

for txid in $transactions
    echo -n $txid'... '
    set txst (concordium-client transaction status $txid | rg -or '$1' '^Transaction is finalized into block .+ with status "(.+)".*')

    switch $txst
        case success
            set count_success (math "$count_success+1")
        case rejected
            set count_rejected (math "$count_rejected+1")
    end

    echo $txst
end

echo
echo 'Total transactions: '(count $transactions)
echo '           Succeed: '$count_success
echo '          Rejected: '$count_rejected
