SELECT VALUE/(A.COUNTER + B.COUNTER + C.COUNTER) "PING RATE"
  FROM V$SYSSTAT,
       V$LOCK_ACTIVITY A,
       V$LOCK_ACTIVITY B,
       V$LOCK_ACTIVITY C
 WHERE A.FROM_VAL = 'X'
   AND A.TO_VAL = 'NULL'
   AND B.FROM_VAL = 'X'
   AND B.TO_VAL = 'S'
   AND C.FROM_VAL = 'X'
   AND C.TO_VAL = 'SSX'
   AND NAME = 'DBWR cross instance writes'
/
