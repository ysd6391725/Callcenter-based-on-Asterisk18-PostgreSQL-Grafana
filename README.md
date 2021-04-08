This is a simple callcenter based on Asterisk 16, PostgreSQL and Grafana

# Asterisk16-PostgreSQL-Grafana
![image](https://user-images.githubusercontent.com/73586088/113707049-2bc4a080-9701-11eb-9a48-5464f6d9a4d8.png)

# Description
[Asterisk16](https://hub.docker.com/repository/docker/6391725ysd/asterisk16-postgresql-odbc) 
 Based on:
 - Centos7 base images
 - Asterisk 16.16.2 built from source with postgresql-odbc. 

 [Grafana](https://hub.docker.com/repository/docker/6391725ysd/grafana)  
 Based on official image [grafana](https://hub.docker.com/r/grafana/grafana) 
 
  [PostgreSQL](https://hub.docker.com/repository/docker/6391725ysd/postgresql)  
 Based on official image [PostgreSQL](https://hub.docker.com/_/postgres) 
 
# Installation

Just pull and run:

    # Grafana 
    docker pull 6391725ysd/grafana
    docker run -d --name my_grafana -v /home/records/:/usr/share/grafana/public/build/records --net=host 6391725ysd/grafana
    
    # Asterisk 16
    docker pull 6391725ysd/asterisk16-postgresql-odbc
    docker run -d --name my_asterisk16 -v /home/records/:/var/spool/asterisk/monitor/ --net=host 6391725ysd/asterisk16-postgresql-odbc
    
    # PostgreSQL
    docker pull 6391725ysd/postgresql
    
    

Grafana default login anf password:
- admin
- Pa$$w0rd

# PostgreSQL tables structure

Database asteriskcdrdb consist of four tables: 
- cdr (all calls, incoming and outgoing)
- queue_log (incoming calls from queue)
- cdr_queue_log (incoming calls from queue)
- operators (list of operators with name and number)

An incoming call enters the queue, an entry is created in the queue_log table
![image](https://user-images.githubusercontent.com/73586088/113996119-ad8b0a00-9878-11eb-8310-dc9955c28b1d.png)

queue_log has a TRIGGER which start function "q_replace"

![image](https://user-images.githubusercontent.com/73586088/113996316-e0cd9900-9878-11eb-9e51-3dc6db536456.png)

"q_replace" function:

    CREATE OR REPLACE FUNCTION public.q_replace()
    RETURNS trigger
    LANGUAGE plpgsql
    AS $function$
       declare 
         dt varchar;
         dt1 varchar;
         dt2 varchar;
         dt3 varchar;
         dt4 varchar;
         dt5 varchar;
	   begin
	      dt := split_part(NEW.data, '|', 1);
	      dt1 := split_part(NEW.data, '|', 2);
	      dt2 := split_part(NEW.data, '|', 3);
	      dt3 := split_part(NEW.data, '|', 4);
	      dt4 := split_part(NEW.data, '|', 5);
	      dt5 := split_part(NEW.data, '|', 6);

           IF (NEW.event = 'ENTERQUEUE')  THEN
              UPDATE cdr_queue_log set  src = dt1 , queuename =  NEW.queuename where uniqueid = NEW.callid ;
           END IF;
	   
           IF (NEW.event = 'DID') THEN
              Insert into cdr_queue_log (calldate, uniqueid, queuename, did,filename) VALUES (NEW.time,NEW.callid , NEW.queuename ,dt,dt1);
           END IF;       
	   
           IF (NEW.event = 'COMPLETECALLER')  OR (NEW.event = 'COMPLETEAGENT')  THEN
              UPDATE cdr_queue_log set  wait_time = dt1, billsec = dt2  where uniqueid = NEW.callid;
           END IF;

           IF (NEW.event = 'ABANDON')  THEN
              UPDATE cdr_queue_log set  wait_time = dt2, disposition = 'NOANSWER',dst = 'nobody' where uniqueid = NEW.callid;
           END IF;
	   
	   IF (NEW.event = 'CONNECT')  THEN
              UPDATE cdr_queue_log set  wait_time = dt1, disposition = 'ANSWER', dst = NEW.agent where uniqueid = NEW.callid;
           END IF;

           IF (NEW.event = 'TRANSFER') THEN
              UPDATE cdr_queue_log set  wait_time = dt3, billsec = dt4  where uniqueid = NEW.callid;
           END IF;

           IF (NEW.event = 'EXITWITHTIMEOUT')  THEN
              UPDATE cdr_queue_log set  wait_time = dt3, disposition = 'NOANSWER' where uniqueid = NEW.callid;
           END if;
	   
	   RETURN NEW;
	   END; 
    $function$;

That function fills the cdr_queue_log table. Which makes it more appropriate for using.

![image](https://user-images.githubusercontent.com/73586088/114003039-3f961100-987f-11eb-81e4-1b1733cfdb49.png)

