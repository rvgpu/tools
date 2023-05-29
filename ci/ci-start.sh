#! /usr/bin/env bash

function start_docserver
{
    pushd /home/rvgpu/pages
    	python -m http.server 10000 &
    popd
}


# main
# start gitlab runner 
gitlab-runner run &

start_docserver

