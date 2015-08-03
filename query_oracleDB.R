## testing RODBC and RODBCext for query directly to Oracle via ODBC
## David DuPre 2015-08-03
library(RODBC)
library(RODBCext)

dm <- odbcConnect("DM",uid="hyp_ccc",pwd="password")

getdata <- function(entity_name, window_id, interval_id) {
        
        myvalues <- data.frame(entity_name, window_id ,
                               interval_id )
        
        rc_prep <- sqlPrepare(dm,"Select ENTITY_NAME,METRIC_NAME,AVG_VALUE,max_value,slope
                                                from Regression_values 
                                                where entity_name = ?
                                                and Window_id = ? 
                                                and interval_id = ?
                              ")
        rc_ex <- sqlExecute(dm,NULL,myvalues)
        output <- sqlGetResults(dm)
        return(output)
}

getlikedata <- function(entity_name, window_id, interval_id) {
        
        myvalues <- data.frame(entity_name, window_id ,
                               interval_id )
        
        rc_prep <- sqlPrepare(dm,"Select ENTITY_NAME,METRIC_NAME,AVG_VALUE,max_value,slope
                                                from Regression_values 
                                                where entity_name LIKE ?
                                                and Window_id = ? 
                                                and interval_id = ?
                              ")
        rc_ex <- sqlExecute(dm,NULL,myvalues)
        output <- sqlGetResults(dm)
        return(output)
}
mo <- getlikedata("mo%",0,-2)
moons <- getlikedata("%moons%",0,-2)
as  <- getlikedata("a%",0,-2)
