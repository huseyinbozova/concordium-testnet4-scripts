PATH=/home/<user>/scripts:/usr/local/bin:/usr/bin:/bin
password=<password>
sender=<sender>

# OT4-T1
0 0,5,10,15,20 * * * challenge-ot4-t1.fish $password $sender >>$HOME/scripts/cron_t1.log 2>&1
