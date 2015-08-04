## testing RODBC and RODBCext for query directly to Oracle via ODBC
## David DuPre 2015-08-03
library(RODBC)
library(RODBCext)



## This function requires hard coded Entity_name to match and Window_id and Interval_id
## -- Returns a DataFrame
getdata <- function(entity_name, window_id=0, interval_id=90) {

        ## Setup the ODBC connection as 64bit using ODBCAdmin normal, not the SYSWOW version.
        dm <- odbcConnect("DM",uid="hyp_ccc",pwd="password")
                
        ## store replacements in a data.frame!
        
        myvalues <- data.frame(entity_name, window_id, interval_id )
        
        ## Just like Oracle uses the ? where a parameter should be replaced.
        
        rc_prep <- sqlPrepare(dm,"Select ENTITY_NAME,METRIC_NAME,AVG_VALUE,max_value,slope
                                                from Regression_values 
                                                where entity_name = ?
                                                and Window_id = ? 
                                                and interval_id = ?")
        
        ## Excecute the Prepared SQL "NULL" means used the sqlPrepare statement
        
        rc_ex <- sqlExecute(dm,NULL,myvalues)
        ## --- Put retults into output - is a DATAFRAME
        output <- sqlGetResults(dm)
        
        ## Close ODBC connection
        rc_close <- odbcClose(dm)
        
        return(output)
}

## This accepts an entity name for a LIKE where clause requries a "%" somewhere in the string.
## Returns a DATAFRAME
getlikedata <- function(entity_name, window_id=0, interval_id=90) {
        
        ## Setup the ODBC connection as 64bit using ODBCAdmin normal, not the SYSWOW version.
        dm <- odbcConnect("DM",uid="hyp_ccc",pwd="password")
        
        myvalues <- data.frame(entity_name) ##, 
                               ##window_id ,
                               ##interval_id )
        
        rc_prep <- sqlPrepare(dm,"Select ENTITY_NAME,METRIC_NAME,AVG_VALUE,max_value,slope
                                                from Regression_values 
                                                where entity_name LIKE ?
                                                --and Window_id = ? 
                                                --and interval_id = ?
                              ")
        rc_ex <- sqlExecute(dm,NULL,myvalues)
        output <- sqlGetResults(dm)
        
        ## Close ODBC connection
        rc_close <- odbcClose(dm)
        
        return(output)
}

## This returns the TableSpaceReport
## Returns a DATAFRAME
gettablespace <- function() {
        
        ## Setup the ODBC connection as 64bit using ODBCAdmin normal, not the SYSWOW version.
        dm <- odbcConnect("DM",uid="hyp_ccc",pwd="password")
        
        ##myvalues <- data.frame(entity_name) ##, 
        ##window_id ,
        ##interval_id )
        
        rc_prep <- sqlPrepare(dm,"
                                SELECT
                                NVL(b.tablespace_name, NVL(a.tablespace_name,'UNKNOWN')) TABLESPACE
                              , b.AutoExtensible AutoExtensible
                              , Mbytes_max Max_MB
                              , Mbytes_alloc Allocated_MB
                              , Mbytes_alloc-NVL(Mbytes_free,0) Used_MB
                              , NVL(Mbytes_free,0) Free_MB
                              , ROUND(((Mbytes_alloc-NVL(Mbytes_free,0))/Mbytes_alloc)*100,2) Used
                              , data_files Data_Files
                              FROM
                              (
                              SELECT
                              SUM(aa.bytes) /1024/1024 Mbytes_free
                              , MAX(aa.bytes) /1024/1024 largest
                              , aa.tablespace_name
                              , bb.AutoExtensible
                              FROM
                              sys.dba_free_space aa
                              , sys.dba_data_files bb
                              WHERE
                              aa.tablespace_name = bb.tablespace_name
                              AND aa.file_id       = bb.file_id
                              GROUP BY
                              aa.tablespace_name
                              , bb.AutoExtensible
                              )
                              a
                              , (
                              SELECT
                              SUM(bytes)/1024/1024 Mbytes_alloc
                              , SUM(
                              CASE
                              WHEN maxbytes > bytes
                              THEN maxbytes
                              ELSE bytes
                              END)/1024/1024 Mbytes_max
                              , tablespace_name
                              , AutoExtensible
                              , COUNT(*) data_files
                              FROM
                              sys.dba_data_files
                              GROUP BY
                              tablespace_name
                              , AutoExtensible
                              )
                              b
                              WHERE
                              a.tablespace_name (+)  = b.tablespace_name
                              AND a.AutoExtensible (+) = b.AutoExtensible
                              ORDER BY
                              1,2
                              ")
        rc_ex <- sqlExecute(dm,NULL)
        output <- sqlGetResults(dm)
        
        ## Close ODBC connection
        rc_close <- odbcClose(dm)
        
        return(output)
}






## These are some sample executions of the function
mo <- getlikedata("mo%",0,-2)
moons <- getlikedata("%moons%",0,-2)
as  <- getlikedata("a%",0,-2)
ts <- gettablespace()

## END



