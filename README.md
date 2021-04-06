# docker-asterisk

[![Build Status](https://travis-ci.org/dougbtv/docker-asterisk.svg?branch=master)](https://travis-ci.org/dougbtv/docker-asterisk)

A set of Dockerfiles for running asterisk (and a FastAGI, one for PHP as it stands)

Also checkout my blog article @ [dougbtv.com](http://dougbtv.com/2014/10/02/docker-and-asterisk/).

You can [pull the image from dockerhub](https://registry.hub.docker.com/u/dougbtv/asterisk/).

Which is as simple as running:

                                     Security fix only             EOL
    # Asterisk 16.8 Certified LTS       2022-10-09              2023-10-09
    docker pull dougbtv/asterisk16

    # Asterisk 13 LTS                   2020-10-24              2021-10-24
    docker pull dougbtv/asterisk13

    # Asterisk 11 LTS                   2016-10-25              2017-10-25 
    docker pull dougbtv/asterisk 
