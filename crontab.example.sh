PATH=/home/<user>/scripts:/usr/local/bin:/usr/bin:/bin
password=<password>
sender=<sender>

# OT4-T1
0 0,5,10,15,20 * * * challenge-ot4-t1.fish $password $sender >>$HOME/scripts/cron_t1.log 2>&1

# OT4-T2
*/5 1,3,6,9,11,16,20,21 * * * challenge-ot4-t2.fish $password $sender >>$HOME/scripts/cron_t2.log 2>&1

# OT4-T3
*/10 2,4,7,10,12,14,22 * * * challenge-ot4-t3.fish $password $sender >>$HOME/scripts/cron_t3.log 2>&1

# OT4-T4
0 10 * * * challenge-ot4-t4.fish $password $sender >>$HOME/scripts/cron_t4.log 2>&1
