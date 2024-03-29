PRINT 'Current database: ' + DB_NAME()
GO
SET NOCOUNT ON
SET QUOTED_IDENTIFIER ON
GO

-- TODO: store schema ver for possible upgrade tasks
IF '%runmode%' != 'REALTIME' AND OBJECT_ID ('tbl_SCRIPT_ENVIRONMENT_DETAILS') IS NOT NULL 
BEGIN
  DECLARE @firstruntime datetime, @lastruntime datetime
  SELECT @firstruntime = MIN (runtime), @lastruntime = MAX (runtime) FROM tbl_RUNTIMES (NOLOCK)
  PRINT '=============================================='
  PRINT '        Perf Stats Script Analysis            '
  PRINT '=============================================='
  PRINT ' Script Exec Duration: ' + CONVERT (varchar, DATEDIFF (mi, @firstruntime, @lastruntime)) + ' minutes'
  PRINT '    Script Start Time: ' + CONVERT (varchar, @firstruntime, 120) 
  PRINT '      Script End Time: ' + CONVERT (varchar, @lastruntime, 120) 
  IF OBJECT_ID ('tbl_SCRIPT_ENVIRONMENT_DETAILS') IS NOT NULL 
    SELECT RIGHT (REPLICATE (' ', 24) + LEFT ([Name], 20), 21) + ':', LEFT ([Value], 60) FROM tbl_SCRIPT_ENVIRONMENT_DETAILS 
    WHERE script_name = 'SQL 2005 Perf Stats Script'
  RAISERROR ('', 0, 1) WITH NOWAIT
END
GO

/* ========== BEGIN TABLE CREATES (realtime only) ========== */
-- DROP TABLE tbl_RUNTIMES
IF '%runmode%' = 'REALTIME' AND OBJECT_ID ('tbl_RUNTIMES') IS NULL
  CREATE TABLE [dbo].[tbl_RUNTIMES](
    [rownum] [bigint] IDENTITY NOT NULL,
    [runtime] [datetime] NULL,
    [source_script] [varchar](80) NULL
  ) 
GO

IF '%runmode%' = 'REALTIME' AND OBJECT_ID ('tbl_BLOCKING_CHAINS') IS NULL
  CREATE TABLE [dbo].[tbl_BLOCKING_CHAINS](
    [first_rownum] [bigint] NULL,
    [last_rownum] [bigint] NULL,
    [num_snapshots] [int] NULL,
    [blocking_start] [datetime] NULL,
    [blocking_end] [datetime] NULL,
    [head_blocker_session_id] int NULL, 
    [blocking_wait_type] varchar(40) NULL, 
    [max_blocked_task_count] int NULL,
    [max_total_wait_duration_ms] [bigint] NULL,
    [avg_wait_duration_ms] [bigint] NULL,
    [max_wait_duration_ms] [bigint] NULL,
    [max_blocking_chain_depth] [int] NULL,
    [head_blocker_session_id_orig] [int] NULL
  ) 
GO

-- DROP VIEW vw_HEAD_BLOCKER_SUMMARY
-- DROP TABLE tbl_HEADBLOCKERSUMMARY
IF OBJECT_ID ('tbl_HEADBLOCKERSUMMARY') IS NULL
  CREATE TABLE [dbo].[tbl_HEADBLOCKERSUMMARY](
    [rownum] [bigint] IDENTITY NOT NULL,
    [runtime] [datetime] NULL,
    [head_blocker_session_id] [int] NULL,
    [blocked_task_count] [int] NULL,
    [tot_wait_duration_ms] [bigint] NULL,
    [blocking_resource_wait_type] varchar(40) NULL, 
    [avg_wait_duration_ms] [bigint] NULL,
    [max_wait_duration_ms] [bigint] NULL,
    [max_blocking_chain_depth] [int] NULL, 
    [head_blocker_proc_name] nvarchar(60), 
    [head_blocker_proc_objid] [int] NULL, 
    [stmt_text] nvarchar(1000) NULL, 
    [head_blocker_plan_handle] varbinary(64) NULL
  )
GO
-- DROP TABLE tbl_NOTABLEACTIVEQUERIES
IF '%runmode%' = 'REALTIME' AND OBJECT_ID ('tbl_NOTABLEACTIVEQUERIES') IS NULL
  CREATE TABLE [dbo].[tbl_NOTABLEACTIVEQUERIES](
    [rownum] [bigint] IDENTITY NOT NULL,
    [runtime] [datetime] NULL,
    [session_id] [int] NULL,
    [request_id] [int] NULL,
    [plan_total_exec_count] [bigint] NULL,
    [plan_total_cpu_ms] [bigint] NULL,
    [plan_total_duration_ms] [bigint] NULL,
    [plan_total_physical_reads] [bigint] NULL,
    [plan_total_logical_writes] [bigint] NULL,
    [plan_total_logical_reads] [bigint] NULL,
    [dbname] [varchar](40) NULL,
    [objectid] [int] NULL,
    [procname] [varchar](60) NULL,
    [plan_handle] varbinary(64) NULL,
    [stmt_text] [varchar](2000) NULL,
    [stmt_text_agg]  AS (replace(replace(case when [stmt_text] IS NULL then NULL when charindex('noexec',substring([stmt_text],(1),(200)))>(0) then substring([stmt_text],(1),(40)) when charindex('sp_executesql',substring([stmt_text],(1),(200)))>(0) then substring([stmt_text],charindex('exec',substring([stmt_text],(1),(200))),(60)) when charindex('sp_cursoropen',substring([stmt_text],(1),(200)))>(0) OR charindex('sp_cursorprep',substring([stmt_text],(1),(200)))>(0) OR charindex('sp_prepare',substring([stmt_text],(1),(200)))>(0) OR charindex('sp_prepexec',substring([stmt_text],(1),(200)))>(0) then substring([stmt_text],charindex('exec',substring([stmt_text],(1),(200))),(80)) when charindex('exec',substring([stmt_text],(1),(200)))>(0) then substring([stmt_text],charindex('exec',substring([stmt_text],(1),(4000))),charindex(' ',substring(substring([stmt_text],(1),(200))+'   ',charindex('exec',substring([stmt_text],(1),(500))),(200)),(9))) when substring([stmt_text],(1),(2))='usp' OR substring([stmt_text],(1),(2))='xp' OR substring([stmt_text],(1),(2))='sp' then substring([stmt_text],(1),charindex(' ',substring([stmt_text],(1),(200))+' ')) when substring([stmt_text],(1),(30)) like '%UPDATE %' OR substring([stmt_text],(1),(30)) like '%INSERT %' OR substring([stmt_text],(1),(30)) like '%DELETE %' then substring([stmt_text],(1),(30)) else substring([stmt_text],(1),(45)) end,char((10)),' '),char((13)),' '))
  )
GO
-- DROP TABLE tbl_REQUESTS
IF '%runmode%' = 'REALTIME' AND OBJECT_ID ('tbl_REQUESTS') IS NULL
  CREATE TABLE [dbo].[tbl_REQUESTS](
    [rownum] [bigint] IDENTITY NOT NULL,
    [runtime] [datetime] NULL,
    [session_id] [int] NULL,
    [request_id] [int] NULL, 
    [ecid] [int] NULL,
    [blocking_session_id] [int] NULL,
    [blocking_ecid] [int] NULL,
    [task_state] [varchar](15) NULL,
    [wait_type] [varchar](50) NULL,
    [wait_duration_ms] [bigint] NULL,
    [wait_resource] [varchar](40) NULL,
    [resource_description] [varchar](120) NULL,
    [last_wait_type] [varchar](50) NULL,
    [open_trans] [int] NULL,
    [transaction_isolation_level] [varchar](30) NULL,
    [is_user_process] [int] NULL,
    [request_cpu_time] [bigint] NULL,
    [request_logical_reads] [bigint] NULL,
    [request_reads] [bigint] NULL,
    [request_writes] [bigint] NULL,
    [memory_usage] [int] NULL,
    [session_cpu_time] [bigint] NULL,
    [session_reads] [bigint] NULL,
    [session_writes] [bigint] NULL,
    [session_logical_reads] [bigint] NULL,
    [total_scheduled_time] [bigint] NULL,
    [total_elapsed_time] [varchar](18) NULL,
    [last_request_start_time] [datetime] NULL,
    [last_request_end_time] [datetime] NULL,
    [session_row_count] [bigint] NULL,
    [prev_error] [int] NULL,
    [open_resultsets] [int] NULL,
    [request_total_elapsed_time] [bigint] NULL,
    [percent_complete] [int] NULL,
    [estimated_completion_time] [bigint] NULL,
    [tran_name] [varchar](32) NULL,
    [transaction_begin_time] [datetime] NULL,
    [tran_type] [varchar](15) NULL,
    [tran_state] [varchar](15) NULL,
    [request_start_time] [datetime] NULL,
    [request_status] [varchar](15) NULL,
    [command] [varchar](16) NULL,
    [statement_start_offset] [int] NULL,
    [statement_end_offset] [int] NULL,
    [database_id] [int] NULL,
    [user_id] [int] NULL,
    [executing_managed_code] [int] NULL,
    [pending_io_count] [int] NULL,
    [login_time] [datetime] NULL,
    [host_name] [varchar](20) NULL,
    [program_name] [varchar](50) NULL,
    [host_process_id] [int] NULL,
    [client_version] [varchar](14) NULL,
    [client_interface_name] [varchar](32) NULL,
    [login_name] [varchar](20) NULL,
    [nt_domain] [varchar](30) NULL,
    [nt_user_name] [varchar](20) NULL,
    [net_packet_size] [int] NULL,
    [client_net_address] [varchar](40) NULL,
    [session_status] [varchar](15) NULL,
    [scheduler_id] [int] NULL,
    [is_preemptive] [int] NULL,
    [is_sick] [int] NULL,
    [last_worker_exception] [int] NULL,
    [last_exception_address] [varbinary](22) NULL,
    [os_thread_id] [int] NULL
  )
GO

IF '%runmode%' = 'REALTIME' AND OBJECT_ID ('tbl_OS_WAIT_STATS') IS NULL
  CREATE TABLE [dbo].[tbl_OS_WAIT_STATS](
    [rownum] [bigint] IDENTITY NOT NULL,
    [runtime] [datetime] NULL,
    [wait_type] [varchar](45) NULL,
    [waiting_tasks_count] [bigint] NULL,
    [wait_time_ms] [bigint] NULL,
    [max_wait_time_ms] [bigint] NULL,
    [signal_wait_time_ms] [bigint] NULL
  )
GO
IF '%runmode%' = 'REALTIME' AND OBJECT_ID ('tbl_SYSPERFINFO') IS NULL
  CREATE TABLE [dbo].[tbl_SYSPERFINFO] (
    [rownum] [bigint] IDENTITY NOT NULL,
    [runtime] [datetime] NULL,
    [object_name] nvarchar(256), 
    counter_name nvarchar(256), 
    instance_name nvarchar(256), 
    cntr_value bigint
  )
GO
IF '%runmode%' = 'REALTIME' AND OBJECT_ID ('tbl_SQL_CPU_HEALTH') IS NULL
  CREATE TABLE tbl_SQL_CPU_HEALTH (
    rownum bigint IDENTITY NOT NULL, 
    runtime datetime, 
    record_id int, 
    EventTime datetime, 
    system_idle_cpu int, 
    sql_cpu_utilization int
  )
GO
IF '%runmode%' = 'REALTIME' AND OBJECT_ID ('tbl_FILE_STATS') IS NULL
  CREATE TABLE [dbo].[tbl_FILE_STATS](
    [database] [sysname],
    [file] [nvarchar](260),
    [DbId] [smallint],
    [FileId] [smallint],
    [AvgIOTimeMS] [bigint] NULL,
    [TimeStamp] [int],
    [NumberReads] [bigint],
    [BytesRead] [bigint],
    [IoStallReadMS] [bigint],
    [NumberWrites] [bigint],
    [BytesWritten] [bigint],
    [IoStallWriteMS] [bigint],
    [IoStallMS] [bigint],
    [BytesOnDisk] [bigint],
    [type] [tinyint],
    [type_desc] [nvarchar](60),
    [data_space_id] [int],
    [state] [tinyint],
    [state_desc] [nvarchar](60),
    [size] [int],
    [max_size] [int],
    [growth] [int],
    [is_sparse] [bit],
    [is_percent_growth] [bit] 
  )
GO

-- "Register" perf stats tables for the background purge job
IF '%runmode%' = 'REALTIME' BEGIN
  IF NOT EXISTS (SELECT * FROM tbl_NEXUS_PURGE_TABLES WHERE tablename = 'tbl_RUNTIMES') INSERT INTO tbl_NEXUS_PURGE_TABLES VALUES ('tbl_RUNTIMES', 'runtime')
  IF NOT EXISTS (SELECT * FROM tbl_NEXUS_PURGE_TABLES WHERE tablename = 'tbl_BLOCKING_CHAINS') INSERT INTO tbl_NEXUS_PURGE_TABLES VALUES ('tbl_BLOCKING_CHAINS', 'blocking_end')
  IF NOT EXISTS (SELECT * FROM tbl_NEXUS_PURGE_TABLES WHERE tablename = 'tbl_HEADBLOCKERSUMMARY') INSERT INTO tbl_NEXUS_PURGE_TABLES VALUES ('tbl_HEADBLOCKERSUMMARY', 'runtime')
  IF NOT EXISTS (SELECT * FROM tbl_NEXUS_PURGE_TABLES WHERE tablename = 'tbl_NOTABLEACTIVEQUERIES') INSERT INTO tbl_NEXUS_PURGE_TABLES VALUES ('tbl_NOTABLEACTIVEQUERIES', 'runtime')
  IF NOT EXISTS (SELECT * FROM tbl_NEXUS_PURGE_TABLES WHERE tablename = 'tbl_REQUESTS') INSERT INTO tbl_NEXUS_PURGE_TABLES VALUES ('tbl_REQUESTS', 'runtime')
  IF NOT EXISTS (SELECT * FROM tbl_NEXUS_PURGE_TABLES WHERE tablename = 'tbl_OS_WAIT_STATS') INSERT INTO tbl_NEXUS_PURGE_TABLES VALUES ('tbl_OS_WAIT_STATS', 'runtime')
  IF NOT EXISTS (SELECT * FROM tbl_NEXUS_PURGE_TABLES WHERE tablename = 'tbl_SYSPERFINFO') INSERT INTO tbl_NEXUS_PURGE_TABLES VALUES ('tbl_SYSPERFINFO', 'runtime')
  IF NOT EXISTS (SELECT * FROM tbl_NEXUS_PURGE_TABLES WHERE tablename = 'tbl_SQL_CPU_HEALTH') INSERT INTO tbl_NEXUS_PURGE_TABLES VALUES ('tbl_SQL_CPU_HEALTH', 'runtime')
END
GO

-- Compensate for missing sys.dm_os_sys_info in some very old perf stats script output. 
IF OBJECT_ID ('tbl_SYSINFO') IS NULL
BEGIN
  CREATE TABLE [dbo].[tbl_SYSINFO](
    tableinfo varchar(128), 
    cpu_ticks bigint, ms_ticks bigint, cpu_count int, cpu_ticks_in_ms bigint, 
    hyperthread_ratio int, physical_memory_in_bytes bigint, virtual_memory_in_bytes bigint, 
    bpool_committed int, bpool_commit_target int, bpool_visible int, 
    stack_size_in_bytes int, os_quantum bigint, os_error_code int, os_priority_class int, 
    max_workers_count int, schedulers_count smallint, scheduler_total_count int, 
    deadlock_monitor_serial_number int
  )
  EXEC ('INSERT INTO tbl_SYSINFO (tableinfo, cpu_count) 
    VALUES (''This table was created by PerfStatsAnalysis.sql due to missing Perf Stats Script data.'', 2)')
END
GO

-- Compensate for missing tbl_SQL_CPU_HEALTH bug in some perf stats script output
IF OBJECT_ID ('tbl_SQL_CPU_HEALTH') IS NULL 
BEGIN
  CREATE TABLE [dbo].[tbl_SQL_CPU_HEALTH](
    [runtime] [datetime] NOT NULL,
    [record_id] [int] NULL,
    [EventTime] [varchar](30) NULL,
    [timestamp] [bigint] NOT NULL,
    [system_idle_cpu] [int] NULL,
    [sql_cpu_utilization] [int] NULL
  )
END
GO

/* ========== END TABLE CREATES ========== */



/* ========== BEGIN ANALYSIS HELPER OBJECTS ========== */
IF OBJECT_ID ('vw_BLOCKING_HIERARCHY') IS NOT NULL DROP VIEW vw_BLOCKING_HIERARCHY
GO 
CREATE VIEW vw_BLOCKING_HIERARCHY AS 
WITH BlockingHierarchy (runtime, head_blocker_session_id, session_id, blocking_session_id, wait_type, 
  wait_duration_ms, wait_resource, resource_description, [Level]) 
AS (
  SELECT head.runtime, head.session_id AS head_blocker_session_id, head.session_id AS session_id, head.blocking_session_id, 
    head.wait_type, head.wait_duration_ms, head.wait_resource, head.resource_description, 0 AS [Level]
  FROM tbl_REQUESTS (NOLOCK) AS head
  WHERE (head.blocking_session_id IS NULL OR head.blocking_session_id = 0) 
    AND head.session_id IN (SELECT blocking_session_id FROM tbl_REQUESTS  (NOLOCK) AS r2 WHERE r2.blocking_session_id <> 0 AND r2.runtime = head.runtime) 
    AND (head.ecid = 0 OR head.ecid IS NULL)
  UNION ALL 
  SELECT h.runtime, h.head_blocker_session_id, blocked.session_id, blocked.blocking_session_id, blocked.wait_type, 
    CASE WHEN blocked.wait_type LIKE 'EXCHANGE%' OR blocked.wait_type LIKE 'CXPACKET%' THEN 0 ELSE blocked.wait_duration_ms END AS wait_duration_ms, 
    blocked.wait_resource, blocked.resource_description, [Level] + 1
  FROM tbl_REQUESTS (NOLOCK) AS blocked
  INNER JOIN BlockingHierarchy AS h ON h.runtime = blocked.runtime AND h.session_id = blocked.blocking_session_id
)
SELECT * FROM BlockingHierarchy 
GO

IF OBJECT_ID ('vw_FIRSTTIERBLOCKINGHIERARCHY') IS NOT NULL DROP VIEW vw_FIRSTTIERBLOCKINGHIERARCHY
GO 
CREATE VIEW vw_FIRSTTIERBLOCKINGHIERARCHY AS 
  WITH BlockingHierarchy (runtime, first_tier_blocked_session_id, session_id, blocking_session_id, wait_type, 
    wait_duration_ms, first_tier_wait_resource, wait_resource, resource_description, [Level]) 
  AS (
    SELECT firsttier.runtime, firsttier.session_id AS first_tier_blocked_session_id, firsttier.session_id AS session_id, firsttier.blocking_session_id, 
      firsttier.wait_type, firsttier.wait_duration_ms, firsttier.wait_resource AS first_tier_wait_resource, 
      firsttier.wait_resource, firsttier.resource_description, 1 AS [Level]
    FROM tbl_REQUESTS (NOLOCK) AS firsttier
    WHERE firsttier.blocking_session_id IN (SELECT session_id FROM tbl_REQUESTS (NOLOCK) AS r2 WHERE r2.blocking_session_id = 0 AND r2.runtime = firsttier.runtime) 
    UNION ALL 
    SELECT h.runtime, h.first_tier_blocked_session_id, blocked.session_id, blocked.blocking_session_id, blocked.wait_type, 
      CASE WHEN blocked.wait_type IN ('EXCHANGE', 'CXPACKET') THEN 0 ELSE blocked.wait_duration_ms END AS wait_duration_ms, 
      h.first_tier_wait_resource, blocked.wait_resource, blocked.resource_description, [Level] + 1
    FROM tbl_REQUESTS (NOLOCK) AS blocked
    INNER JOIN BlockingHierarchy AS h ON h.runtime = blocked.runtime AND h.session_id = blocked.blocking_session_id
  )
  SELECT * FROM BlockingHierarchy 
GO

-- Handle old tbl_RUNTIMES format
IF NOT EXISTS (SELECT * FROM sys.columns WHERE [object_id] = OBJECT_ID ('tbl_RUNTIMES') AND name = 'source_script') 
  ALTER TABLE tbl_RUNTIMES
  ADD source_script varchar(80) NULL
GO

IF OBJECT_ID ('vw_HEAD_BLOCKER_SUMMARY') IS NOT NULL DROP VIEW vw_HEAD_BLOCKER_SUMMARY
GO
-- old 
IF EXISTS (SELECT * FROM sys.columns WHERE [object_id] = OBJECT_ID ('tbl_HEADBLOCKERSUMMARY') AND name = 'wait_type') 
EXEC ('
  CREATE VIEW vw_HEAD_BLOCKER_SUMMARY WITH SCHEMABINDING AS 
  SELECT rownum, runtime, CASE WHEN wait_type LIKE ''COMPILE%'' THEN ''COMPILE BLOCKING'' ELSE CONVERT (varchar(24), head_blocker_session_id) END AS head_blocker_session_id, 
    blocked_task_count, tot_wait_duration_ms, wait_type AS blocking_wait_type, avg_wait_duration_ms, max_wait_duration_ms, max_blocking_chain_depth, 
    head_blocker_session_id AS head_blocker_session_id_orig
  FROM dbo.tbl_HEADBLOCKERSUMMARY (NOLOCK)
')
GO
-- new
IF EXISTS (SELECT * FROM sys.columns WHERE [object_id] = OBJECT_ID ('tbl_HEADBLOCKERSUMMARY') AND name = 'blocking_resource_wait_type') 
EXEC ('
  CREATE VIEW vw_HEAD_BLOCKER_SUMMARY WITH SCHEMABINDING AS 
  SELECT rownum, runtime, CASE WHEN blocking_resource_wait_type LIKE ''COMPILE%'' THEN ''COMPILE BLOCKING'' ELSE CONVERT (varchar(24), head_blocker_session_id) END AS head_blocker_session_id, 
    blocked_task_count, tot_wait_duration_ms, blocking_resource_wait_type AS blocking_wait_type, avg_wait_duration_ms, max_wait_duration_ms, max_blocking_chain_depth, 
    head_blocker_session_id AS head_blocker_session_id_orig
  FROM dbo.tbl_HEADBLOCKERSUMMARY (NOLOCK)
')
GO
CREATE UNIQUE CLUSTERED INDEX cidx ON vw_HEAD_BLOCKER_SUMMARY (runtime, head_blocker_session_id, blocking_wait_type, rownum)
GO

IF OBJECT_ID ('tbl_PERF_STATS_SCRIPT_RUNTIMES') IS NOT NULL DROP TABLE tbl_PERF_STATS_SCRIPT_RUNTIMES
GO
SELECT DISTINCT runtime INTO tbl_PERF_STATS_SCRIPT_RUNTIMES FROM tbl_REQUESTS ORDER BY runtime
GO

IF OBJECT_ID ('vw_PERF_STATS_SCRIPT_RUNTIMES') IS NOT NULL DROP VIEW vw_PERF_STATS_SCRIPT_RUNTIMES
GO 
CREATE VIEW vw_PERF_STATS_SCRIPT_RUNTIMES AS 
SELECT runtime FROM tbl_PERF_STATS_SCRIPT_RUNTIMES 
--SELECT * FROM tbl_RUNTIMES (NOLOCK) 
--WHERE source_script IN ('SQL 2005 Perf Stats Script', '') OR source_script IS NULL
GO

IF OBJECT_ID ('ufn_REQUEST_DETAILS') IS NOT NULL DROP FUNCTION ufn_REQUEST_DETAILS
GO
CREATE FUNCTION ufn_REQUEST_DETAILS (@start_time datetime, @end_time datetime, @session_id int) RETURNS TABLE AS
RETURN SELECT TOP 1 runtime, session_id, ecid, wait_type, wait_duration_ms, request_status, wait_resource, open_trans, 
  transaction_isolation_level, tran_name, transaction_begin_time, request_start_time, command, resource_description, program_name, 
  [host_name], nt_user_name, nt_domain, login_name, last_request_start_time, last_request_end_time
FROM tbl_REQUESTS 
WHERE runtime >= @start_time AND runtime < @end_time AND session_id = @session_id
ORDER BY CASE WHEN wait_type IN ('EXCHANGE', 'CXPACKET') THEN 1 ELSE 0 END, -- prefer non-parallel waittypes
  wait_duration_ms DESC, -- prefer longer waits
  runtime
GO

IF OBJECT_ID ('ufn_QUERY_DETAILS') IS NOT NULL DROP FUNCTION ufn_QUERY_DETAILS
GO
CREATE FUNCTION ufn_QUERY_DETAILS (@start_time datetime, @end_time datetime, @session_id int) RETURNS TABLE AS
RETURN SELECT TOP 1 runtime, procname, stmt_text, session_id
FROM tbl_NOTABLEACTIVEQUERIES 
WHERE runtime >= @start_time AND runtime < @end_time AND session_id = @session_id AND (stmt_text IS NOT NULL OR procname IS NOT NULL)
ORDER BY runtime
GO

IF '%runmode%' != 'REALTIME' BEGIN
  -- Create tbl_BLOCKING_CHAINS (postmortem analysis mode only -- the realtime data capture proc populates this on-the-fly)
  IF OBJECT_ID ('tempdb.dbo.#head_blk_sum') IS NOT NULL DROP TABLE #head_blk_sum

  SELECT rownum, runtime AS blocking_start, 
    (
      SELECT TOP 1 runtime FROM vw_PERF_STATS_SCRIPT_RUNTIMES run WHERE run.runtime > b.runtime AND NOT EXISTS 
      (SELECT runtime FROM vw_HEAD_BLOCKER_SUMMARY AS b2 WHERE b2.runtime = run.runtime AND b2.head_blocker_session_id = b.head_blocker_session_id AND b2.blocking_wait_type = b.blocking_wait_type)
      ORDER BY run.runtime ASC
    ) AS blocking_end, 
    head_blocker_session_id,  blocking_wait_type, avg_wait_duration_ms, max_wait_duration_ms, max_blocking_chain_depth, 
    blocked_task_count, tot_wait_duration_ms, head_blocker_session_id_orig
  INTO #head_blk_sum
  FROM vw_HEAD_BLOCKER_SUMMARY b
  WHERE runtime IS NOT NULL

  -- Set blocking end time to end-of-data-collection for any blocking chains that were still active when data collection stopped
  UPDATE #head_blk_sum SET blocking_end = (SELECT MAX (runtime) FROM vw_PERF_STATS_SCRIPT_RUNTIMES) WHERE blocking_end IS NULL

--   SELECT 
--     b1.rownum, 
--     b2.blocking_start, b2.blocking_end, b1.head_blocker_session_id, b1.blocking_wait_type, 
--     b1.blocked_task_count AS blocked_task_count, b1.tot_wait_duration_ms AS tot_wait_duration_ms, 
--     b1.avg_wait_duration_ms AS avg_wait_duration_ms, b1.max_wait_duration_ms AS max_wait_duration_ms, 
--     b1.max_blocking_chain_depth AS max_blocking_chain_depth, b1.blocked_task_count, b1.tot_wait_duration_ms, b1.head_blocker_session_id_orig
--   FROM vw_HEAD_BLOCKER_SUMMARY b1
--   INNER JOIN #head_blk_sum b2 ON b1.rownum = b2.rownum
--   WHERE NOT EXISTS (
--     SELECT * FROM #head_blk_sum b3 
--     WHERE b3.blocking_start < b2.blocking_start AND b3.blocking_end = b2.blocking_end AND b3.head_blocker_session_id = b2.head_blocker_session_id AND b3.blocking_wait_type = b2.blocking_wait_type)

  IF OBJECT_ID ('tbl_BLOCKING_CHAINS') IS NOT NULL DROP TABLE tbl_BLOCKING_CHAINS;
  WITH BlockingChainsIntermediate (rownum, blocking_start, blocking_end, head_blocker_session_id, blocking_wait_type, blocked_task_count, 
    tot_wait_duration_ms, avg_wait_duration_ms, max_wait_duration_ms, max_blocking_chain_depth, head_blocker_session_id_orig) AS 
  (
    SELECT 
      rownum, 
      (SELECT MIN (blocking_start) FROM #head_blk_sum b3 WHERE b3.head_blocker_session_id = b2.head_blocker_session_id AND b3.blocking_end = b2.blocking_end AND b3.blocking_wait_type = b2.blocking_wait_type) AS blocking_start, 
      b2.blocking_end, b2.head_blocker_session_id, b2.blocking_wait_type, 
      b2.blocked_task_count, b2.tot_wait_duration_ms, 
      b2.avg_wait_duration_ms, b2.max_wait_duration_ms, 
      b2.max_blocking_chain_depth, b2.head_blocker_session_id_orig
    FROM #head_blk_sum b2 
  )
  SELECT 
    MIN (rownum) AS first_rownum, 
    MAX (rownum) AS last_rownum, 
    COUNT(*) AS num_snapshots, 
    blocking_start, blocking_end, head_blocker_session_id, blocking_wait_type, 
    MAX (blocked_task_count) AS max_blocked_task_count, MAX (tot_wait_duration_ms) AS max_total_wait_duration_ms, 
    AVG (avg_wait_duration_ms) AS avg_wait_duration_ms, MAX (max_wait_duration_ms) AS max_wait_duration_ms, 
    MAX (max_blocking_chain_depth) AS max_blocking_chain_depth, MIN (head_blocker_session_id_orig) AS head_blocker_session_id_orig
  INTO tbl_BLOCKING_CHAINS
  FROM BlockingChainsIntermediate
  GROUP BY blocking_end, blocking_start, head_blocker_session_id, blocking_wait_type
END
GO

IF OBJECT_ID ('vw_BLOCKING_CHAINS') IS NOT NULL DROP VIEW vw_BLOCKING_CHAINS
GO
-- CREATE VIEW vw_BLOCKING_CHAINS AS 
-- WITH BlockingPeriods (rownum, blocking_start, blocking_end, head_blocker_session_id, blocking_wait_type, avg_wait_duration_ms, max_wait_duration_ms, max_blocking_chain_depth, head_blocker_session_id_orig) AS 
-- (
--   SELECT rownum, runtime AS blocking_start, 
--     (
--       SELECT TOP 1 runtime FROM vw_PERF_STATS_SCRIPT_RUNTIMES run WHERE run.runtime > b.runtime AND NOT EXISTS 
--         (SELECT runtime FROM vw_HEAD_BLOCKER_SUMMARY AS b2 WHERE b2.runtime = run.runtime AND b2.head_blocker_session_id = b.head_blocker_session_id AND b2.blocking_wait_type = b.blocking_wait_type)
--       ORDER BY run.runtime ASC
--     ) AS blocking_end, 
--     head_blocker_session_id,  blocking_wait_type, avg_wait_duration_ms, max_wait_duration_ms, max_blocking_chain_depth, 
--     head_blocker_session_id_orig
--   FROM vw_HEAD_BLOCKER_SUMMARY b
-- )
-- SELECT p1.*, 
--   CASE 
--     WHEN DATEDIFF (s, blocking_start, blocking_end) >= 20 THEN DATEDIFF (s, blocking_start, blocking_end) 
--     ELSE max_wait_duration_ms / 1000
--   END AS blocking_duration_sec, 
--   (
--     SELECT MAX (blocked_task_count) FROM vw_HEAD_BLOCKER_SUMMARY b3 
--     WHERE b3.head_blocker_session_id = p1.head_blocker_session_id AND b3.blocking_wait_type = p1.blocking_wait_type AND b3.runtime >= p1.blocking_start AND b3.runtime < p1.blocking_end
--   ) AS max_blocked_task_count, 
--   (
--     SELECT MAX (tot_wait_duration_ms) FROM vw_HEAD_BLOCKER_SUMMARY b3 
--     WHERE b3.head_blocker_session_id = p1.head_blocker_session_id  AND b3.blocking_wait_type = p1.blocking_wait_type AND b3.runtime >= p1.blocking_start AND b3.runtime < p1.blocking_end
--   ) AS max_total_wait_duration_ms, 
--   req.runtime AS example_runtime, req.program_name, req.[host_name], req.nt_user_name, req.nt_domain, req.login_name, req.wait_type, 
--   req.wait_duration_ms, req.request_status, req.wait_resource, req.open_trans, req.transaction_isolation_level, req.tran_name, 
--   req.transaction_begin_time, req.request_start_time, req.command, req.resource_description, 
--   last_request_start_time, last_request_end_time, 
--   qry.procname, qry.stmt_text
-- FROM BlockingPeriods p1
-- OUTER APPLY dbo.ufn_REQUEST_DETAILS (p1.blocking_start, p1.blocking_end, p1.head_blocker_session_id_orig) req
-- OUTER APPLY dbo.ufn_QUERY_DETAILS (p1.blocking_start, p1.blocking_end, p1.head_blocker_session_id_orig) qry
-- WHERE NOT EXISTS 
--   (SELECT blocking_start FROM BlockingPeriods AS p2
--   WHERE p2.blocking_start < p1.blocking_start AND p2.blocking_end = p1.blocking_end AND p2.head_blocker_session_id = p1.head_blocker_session_id 
--     AND p2.blocking_wait_type = p1.blocking_wait_type)
CREATE VIEW vw_BLOCKING_CHAINS AS 
SELECT ch.*, 
  CASE 
    WHEN DATEDIFF (s, blocking_start, blocking_end) >= 20 THEN DATEDIFF (s, blocking_start, blocking_end) 
    ELSE max_wait_duration_ms / 1000
  END AS blocking_duration_sec, 
  req.runtime AS example_runtime, req.program_name, req.[host_name], req.nt_user_name, req.nt_domain, req.login_name, req.wait_type, 
  req.wait_duration_ms, req.request_status, req.wait_resource, req.open_trans, req.transaction_isolation_level, req.tran_name, 
  req.transaction_begin_time, req.request_start_time, req.command, req.resource_description, 
  last_request_start_time, last_request_end_time, 
  qry.procname, qry.stmt_text
FROM tbl_BLOCKING_CHAINS ch
OUTER APPLY dbo.ufn_REQUEST_DETAILS (ch.blocking_start, ch.blocking_end, ch.head_blocker_session_id_orig) req
OUTER APPLY dbo.ufn_QUERY_DETAILS (ch.blocking_start, ch.blocking_end, ch.head_blocker_session_id_orig) qry
GO

IF OBJECT_ID ('vw_BLOCKING_PERIODS') IS NOT NULL DROP VIEW vw_BLOCKING_PERIODS
GO 
CREATE VIEW vw_BLOCKING_PERIODS AS 
WITH BlockingPeriodsRaw (blocking_start, blocking_end, max_wait_duration_ms) AS (
  SELECT DISTINCT runtime AS blocking_start, 
    (
      SELECT TOP 1 runtime FROM vw_PERF_STATS_SCRIPT_RUNTIMES run WHERE run.runtime > b.runtime AND NOT EXISTS 
        (SELECT runtime FROM vw_HEAD_BLOCKER_SUMMARY AS b2 WHERE b2.runtime = run.runtime)
      ORDER BY run.runtime ASC
    ) AS blocking_end, max_wait_duration_ms
  FROM vw_HEAD_BLOCKER_SUMMARY b
)
SELECT p1.*, 
  CASE 
    WHEN DATEDIFF (s, blocking_start, blocking_end) >= 20 THEN DATEDIFF (s, blocking_start, blocking_end) 
    ELSE max_wait_duration_ms / 1000
  END AS blocking_duration_sec, 
  (SELECT MAX (blocked_task_count) FROM vw_HEAD_BLOCKER_SUMMARY b3 WHERE b3.runtime >= p1.blocking_start AND b3.runtime < p1.blocking_end) AS max_blocked_task_count, 
  (SELECT MAX (tot_wait_duration_ms) FROM vw_HEAD_BLOCKER_SUMMARY b3 WHERE b3.runtime >= p1.blocking_start AND b3.runtime < p1.blocking_end) AS max_total_wait_duration_ms 
FROM BlockingPeriodsRaw p1
WHERE NOT EXISTS 
  (SELECT blocking_start FROM BlockingPeriodsRaw AS p2
  WHERE p2.blocking_start < p1.blocking_start AND p2.blocking_end = p1.blocking_end)
GO
-- CREATE VIEW vw_BLOCKING_PERIODS AS 
-- WITH BlockingPeriodsRaw (blocking_start, blocking_end) AS (
--   SELECT runtime AS blocking_start, 
--     (SELECT TOP 1 runtime FROM tbl_REQUESTS (NOLOCK) AS r2 WHERE r2.runtime > r1.runtime AND NOT EXISTS 
--       (SELECT runtime FROM tbl_REQUESTS (NOLOCK) AS r3 WHERE r3.runtime = r2.runtime AND blocking_session_id != 0)
--        ORDER BY r2.runtime ASC) AS blocking_end 
--   FROM tbl_REQUESTS (NOLOCK) AS r1
--   WHERE blocking_session_id != 0
--     AND EXISTS (SELECT * FROM tbl_REQUESTS (NOLOCK) AS r2 WHERE r1.runtime = r2.runtime AND r1.blocking_session_id = r2.session_id AND r2.blocking_session_id = 0)
--   GROUP BY runtime
-- )
-- SELECT *, 
--   CASE 
--     WHEN (SELECT COUNT(*) FROM tbl_RUNTIMES (NOLOCK) AS r WHERE r.runtime >= blocking_start AND r.runtime < blocking_end) > 1 
--     THEN DATEDIFF (s, blocking_start, blocking_end) 
--     ELSE 
--      (SELECT MAX (wait_duration_ms) FROM vw_BLOCKING_HIERARCHY h 
--       WHERE h.runtime >= blocking_start AND h.runtime < blocking_end) / 1000
--   END AS blocking_duration_sec
-- FROM BlockingPeriodsRaw ch1
-- WHERE NOT EXISTS 
--   (SELECT * FROM BlockingPeriodsRaw ch2 
--    WHERE ch2.blocking_start < ch1.blocking_start AND ch1.blocking_end = ch2.blocking_end)
-- GO

IF NOT EXISTS (SELECT * FROM sys.columns WHERE [object_id] = OBJECT_ID ('tbl_OS_WAIT_STATS') AND name = 'wait_category') 
  ALTER TABLE tbl_OS_WAIT_STATS
  ADD wait_category AS CASE 
    WHEN wait_type LIKE 'LCK%' THEN 'Locks'
    WHEN wait_type LIKE 'PAGEIO%' THEN 'Page I/O Latch'
    WHEN wait_type LIKE 'PAGELATCH%' THEN 'Page Latch (non-I/O)'
    WHEN wait_type LIKE 'LATCH%' THEN 'Latch (non-buffer)'
    WHEN wait_type LIKE 'IO_COMPLETION' THEN 'I/O Completion'
    WHEN wait_type LIKE 'ASYNC_NETWORK_IO' THEN 'Network I/O (client fetch)'
    --WHEN wait_type LIKE 'CLR_%' OR wait_type LIKE 'SQLCLR%' THEN 'SQLCLR'
    WHEN wait_type IN ('RESOURCE_SEMAPHORE', 'SOS_RESERVEDMEMBLOCKLIST') THEN 'Memory'
    WHEN wait_type LIKE 'RESOURCE_SEMAPHORE_%' OR wait_type = 'CMEMTHREAD' THEN 'Compilation'
    WHEN wait_type LIKE 'MSQL_XP' THEN 'XProc'
    WHEN wait_type LIKE 'WRITELOG' THEN 'Writelog'
    WHEN wait_type IN ('WAITFOR', 'LAZYWRITER_SLEEP', 'SQLTRACE_BUFFER_FLUSH', 'CXPACKET', 'EXCHANGE', 
      'REQUEST_FOR_DEADLOCK_SEARCH', 'KSOURCE_WAKEUP', 'BROKER_TRANSMITTER', 'BROKER_EVENTHANDLER', 'BROKER_RECEIVE_WAITFOR', 
      'BROKER_TASK_STOP', 'ONDEMAND_TASK_QUEUE', 'CHKPT', 'DBMIRROR_WORKER_QUEUE', 'DBMIRRORING_CMD',
	'SLEEP_TASK', 'CLR_MANUAL_EVENT', 'CLR_AUTO_EVENT'
	) --, 'DBMIRROR_DBM_EVENT') -- , 'SOS_SCHEDULER_YIELD') 
      THEN 'IGNORABLE'
    ELSE wait_type 
  END 
GO

IF NOT EXISTS (SELECT * FROM sys.columns WHERE [object_id] = OBJECT_ID ('tbl_REQUESTS') AND name = 'wait_category') 
  ALTER TABLE tbl_REQUESTS
  ADD wait_category AS CASE 
    WHEN wait_type LIKE 'LCK%' THEN 'Locks'
    WHEN wait_type LIKE 'PAGEIO%' THEN 'Page I/O Latch'
    WHEN wait_type LIKE 'PAGELATCH%' THEN 'Page Latch (non-I/O)'
    WHEN wait_type LIKE 'LATCH%' THEN 'Latch (non-buffer)'
    WHEN wait_type LIKE 'IO_COMPLETION' THEN 'I/O Completion'
    WHEN wait_type LIKE 'ASYNC_NETWORK_IO' THEN 'Network I/O (client fetch)'
    WHEN wait_type LIKE 'CLR_%' or wait_type like 'SQLCLR%' THEN 'SQLCLR'
    WHEN wait_type IN ('RESOURCE_SEMAPHORE', 'SOS_RESERVEDMEMBLOCKLIST') THEN 'Memory'
    WHEN wait_type LIKE 'RESOURCE_SEMAPHORE_%' OR wait_type = 'CMEMTHREAD' THEN 'Compilation'
    WHEN wait_type LIKE 'MSQL_XP' THEN 'XProc'
    WHEN wait_type LIKE 'WRITELOG' THEN 'Writelog'
    WHEN wait_type IN ('WAITFOR', 'LAZYWRITER_SLEEP', 'SQLTRACE_BUFFER_FLUSH', 'CXPACKET', 'EXCHANGE', 
      'REQUEST_FOR_DEADLOCK_SEARCH', 'KSOURCE_WAKEUP', 'BROKER_TRANSMITTER', 'BROKER_EVENTHANDLER', 'BROKER_RECEIVE_WAITFOR', 
      'ONDEMAND_TASK_QUEUE', 'CHKPT', 'DBMIRROR_WORKER_QUEUE', 'DBMIRRORING_CMD', 'DBMIRROR_DBM_EVENT',
	'CLR_MANUAL_EVENT', 'CLR_AUTO_EVENT') --, 'SOS_SCHEDULER_YIELD') 
      THEN 'IGNORABLE'
    ELSE wait_type 
  END 
GO

IF OBJECT_ID ('vw_WAIT_CATEGORY_STATS') IS NOT NULL DROP VIEW vw_WAIT_CATEGORY_STATS
GO
CREATE VIEW vw_WAIT_CATEGORY_STATS AS 
SELECT 
  runtime,
  wait_category, 
  SUM (ISNULL (waiting_tasks_count, 0)) AS waiting_tasks_count, 
  SUM (ISNULL (wait_time_ms, 0)) AS wait_time_ms, 
  SUM (ISNULL (signal_wait_time_ms, 0)) AS signal_wait_time_ms, 
  MAX (ISNULL (max_wait_time_ms, 0)) AS max_wait_time_ms
FROM dbo.tbl_OS_WAIT_STATS (NOLOCK) 
WHERE wait_category != 'IGNORABLE'
GROUP BY runtime, wait_category
GO

/* ============ Nexus Reporting DataSet Queries ============ */
-- Naming convention: DataSet_ReportName_ReportItem
IF OBJECT_ID ('DataSet_WaitStatsMain_WaitStatsChart') IS NOT NULL DROP PROC DataSet_WaitStatsMain_WaitStatsChart
GO
CREATE PROC DataSet_WaitStatsMain_WaitStatsChart @StartTime datetime='19000101', @EndTime datetime='29990101' AS 
IF @StartTime IS NULL OR @StartTime = '19000101' 
  SELECT  @StartTime = MIN (runtime) FROM vw_PERF_STATS_SCRIPT_RUNTIMES
IF @EndTime IS NULL OR @EndTime = '29990101' 
  SELECT  @EndTime = MAX (runtime) FROM vw_PERF_STATS_SCRIPT_RUNTIMES

SELECT 
  MIN (w1.runtime) AS interval_start, 
  MAX (w2.runtime) AS interval_end, 
  w2.wait_category, 
  CONVERT (decimal (28,3), MAX (w2.wait_time_ms) - MIN (w1.wait_time_ms) + 0.001) AS wait_time_ms, 
  CONVERT (decimal (28,3), MAX (w2.wait_time_ms) - MIN (w1.wait_time_ms) + 0.001)
    / CASE WHEN DATEDIFF (s, MIN (w1.runtime), MAX (w2.runtime)) = 0 THEN 1 ELSE DATEDIFF (s, MIN (w1.runtime), MAX (w2.runtime)) END AS wait_time_per_sec, 
  CONVERT (decimal (28,3), MAX (w2.waiting_tasks_count) - MIN (w1.waiting_tasks_count)) + 0.001 AS wait_count
FROM vw_WAIT_CATEGORY_STATS w2
LEFT OUTER JOIN vw_WAIT_CATEGORY_STATS w1 ON w1.wait_category = w2.wait_category
  AND w1.runtime = (SELECT TOP 1 runtime FROM tbl_OS_WAIT_STATS w3 WHERE w3.runtime < w2.runtime ORDER BY w3.runtime DESC)
WHERE w2.wait_category IN ('Locks', 'Page I/O Latch', 'Page Latch (non-I/O)', 'Latch (non-buffer)', 'I/O Completion', 
    'Network I/O (client fetch)', 'Writelog', 'Compilation', 'Memory', 'OLEDB')
  AND w2.runtime >= @StartTime
  AND w2.runtime <= @EndTime
GROUP BY w2.wait_category, DATEDIFF (ss, '20000101', w2.runtime) / (DATEDIFF (s, @StartTime, @EndTime) / 50 + 1)
HAVING MIN (w1.runtime) IS NOT NULL
ORDER BY MIN (w2.runtime)
GO

IF OBJECT_ID ('DataSet_WaitStats_WaitStatsTop5Categories') IS NOT NULL DROP PROC DataSet_WaitStats_WaitStatsTop5Categories
GO
CREATE PROC DataSet_WaitStats_WaitStatsTop5Categories @StartTime datetime='19000101', @EndTime datetime='29990101' AS 
SET NOCOUNT ON
-- DECLARE @StartTime datetime
-- DECLARE @EndTime datetime
IF (@StartTime IS NOT NULL AND @StartTime != '19000101') SELECT @StartTime = MAX (runtime) FROM tbl_OS_WAIT_STATS WHERE runtime <= @StartTime 
IF (@StartTime IS NULL OR @StartTime = '19000101') SELECT @StartTime = MIN (runtime) FROM tbl_OS_WAIT_STATS

IF (@EndTime IS NOT NULL AND @EndTime != '29990101') SELECT @EndTime = MIN (runtime) FROM tbl_OS_WAIT_STATS WHERE runtime >= @EndTime 
IF (@EndTime IS NULL OR @EndTime = '29990101') SELECT @EndTime = MAX (runtime) FROM tbl_OS_WAIT_STATS

-- Get basic wait stats for the specified interval
SELECT 
  w_end.wait_category, 
  (CONVERT (bigint, w_end.wait_time_ms) - CASE WHEN w_start.wait_time_ms IS NULL THEN 0 ELSE w_start.wait_time_ms END) AS total_wait_time_ms, 
  (CONVERT (bigint, w_end.wait_time_ms) - CASE WHEN w_start.wait_time_ms IS NULL THEN 0 ELSE w_start.wait_time_ms END) / (DATEDIFF (s, @StartTime, @EndTime) + 1) AS wait_time_ms_per_sec
INTO #waitstats_categories
FROM vw_WAIT_CATEGORY_STATS w_end
LEFT OUTER JOIN vw_WAIT_CATEGORY_STATS w_start ON w_end.wait_category = w_start.wait_category AND w_start.runtime = @StartTime
WHERE w_end.runtime = @EndTime
  AND w_end.wait_category != 'IGNORABLE'
ORDER BY (w_end.wait_time_ms - CASE WHEN w_start.wait_time_ms IS NULL THEN 0 ELSE w_start.wait_time_ms END) DESC

-- Get number of available "CPU seconds" in the specified interval (seconds in collection interval times # CPUs on the system)
DECLARE @avail_cpu_time_sec int 
SELECT @avail_cpu_time_sec = (SELECT TOP 1 cpu_count FROM tbl_SYSINFO) * DATEDIFF (s, @StartTime, @EndTime)

-- Get average % CPU utilization (this is the % of all CPUs on the box, ignoring affinity mask)
DECLARE @avg_sql_cpu int 
SELECT @avg_sql_cpu = AVG (sql_cpu_utilization) 
FROM (
  SELECT DISTINCT (SELECT TOP 1 EventTime FROM  tbl_SQL_CPU_HEALTH cpu2 WHERE cpu1.record_id = cpu2.record_id) AS EventTime, 
    record_id, system_idle_cpu, sql_cpu_utilization, 100 - sql_cpu_utilization - system_idle_cpu AS nonsql_cpu_utilization 
  FROM tbl_SQL_CPU_HEALTH cpu1
  WHERE EventTime BETWEEN @StartTime AND @EndTime
) AS sql_cpu

DECLARE @cpu_time_used_ms bigint
SET @cpu_time_used_ms = ISNULL ((0.01 * @avg_sql_cpu) * @avail_cpu_time_sec * 1000, 0)  -- CPU time used by SQL = (%CPU used by SQL) * (available CPU time)

-- Get total wait time for the specified interval
DECLARE @all_resources_wait_time_ms bigint
SELECT @all_resources_wait_time_ms = SUM (total_wait_time_ms) FROM #waitstats_categories
SET @all_resources_wait_time_ms = @all_resources_wait_time_ms + @cpu_time_used_ms

--this will prevent division by zero errors (bug 2119)
if @all_resources_wait_time_ms is null or @all_resources_wait_time_ms=0
begin
	
	return
end


-- Return stats for base wait categories
SELECT * FROM 
( SELECT TOP 5 
    cat.wait_category, 
    DATEDIFF (s, @StartTime, @EndTime) AS time_interval_sec, 
    CONVERT (bigint, cat.total_wait_time_ms) AS total_wait_time_ms, 
    CONVERT (numeric(6,2), 100.0*CONVERT (bigint, cat.total_wait_time_ms)/@all_resources_wait_time_ms) AS percent_of_total_waittime, 
    cat.wait_time_ms_per_sec 
  FROM #waitstats_categories cat
  WHERE (cat.wait_time_ms_per_sec > 0 OR cat.total_wait_time_ms > 0)
    AND cat.wait_category != 'SOS_SCHEDULER_YIELD' -- don't include "waiting on CPU" time here; we'll include it in the next query
  ORDER BY wait_time_ms_per_sec DESC
) t
WHERE percent_of_total_waittime > 0
UNION ALL 
-- Add SOS_SCHEDULER_YIELD wait time (waiting to run on a CPU) to actual used CPU time to synthesize a "CPU" wait category
SELECT 
  'CPU' AS wait_category, 
  DATEDIFF (s, @StartTime, @EndTime) AS time_interval_sec, 
  CONVERT (bigint, total_wait_time_ms) + @cpu_time_used_ms AS total_wait_time_ms, 
  100.0*(CONVERT (bigint, total_wait_time_ms) + @cpu_time_used_ms)/@all_resources_wait_time_ms AS percent_of_total_waittime, 
  wait_time_ms_per_sec + (@cpu_time_used_ms / (DATEDIFF (s, @StartTime, @EndTime) + 1)) AS wait_time_ms_per_sec
FROM #waitstats_categories cat
WHERE cat.wait_category = 'SOS_SCHEDULER_YIELD'
UNION ALL 
-- Add in an "other" category
SELECT * FROM 
( SELECT 
    'Other' AS wait_category, 
    DATEDIFF (s, @StartTime, @EndTime) AS time_interval_sec, 
    SUM (CONVERT (bigint, cat.total_wait_time_ms)) AS total_wait_time_ms, 
    CONVERT (numeric(6,2), 100.0*SUM (CONVERT (bigint, cat.total_wait_time_ms))/@all_resources_wait_time_ms) AS percent_of_total_waittime, 
    SUM (cat.wait_time_ms_per_sec) AS wait_time_ms_per_sec
  FROM #waitstats_categories cat
  WHERE (cat.wait_time_ms_per_sec > 0 OR cat.total_wait_time_ms > 0) 
    -- don't include the categories that we are already identifying in the top 5 
    AND cat.wait_category NOT IN (SELECT TOP 5 cat.wait_category FROM #waitstats_categories cat ORDER BY wait_time_ms_per_sec DESC) 
) AS t
WHERE percent_of_total_waittime > 0
ORDER BY wait_time_ms_per_sec DESC
GO


IF OBJECT_ID ('DataSet_WaitStats_BlockingChains') IS NOT NULL DROP PROC DataSet_WaitStats_BlockingChains
GO
CREATE PROC DataSet_WaitStats_BlockingChains @StartTime datetime='19000101', @EndTime datetime='29990101' AS 
IF @StartTime IS NULL OR @StartTime = '19000101' 
  SELECT  @StartTime = MIN (runtime) FROM vw_PERF_STATS_SCRIPT_RUNTIMES
IF @EndTime IS NULL OR @EndTime = '29990101' 
  SELECT  @EndTime = MAX (runtime) FROM vw_PERF_STATS_SCRIPT_RUNTIMES

SELECT * 
FROM dbo.vw_BLOCKING_CHAINS
WHERE blocking_duration_sec > 0
  AND (blocking_start BETWEEN @StartTime AND @EndTime) 
  OR (blocking_end BETWEEN @StartTime AND @EndTime)
GO

select convert (varchar, getdate(), 126)

IF OBJECT_ID ('DataSet_BlockingChain_BlockingChainAllRuntimes') IS NOT NULL DROP PROC DataSet_BlockingChain_BlockingChainAllRuntimes
GO
CREATE PROC DataSet_BlockingChain_BlockingChainAllRuntimes @BlockingChainRowNum int AS 
  SELECT CONVERT (varchar, r.runtime, 121) AS runtime, CONVERT (varchar, r.runtime, 126) AS runtime_locale_insensitive, r.task_state, 
    LEFT (r.wait_category, 35) AS wait_category, r.wait_duration_ms, r.request_total_elapsed_time AS request_elapsed_time, 
    blk.blocked_task_count AS blocked_tasks, r.command, LEFT (ch.stmt_text, 20) + '...' AS query
  FROM vw_BLOCKING_CHAINS ch 
  INNER JOIN tbl_REQUESTS r ON r.session_id = ch.head_blocker_session_id_orig AND r.runtime BETWEEN ch.blocking_start AND ch.blocking_end
  INNER JOIN tbl_HEADBLOCKERSUMMARY blk ON ch.head_blocker_session_id_orig = blk.head_blocker_session_id AND blk.runtime = r.runtime
  WHERE ch.first_rownum = @BlockingChainRowNum
  ORDER BY r.runtime
GO

IF OBJECT_ID ('DataSet_BlockingChain_BlockingChainTextSummary') IS NOT NULL DROP PROC DataSet_BlockingChain_BlockingChainTextSummary 
GO
CREATE PROC DataSet_BlockingChain_BlockingChainTextSummary @BlockingChainRowNum int AS 
  DECLARE @txtout varchar(max)
  DECLARE @runtime char(31), @task_state char(16), @wait_category char(36), @wait_duration_ms char(21)
  DECLARE @request_elapsed_time char(21), @blocked_tasks char(14), @command char(17), @query char(24)
  SELECT TOP 1 @txtout = 
    'BLOCKING CHAIN STATISTICS:' + CHAR(13) + CHAR(10) + 
    '  Head Blocker Session ID: ' + CONVERT (char(40), head_blocker_session_id) + CHAR(13) + CHAR(10) + 
    '  Blocking Duration (sec): ' + CONVERT (char(40), blocking_duration_sec) + CHAR(13) + CHAR(10) +  
    '           Max Chain Size: ' + CONVERT (char(40), max_blocked_task_count, 121) + CHAR (13) + CHAR(10) +
    '           Blocking Start: ' + CONVERT (char(40), blocking_start, 121) + CHAR (13) + CHAR(10) + 
    '             Blocking End: ' + CONVERT (char(40), blocking_end, 121) + CHAR (13) + CHAR(10) + 
    CHAR (13) + CHAR(10) +
    'HEAD BLOCKER:' + CHAR(13) + CHAR(10) + 
    '   Program Name: ' + CONVERT (char(40), program_name)                  + '         Transaction Name: ' + CONVERT (char(40), tran_name) + CHAR(13) + CHAR(10) + 
    '      Host Name: ' + CONVERT (char(40), [host_name])                   + 'Transaction Isolation Lvl: ' + CONVERT (char(40), transaction_isolation_level) + CHAR(13) + CHAR(10) + 
    '     Login Name: ' + CONVERT (char(40), login_name)                    + '   Transaction Begin Time: ' + CONVERT (char(40), transaction_begin_time, 121) + CHAR(13) + CHAR(10)
  FROM dbo.vw_BLOCKING_CHAINS
  WHERE first_rownum = @BlockingChainRowNum

  SET @txtout = @txtout + CHAR(13) + CHAR(10)
  SET @txtout = @txtout + 'HEAD BLOCKER RUNTIME SUMMARY:' + CHAR(13) + CHAR(10)
  SET @txtout = @txtout + '  runtime                        task_state      wait_category                       wait_duration_ms     request_elapsed_time blocked_tasks command          query                   ' + CHAR(13) + CHAR(10)
  SET @txtout = @txtout + '  ------------------------------ --------------- ----------------------------------- -------------------- -------------------- ------------- ---------------- ----------------------- ' + CHAR(13) + CHAR(10)
  DECLARE c CURSOR FOR 
  SELECT CONVERT (varchar, r.runtime, 121) AS runtime, r.task_state, LEFT (r.wait_category, 35) AS wait_category, r.wait_duration_ms, r.request_total_elapsed_time AS request_elapsed_time, 
    blk.blocked_task_count AS blocked_tasks, r.command, LEFT (ch.stmt_text, 20) + '...' AS query
  FROM vw_BLOCKING_CHAINS ch 
  INNER JOIN tbl_REQUESTS r ON r.session_id = ch.head_blocker_session_id_orig AND r.runtime BETWEEN ch.blocking_start AND ch.blocking_end
  INNER JOIN tbl_HEADBLOCKERSUMMARY blk ON ch.head_blocker_session_id_orig = blk.head_blocker_session_id AND blk.runtime = r.runtime
  WHERE ch.first_rownum = @BlockingChainRowNum
  ORDER BY r.runtime
  OPEN c
  FETCH NEXT FROM c INTO @runtime, @task_state, @wait_category, @wait_duration_ms, @request_elapsed_time, @blocked_tasks, @command, @query
  WHILE (@@FETCH_STATUS<>-1) BEGIN
    SET @txtout = @txtout + '  ' + @runtime + @task_state + @wait_category + @wait_duration_ms + @request_elapsed_time + @blocked_tasks + @command + @query + CHAR(13) + CHAR(10)
    FETCH NEXT FROM c INTO @runtime, @task_state, @wait_category, @wait_duration_ms, @request_elapsed_time, @blocked_tasks, @command, @query
  END
  CLOSE c
  DEALLOCATE c
  SELECT REPLACE (REPLACE (@txtout, '/', '_'), '\', '_') AS summary
GO

IF OBJECT_ID ('DataSet_BlockingChain_HeadBlockerSampleRuntime') IS NOT NULL DROP PROC DataSet_BlockingChain_HeadBlockerSampleRuntime
GO
CREATE PROC DataSet_BlockingChain_HeadBlockerSampleRuntime @BlockingChainRowNum int AS 
  SELECT r.*, q.* FROM tbl_REQUESTS r
  INNER JOIN vw_BLOCKING_CHAINS ch ON ch.first_rownum = @BlockingChainRowNum AND ch.head_blocker_session_id_orig = r.session_id
  LEFT OUTER JOIN tbl_NOTABLEACTIVEQUERIES q ON q.session_id = ch.head_blocker_session_id_orig AND q.runtime = r.runtime 
  WHERE r.runtime = ( -- attempt to find the "worst" example runtime for this chain
      SELECT TOP 1 runtime FROM vw_HEAD_BLOCKER_SUMMARY b 	-- attempt to find the "worst" example runtime for this chain
      WHERE ch.head_blocker_session_id =  b.head_blocker_session_id AND ch.blocking_wait_type = b.blocking_wait_type
        AND b.runtime >= ch.blocking_start AND b.runtime < ch.blocking_end 
      ORDER BY b.blocked_task_count * 4 + b.tot_wait_duration_ms / 1000 DESC
    )
  ORDER BY r.session_id
GO

IF OBJECT_ID ('DataSet_BlockingChain_BlockingChainDetails') IS NOT NULL DROP PROC DataSet_BlockingChain_BlockingChainDetails
GO
CREATE PROC DataSet_BlockingChain_BlockingChainDetails @BlockingChainRowNum int AS 
SELECT TOP 1 * 
FROM dbo.vw_BLOCKING_CHAINS
WHERE first_rownum = @BlockingChainRowNum 
GO

IF OBJECT_ID ('DataSet_Shared_SQLServerName') IS NOT NULL DROP PROC DataSet_Shared_SQLServerName
GO
CREATE PROC DataSet_Shared_SQLServerName @script_name varchar(80) = null, @name varchar(60) = null AS 
IF OBJECT_ID ('tbl_SCRIPT_ENVIRONMENT_DETAILS') IS NOT NULL
  SELECT [Value]
  FROM tbl_SCRIPT_ENVIRONMENT_DETAILS
  WHERE script_name = 'SQL 2005 Perf Stats Script'
    AND [Name] = 'SQL Server Name'
ELSE 
  SELECT @@SERVERNAME AS [value]
  -- SELECT @@SERVERNAME AS [value]
GO


IF OBJECT_ID ('DataSet_Shared_SQLVersion') IS NOT NULL DROP PROC DataSet_Shared_SQLVersion
GO
CREATE PROC DataSet_Shared_SQLVersion @script_name varchar(80) = null, @name varchar(60) = null AS 
IF OBJECT_ID ('tbl_SCRIPT_ENVIRONMENT_DETAILS') IS NOT NULL
  SELECT [value]
  FROM tbl_SCRIPT_ENVIRONMENT_DETAILS
  WHERE script_name = 'SQL 2005 Perf Stats Script'
    AND [Name] = 'SQL Version (SP)'
ELSE
  SELECT '' AS [value]
  -- SELECT CONVERT (varchar, SERVERPROPERTY ('ProductVersion')) + ' (' + CONVERT (varchar, SERVERPROPERTY ('ProductLevel')) + ')' AS [value]
GO

IF OBJECT_ID ('DataSet_WaitStats_ParamStartTime') IS NOT NULL DROP PROC DataSet_WaitStats_ParamStartTime
GO
CREATE PROC DataSet_WaitStats_ParamStartTime AS 
DECLARE @StartTime datetime
DECLARE @EndTime datetime
SELECT @StartTime = MIN (runtime) FROM vw_PERF_STATS_SCRIPT_RUNTIMES
SELECT @EndTime = MAX (runtime) FROM vw_PERF_STATS_SCRIPT_RUNTIMES
IF @StartTime IS NULL SET @StartTime = GETDATE()
IF @EndTime IS NULL SET @EndTime = GETDATE()

SELECT 
  CASE 
    WHEN DATEDIFF (mi, @StartTime, @EndTime) > 4*60 THEN DATEADD (mi, -60, @EndTime)
    ELSE @StartTime
  END AS StartTime
UNION ALL
SELECT @StartTime 
UNION ALL
SELECT @EndTime 
GO

IF OBJECT_ID ('DataSet_WaitStats_ParamEndTime') IS NOT NULL DROP PROC DataSet_WaitStats_ParamEndTime
GO
CREATE PROC DataSet_WaitStats_ParamEndTime AS 
DECLARE @StartTime datetime
DECLARE @EndTime datetime
SELECT @StartTime = MIN (runtime) FROM vw_PERF_STATS_SCRIPT_RUNTIMES
SELECT @EndTime = MAX (runtime) FROM vw_PERF_STATS_SCRIPT_RUNTIMES
IF @StartTime IS NULL SET @StartTime = GETDATE()
IF @EndTime IS NULL SET @EndTime = GETDATE()

SELECT @EndTime AS EndTime 
UNION ALL
SELECT @StartTime AS EndTime 
UNION ALL
SELECT @EndTime AS EndTime 
GO


/* ============ End Nexus Reporting DataSet Queries ============ */


IF NOT EXISTS (SELECT * FROM sysindexes WHERE [id] = OBJECT_ID ('tbl_NOTABLEACTIVEQUERIES') AND name = 'idx1') BEGIN 
  RAISERROR ('Creating index 1 of 7', 0, 1) WITH NOWAIT
  CREATE NONCLUSTERED INDEX idx1 ON dbo.tbl_NOTABLEACTIVEQUERIES (runtime, session_id, procname) INCLUDE (stmt_text)
END
IF NOT EXISTS (SELECT * FROM sysindexes WHERE [id] = OBJECT_ID ('tbl_HEADBLOCKERSUMMARY') AND name = 'idx1') 
  AND EXISTS (SELECT * FROM syscolumns WHERE [id] = OBJECT_ID ('tbl_HEADBLOCKERSUMMARY') AND name = 'wait_type') 
  BEGIN 
  RAISERROR ('Creating index 2 of 7', 0, 1) WITH NOWAIT
  CREATE NONCLUSTERED INDEX idx1 ON dbo.tbl_HEADBLOCKERSUMMARY (runtime, head_blocker_session_id, wait_type, blocked_task_count) 
    INCLUDE (rownum, tot_wait_duration_ms, avg_wait_duration_ms, max_wait_duration_ms, max_blocking_chain_depth)
END
GO
IF NOT EXISTS (SELECT * FROM sysindexes WHERE [id] = OBJECT_ID ('tbl_HEADBLOCKERSUMMARY') AND name = 'idx1') 
  AND EXISTS (SELECT * FROM syscolumns WHERE [id] = OBJECT_ID ('tbl_HEADBLOCKERSUMMARY') AND name = 'blocking_resource_wait_type') 
  BEGIN 
  RAISERROR ('Creating index 2 of 7', 0, 1) WITH NOWAIT
  CREATE NONCLUSTERED INDEX idx1 ON dbo.tbl_HEADBLOCKERSUMMARY (runtime, head_blocker_session_id, blocking_resource_wait_type, blocked_task_count) 
    INCLUDE (rownum, tot_wait_duration_ms, avg_wait_duration_ms, max_wait_duration_ms, max_blocking_chain_depth)
END
GO
IF NOT EXISTS (SELECT * FROM sysindexes WHERE [id] = OBJECT_ID ('tbl_REQUESTS') AND name = 'idx1') BEGIN 
  RAISERROR ('Creating index 3 of 7', 0, 1) WITH NOWAIT
  CREATE NONCLUSTERED INDEX idx1 ON [dbo].[tbl_REQUESTS] (runtime, session_id, program_name, [host_name], nt_user_name, nt_domain, login_name) 
END
GO
IF NOT EXISTS (SELECT * FROM sysindexes WHERE [id] = OBJECT_ID ('tbl_REQUESTS') AND name = 'idx2') BEGIN 
  RAISERROR ('Creating index 4 of 7', 0, 1) WITH NOWAIT
  CREATE NONCLUSTERED INDEX idx2 ON [dbo].[tbl_REQUESTS] (runtime, blocking_session_id, session_id) 
END
GO
IF NOT EXISTS (SELECT * FROM sysindexes WHERE [id] = OBJECT_ID ('tbl_REQUESTS') AND name = 'idx3') BEGIN 
  RAISERROR ('Creating index 5 of 7', 0, 1) WITH NOWAIT
  CREATE NONCLUSTERED INDEX idx3 ON [dbo].[tbl_REQUESTS] (blocking_session_id, runtime, wait_type, wait_resource) 
END
GO
IF NOT EXISTS (SELECT * FROM sysindexes WHERE [id] = OBJECT_ID ('tbl_REQUESTS') AND name = 'idx4') BEGIN 
  RAISERROR ('Creating index 6 of 7', 0, 1) WITH NOWAIT
  CREATE NONCLUSTERED INDEX idx4 ON [dbo].[tbl_REQUESTS] (wait_category, wait_duration_ms DESC, wait_type, runtime, session_id)
END
GO
IF NOT EXISTS (SELECT * FROM sysindexes WHERE [id] = OBJECT_ID ('tbl_OS_WAIT_STATS') AND name = 'cidx') BEGIN 
  RAISERROR ('Creating index 7 of 7', 0, 1) WITH NOWAIT
  CREATE CLUSTERED INDEX cidx ON [dbo].[tbl_OS_WAIT_STATS] (runtime, wait_category) 
END
GO
IF NOT EXISTS (SELECT * FROM sysindexes WHERE [id] = OBJECT_ID ('tbl_RUNTIMES') AND name = 'cidx') BEGIN 
  RAISERROR ('Creating index 8 of 8', 0, 1) WITH NOWAIT
  CREATE CLUSTERED INDEX cidx ON [dbo].[tbl_RUNTIMES] (runtime, source_script) 
END
GO
IF NOT EXISTS (SELECT * FROM sysindexes WHERE [id] = OBJECT_ID ('tbl_REQUESTS') AND name = 'stats1') BEGIN 
  CREATE STATISTICS stats1 ON [dbo].[tbl_REQUESTS] (runtime, wait_duration_ms) 
END
GO
/* ========== END ANALYSIS HELPER OBJECTS ========== */
 




/* ========== BEGIN ANALYSIS QUERIES ========== */

IF '%runmode%' != 'REALTIME' BEGIN
  IF OBJECT_ID ('tbl_SCRIPT_ENVIRONMENT_DETAILS') IS NOT NULL BEGIN
    PRINT ''
    PRINT '==== Script Environment Details ====';
    SELECT [Name], [Value] FROM tbl_SCRIPT_ENVIRONMENT_DETAILS WHERE script_name = 'SQL 2005 Perf Stats Script'
  END
END
GO

IF '%runmode%' != 'REALTIME' BEGIN
  PRINT ''
  PRINT '==== Waitstats Resource Bottleneck Analysis ====';
  SELECT TOP 10 
     wait_category, 
    (MAX(wait_time_ms) - MIN(wait_time_ms)) AS wait_time_ms, 
    (MAX(wait_time_ms) - MIN(wait_time_ms)) / (1 + DATEDIFF (s, MIN(runtime), MAX(runtime))) AS wait_time_per_sec, 
    (MAX(waiting_tasks_count) - MIN(waiting_tasks_count)) AS wait_count, 
    (MAX(wait_time_ms) - MIN(wait_time_ms)) / 
       CASE (MAX(waiting_tasks_count) - MIN(waiting_tasks_count)) WHEN 0 THEN 1
       ELSE ((MAX(waiting_tasks_count) - MIN(waiting_tasks_count))) END AS average_wait_time_ms, 
    MAX(max_wait_time_ms) AS max_wait_time_ms 
  FROM vw_WAIT_CATEGORY_STATS
  WHERE wait_category != 'IGNORABLE'
  GROUP BY wait_category
  ORDER BY (MAX(wait_time_ms) - MIN(wait_time_ms)) DESC
END
GO

IF '%runmode%' != 'REALTIME' BEGIN
  DECLARE @wait_category_num int
  DECLARE @wait_category varchar(90)
  SET @wait_category_num = 1
  DECLARE c CURSOR FOR 
    SELECT wait_category FROM vw_WAIT_CATEGORY_STATS 
    WHERE wait_category != 'IGNORABLE'
    GROUP BY wait_category 
    ORDER BY (MAX(wait_time_ms) - MIN(wait_time_ms)) DESC 
  OPEN c
  FETCH NEXT FROM c INTO @wait_category
  WHILE (@@FETCH_STATUS = 0)
  BEGIN
    RAISERROR ('==== Top 10 longest individual waits for the "%s" wait category ====', 0, 1, @wait_category) WITH NOWAIT;
    SELECT TOP 10 * FROM tbl_REQUESTS (NOLOCK) AS r
    WHERE r.wait_category = @wait_category
    ORDER BY wait_duration_ms DESC
    FETCH NEXT FROM c INTO @wait_category
    SET @wait_category_num = @wait_category_num + 1
    IF @wait_category_num >= 3 BREAK
  END
  CLOSE c
  DEALLOCATE c
END
GO

IF '%runmode%' != 'REALTIME' BEGIN
  PRINT ''
  RAISERROR ('==== Top 10 Most Expensive Queries by CPU ====', 0, 1) WITH NOWAIT;
  SELECT TOP 10 MAX (ISNULL (plan_total_exec_count, 0)) AS exec_count, 
    MAX (ISNULL (plan_total_cpu_ms, 0)) AS total_cpu, 
    MAX (ISNULL (plan_total_duration_ms, 0)) AS total_duration, 
    MAX (ISNULL (plan_total_physical_reads, 0)) AS total_physical_reads,
    MAX (ISNULL (plan_total_Logical_writes, 0)) AS total_writes, 
    CAST (ISNULL (stmt_text, '') AS varchar(150)) AS stmt_text
  FROM tbl_NOTABLEACTIVEQUERIES (NOLOCK) 
  WHERE stmt_text IS NOT NULL
  GROUP BY stmt_text
  ORDER BY MAX (ISNULL (plan_total_cpu_ms, 0)) DESC
  PRINT '     Note: The query costs shown above were sampled from sys.dm_exec_query_stats. This is not
     as reliable as a trace, and may overlook some expensive queries or fail to aggregate the 
     cumulative costs of a query correctly.  Be cautious about drawing firm conclusions about 
     the most expensive query based on this data.'
  PRINT ''
END
GO

IF '%runmode%' != 'REALTIME' BEGIN
  IF NOT EXISTS (SELECT * FROM tbl_REQUESTS (NOLOCK) WHERE blocking_session_id != 0) BEGIN
    PRINT ''
    PRINT '     No blocking was detected.'
    PRINT ''
  END
END
GO

IF '%runmode%' != 'REALTIME' AND EXISTS (SELECT * FROM tbl_REQUESTS (NOLOCK) WHERE blocking_session_id != 0) BEGIN
  PRINT ''
  RAISERROR ('==== Top 10 Worst Blocking Chains ====', 0, 1) WITH NOWAIT;
  SELECT TOP 10 CONVERT (varchar, blocking_start, 121) AS blocking_start, 
    CONVERT (varchar, blocking_end, 121) AS blocking_end, 
    blocking_duration_sec, 
    max_blocked_task_count, 
    head_blocker_session_id, 
    blocking_wait_type, 
    max_wait_duration_ms 
  FROM vw_BLOCKING_CHAINS d1
  ORDER BY blocking_duration_sec DESC
END
GO
IF '%runmode%' != 'REALTIME' AND EXISTS (SELECT * FROM tbl_REQUESTS (NOLOCK) WHERE blocking_session_id != 0) BEGIN
  PRINT ''
  RAISERROR ('==== Top 10 Periods of Sustained Blocking ====', 0, 1) WITH NOWAIT;
  SELECT TOP 10 CONVERT (varchar, blocking_start, 121) AS blocking_start, 
    CONVERT (varchar, blocking_end, 121) AS blocking_end, 
    blocking_duration_sec, 
    max_blocked_task_count
  FROM vw_BLOCKING_PERIODS d1
  ORDER BY blocking_duration_sec DESC
END
GO
IF '%runmode%' != 'REALTIME' AND EXISTS (SELECT * FROM tbl_REQUESTS (NOLOCK) WHERE blocking_session_id != 0) BEGIN
  PRINT ''
  RAISERROR ('==== Top 10 Blocking Queries ====', 0, 1) WITH NOWAIT;
  SELECT TOP 10 
    COUNT(*) AS num_blocking_chains, 
    MAX (ISNULL (max_blocked_task_count, 0)) AS max_blocking_chain_size, 
    SUM (ISNULL (blocking_duration_sec, 0)) AS blocking_duration_sec, 
    MAX (ISNULL (max_wait_duration_ms, 0)) AS max_wait_duration_ms, 
    MIN (ISNULL (blocking_start, 0)) AS first_occurrence_runtime, 
    b.procname, 
    SUBSTRING (b.stmt_text, 1, 100) --, q.stmt_text
  FROM vw_BLOCKING_CHAINS b
--  LEFT OUTER JOIN tbl_NOTABLEACTIVEQUERIES q ON b.blocking_start = q.runtime AND b.head_blocker_session_id = q.session_id
  GROUP BY b.procname, SUBSTRING (b.stmt_text, 1, 100)
  ORDER BY MAX (max_blocked_task_count) * 4 + SUM (blocking_duration_sec) DESC
END
GO
IF '%runmode%' != 'REALTIME' AND EXISTS (SELECT * FROM tbl_REQUESTS (NOLOCK) WHERE blocking_session_id != 0) BEGIN
  PRINT ''
  RAISERROR ('==== Top 10 Blocking Programs ====', 0, 1) WITH NOWAIT;
  SELECT TOP 10 
    COUNT(*) AS num_blocking_chains, 
    MAX (ISNULL (max_blocked_task_count, 0)) AS max_blocking_chain_size, 
    SUM (ISNULL (blocking_duration_sec, 0)) AS blocking_duration_sec, 
    MAX (ISNULL (max_wait_duration_ms, 0)) AS max_wait_duration_ms, 
    MIN (ISNULL (blocking_start, 0)) AS first_occurrence_runtime, 
    program_name 
  FROM vw_BLOCKING_CHAINS b
  GROUP BY program_name
  ORDER BY MAX (max_blocked_task_count) * 4 + SUM (blocking_duration_sec) DESC
END
GO
IF '%runmode%' != 'REALTIME' AND EXISTS (SELECT * FROM tbl_REQUESTS (NOLOCK) WHERE blocking_session_id != 0) BEGIN
  PRINT ''
  RAISERROR ('==== Top 10 Blocking Host Workstations ====', 0, 1) WITH NOWAIT;
  SELECT TOP 10 
    COUNT(*) AS num_blocking_chains, 
    MAX (ISNULL (max_blocked_task_count, 0)) AS max_blocking_chain_size, 
    SUM (ISNULL (blocking_duration_sec, 0)) AS blocking_duration_sec, 
    MAX (ISNULL (max_wait_duration_ms, 0)) AS max_wait_duration_ms, 
    MIN (ISNULL (blocking_start, 0)) AS first_occurrence_runtime, 
    [host_name] 
  FROM vw_BLOCKING_CHAINS b
  GROUP BY [host_name]
  ORDER BY MAX (max_blocked_task_count) * 4 + SUM (blocking_duration_sec) DESC
END
GO
IF '%runmode%' != 'REALTIME' AND EXISTS (SELECT * FROM tbl_REQUESTS (NOLOCK) WHERE blocking_session_id != 0) BEGIN
  PRINT ''
  RAISERROR ('==== Top 10 Blocking NT Users ====', 0, 1) WITH NOWAIT;
  SELECT TOP 10 
    COUNT(*) AS num_blocking_chains, 
    MAX (ISNULL (max_blocked_task_count, 0)) AS max_blocking_chain_size, 
    SUM (ISNULL (blocking_duration_sec, 0)) AS blocking_duration_sec, 
    MAX (ISNULL (max_wait_duration_ms, 0)) AS max_wait_duration_ms, 
    MIN (ISNULL (blocking_start, 0)) AS first_occurrence_runtime, 
    ISNULL (nt_domain, '') + '\' + nt_user_name
  FROM vw_BLOCKING_CHAINS b
  GROUP BY ISNULL (nt_domain, '') + '\' + nt_user_name
  ORDER BY MAX (max_blocked_task_count) * 4 + SUM (blocking_duration_sec) DESC
END
GO
IF '%runmode%' != 'REALTIME' AND EXISTS (SELECT * FROM tbl_REQUESTS (NOLOCK) WHERE blocking_session_id != 0) BEGIN
  PRINT ''
  RAISERROR ('==== Top 10 Blocking SQL Logins ====', 0, 1) WITH NOWAIT;
  SELECT TOP 10 
    COUNT(*) AS num_blocking_chains, 
    MAX (ISNULL (max_blocked_task_count, 0)) AS max_blocking_chain_size, 
    SUM (ISNULL (blocking_duration_sec, 0)) AS blocking_duration_sec, 
    MAX (ISNULL (max_wait_duration_ms, 0)) AS max_wait_duration_ms, 
    MIN (ISNULL (blocking_start, 0)) AS first_occurrence_runtime, 
    login_name
    -- , (blocked_task_count) + (MAX (tot_wait_duration_ms) / 5000) AS [Weighted Blocking Chain Score]
  FROM vw_BLOCKING_CHAINS b
  GROUP BY login_name
  ORDER BY MAX (max_blocked_task_count) * 4 + SUM (blocking_duration_sec) DESC
END
GO
IF '%runmode%' != 'REALTIME' AND EXISTS (SELECT * FROM tbl_REQUESTS (NOLOCK) WHERE blocking_session_id != 0) BEGIN
  PRINT ''
  RAISERROR ('==== Top 10 Blocking Resources ====', 0, 1) WITH NOWAIT;
  SELECT TOP 10 COUNT(DISTINCT runtime) AS num_blocking_incidents, 
    COUNT (*) AS total_blocked_sessions, 
    MAX (wait_duration_ms) AS max_wait_duration_ms, 
    AVG (wait_duration_ms) AS avg_wait_duration_ms, 
    (SELECT TOP 1 CONVERT (varchar, runtime, 121) FROM vw_FIRSTTIERBLOCKINGHIERARCHY 
     WHERE first_tier_wait_resource = f.first_tier_wait_resource 
     GROUP BY runtime, first_tier_wait_resource
     ORDER BY (SUM (wait_duration_ms)/5000) + COUNT(*) DESC) AS example_runtime, 
    first_tier_wait_resource 
    -- , (SUM (wait_duration_ms)/5000) + COUNT(*) AS [Weighted Blocking Resource Score]
  FROM vw_FIRSTTIERBLOCKINGHIERARCHY f
  GROUP BY first_tier_wait_resource
  ORDER BY (SUM (wait_duration_ms)/5000) + COUNT(*) DESC
END
GO

-- Run this to view a particular tbl_requests snapshot (tbl_REQUESTS is like sysprocesses, but with a richer data set) 
--   SELECT * FROM tbl_REQUESTS (NOLOCK) AS r 
--   LEFT OUTER JOIN tbl_NOTABLEACTIVEQUERIES (NOLOCK) AS q ON r.runtime = q.runtime AND r.session_id = q.session_id 
--   WHERE r.runtime = '2006-08-15 13:25:31.550'
GO
 

IF OBJECT_ID ('GetTopNQueryHash') IS NOT NULL DROP PROC GetTopNQueryHash
go 
create procedure GetTopNQueryHash @OrderByCriteria nvarchar(20) = 'CPU'
as
declare @tableName nvarchar(50), @OrderName nvarchar(50), @DisplayValue nvarchar(100), @sql nvarchar(max)
if @OrderByCriteria = 'CPU'
begin
	set @tableName = 'tbl_TopNCPUByQueryHash'
	set @OrderName = 'total_worker_time'
	set @DisplayValue = 'total_worker_time'
end
else if (@OrderByCriteria = 'Duration')
begin
		set @tableName = 'tbl_TopNDurationByQueryHash'
	set @OrderName = 'total_elapsed_time'
	set @DisplayValue = 'total_elapsed_time'
end
else if (@OrderByCriteria = 'Logical Reads')
begin
		set @tableName = 'tbl_TopNLogicalReadsByQueryHash'
	set @OrderName = 'total_logical_reads'
	set @DisplayValue = 'total_logical_reads'
end


set @sql = 'select ROW_NUMBER() over (order by ' + @OrderName + ' desc) as ''rownumber'',  *, '+ @DisplayValue + ' as DisplayValue from '  + @tableName + ' order by ' + @OrderName + ' desc'
exec (@sql)

