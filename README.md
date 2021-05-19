This is a simple callcenter based on Asterisk 18, PostgreSQL and Grafana

# Asterisk18-PostgreSQL-Grafana
![image](https://user-images.githubusercontent.com/73586088/113707049-2bc4a080-9701-11eb-9a48-5464f6d9a4d8.png)

# Description
[Asterisk18](https://hub.docker.com/repository/docker/6391725ysd/asterisk-18.3) 
 Based on:
 - Alpine base images
 - Asterisk 18.3.0 built from source with postgresql-odbc. 

 [Grafana](https://hub.docker.com/repository/docker/6391725ysd/grafana)  
 Based on official image [grafana](https://hub.docker.com/r/grafana/grafana) 
 
  [PostgreSQL](https://hub.docker.com/repository/docker/6391725ysd/postgresql)  
 Based on official image [PostgreSQL](https://hub.docker.com/_/postgres) 
 
# Installation

Just pull and run:

    # Grafana 
    docker pull 6391725ysd/grafana
    docker run -d --name grafana -v /home/records/:/usr/share/grafana/public/build/records --net=host 6391725ysd/grafana
    
    # Asterisk 18
    docker pull 6391725ysd/asterisk-18.3
    docker run -d --name asterisk18 -v /home/records/:/var/spool/asterisk/monitor/ --net=host 6391725ysd/asterisk-18.3
    
    # PostgreSQL
    docker pull 6391725ysd/postgresql
    docker run -d --name postgresql --net=host 6391725ysd/postgresql
    
    

Grafana default login and password:
- admin
- n2r24h7

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
      	   begin
           IF (NEW.event = 'ENTERQUEUE')  THEN
           UPDATE cdr_queue_log set  src = NEW.data2 , queuename =  NEW.queuename where uniqueid = NEW.callid ;
        END IF;

        IF (NEW.event = 'DID') THEN
           Insert into cdr_queue_log (calldate, uniqueid, queuename, did,filename) VALUES (NEW.time,NEW.callid , NEW.queuename ,NEW.data1,NEW.data2);

          END IF;       
       
        IF (NEW.event = 'COMPLETECALLER')  OR (NEW.event = 'COMPLETEAGENT')  THEN
           UPDATE cdr_queue_log set  wait_time = NEW.data2, billsec = NEW.data3  where uniqueid = NEW.callid;
        END IF;

        IF (NEW.event = 'ABANDON')  THEN
           UPDATE cdr_queue_log set  wait_time = NEW.data3, disposition = 'NOANSWER',dst = 'nobody' where uniqueid = NEW.callid;
        END IF;

        IF (NEW.event = 'CONNECT')  THEN
           UPDATE cdr_queue_log set  wait_time = NEW.data2, disposition = 'ANSWER', dst = NEW.agent where uniqueid = NEW.callid;
        END IF;

        IF (NEW.event = 'TRANSFER') THEN
           UPDATE cdr_queue_log set  wait_time = NEW.data4, billsec = NEW.data5  where uniqueid = NEW.callid;
        END IF;

        IF (NEW.event = 'EXITWITHTIMEOUT')  THEN
           UPDATE cdr_queue_log set  wait_time = NEW.data4, disposition = 'NOANSWER' where uniqueid = NEW.callid;
        END if;	
	   
	   RETURN NEW;
	   END; 
    $function$;

That function fills the cdr_queue_log table. Which makes it more appropriate for using.

![image](https://user-images.githubusercontent.com/73586088/114003039-3f961100-987f-11eb-81e4-1b1733cfdb49.png)

The "operators" table is basically used for choosing operators in grafana.

![image](https://user-images.githubusercontent.com/73586088/114005210-242c0580-9881-11eb-9afa-d27dcaac4666.png)

On dashboard

![image](https://user-images.githubusercontent.com/73586088/114005171-1b3b3400-9881-11eb-89fd-4ebf77dda5c1.png)




