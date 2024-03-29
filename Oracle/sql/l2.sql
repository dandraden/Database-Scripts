REM 
REM ========================================================== 
REM Procedure        : lock.sql 
REM Subject          : List of locks by users (except MR and RT) 
REM Oracle database  : Oracle7, Oracle8, Oracle8i , Oracle9i
REM ========================================================== 
REM 
 
SET ECHO      OFF 
SET TERM      ON 
SET TIMING    OFF 
SET HEAD      ON 
SET VERI      OFF 
SET FEED      OFF 
SET PAUSE     OFF 
SET PAGES     66 
SET RECSEP    OFF 
SET LINES     132 
SET ARRAYSIZE 5 
  
BTITLE        OFF 
TTITLE        OFF 
  
CLEAR BREAKS 
CLEAR COMPUTE 
CLEAR COLUMNS 
CLEAR SCREEN 
  
COL l FOR A78 TRUNC 
  
  
ACCEPT us_ CHAR PROMPT "Username  (LIKE format - default= all): " 
  
  
TTITLE CENTER "Locks by users (except type MR and RT) by &&us_" SKIP - RIGHT "" 
  
COL username      FOR A08      HEAD "USER OS"        TRUNC 
COL pid           FOR 999      HEAD "PID"            TRUNC 
COL spid          FOR A06      HEAD "SID"            TRUNC 
COL ora           FOR A08      HEAD "USER ORA"       TRUNC 
COL lock          FOR A10      HEAD "LOCKS"          TRUNC 
COL type          FOR A27      HEAD "TYPE"           WRAPPED 
COL lmode         FOR A04      HEAD "MODE"           TRUNC 
COL wait          FOR A01      HEAD "W"              TRUNC 
  
BREAK ON username - 
      ON pid      - 
      ON spid     - 
      ON ora      - 
      ON lock 
  
SPOOL locks.LOG
  
SELECT p.username                             
,      p.pid                                  
,      p.spid                                 
,      s.username ora                         
,      DECODE(l2.type, 
              'TX','TRANSACTIONROW-LEVEL'     , 
              'TS','TEMPORARYSEGMENT '        , 
              'TD','TABLELOCK'                , 
              'TM','ROWLOCK'                  , 
              l2.type )   vlock, 
       DECODE(l2.type, 
              'TX', 'DMLLOCK', 
              'TS', 'TEMPORARYSEGMENT', 
              'TD', DECODE(l2.lmode+l2.request  , 4,'PARSE ' || u.name || '.' || o.name , 6,'DDL', l2.lmode+l2.request),
              'TM', 'DML ' || u.name || '.' || o.name , l2.type )   type                          
,        DECODE(l2.lmode+l2.request             
,             2,'RS'                          
,             3,'RX'                       
,             4,'S'                        
,             5,'SRX'                      
,             6,'X'                        
,             l2.lmode+l2.request)   lmode    
,         DECODE(l2.request                      
,             0,NULL                          
,               'WAIT')   wait 
FROM   	v$process               p , 
   	v$_lock 		l1, 
   	v$lock                  l2, 
        v$resource              r , 
        sys.obj$                o , 
        sys.user$               u , 
        v$session               s 
WHERE  	s.paddr    = p.addr 
  AND  	s.saddr    = l1.saddr 
  AND  	l1.raddr   = r.addr 
  AND  	l2.addr    = l1.laddr 
  AND  	l2.type    <> 'MR' 
  AND  	l2.type    <> 'RT'
  AND  	r.id1      = o.obj# (+) 
  AND  	o.owner#   = u.user# (+) 
  AND  	p.username LIKE NVL('&&us_','%') 
ORDER BY 
       1, 
       2, 
       3, 
       4, 
       5 
/ 
SPOOL OFF 
  