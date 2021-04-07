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
