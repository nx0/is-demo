#!/bin/bash

curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube


cd packaging
eval $(minikube docker-env)
docker build -t instant-search .
minikube image load instant-search:latest
kubectl apply -f ckuster app.yml

# ensure using the context
kubectl config use-context minikube (optional)

(in an other terminal): minikube tunnel

# check if the endpoint is ready
for i in $(seq 1 100); do
    http=$(curl -IXGET -s http://localhost:8180)
    if [ "$http" == "200" ]; then
        open default browser: http://
    fi
done