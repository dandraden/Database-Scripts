SELECT INST_ID
     , SID
     , SERIAL#
     , USERNAME
     , OSUSER
     , MACHINE
     , TERMINAL
     , PROGRAM 
  FROM GV$SESSION
 WHERE OSUSER LIKE 'T%'
   AND TERMINAL LIKE 'SE%'
   AND PROGRAM IS NOT NULL
/