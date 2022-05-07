#!/bin/bash

# clean up conflictive env variables
unset DOCKER_CERT_PATH
unset DOCKER_TLS_VERIFY
unset MINIKUBE_ACTIVE_DOCKERD
unset DOCKER_HOST

function endpoint_ready {
    echo ""
    echo ""
    echo "  CONGRATULATIONS:"
    echo "  ====================================================="
    echo "  instant-search endpoint should be ready!!"
    echo "  open a web browser and head to: http://localhost:8080"
    echo ""
    echo ""
}

function upload_image {
    echo "===> uploading image to minikube"
    echo ""
    echo "it may take a while, be patient :)"
    echo ""
    minikube image load instant-search:latest
}

function exit_grace {
    echo "missing requirements, exiting..."
    exit 1
}

function install_minikube {
    echo "===> installing minikube"
    curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube_latest_amd64.deb
    sudo dpkg -i minikube_latest_amd64.deb
}

function install_kubectl {
    echo "===> installing kubectl via snap"
    sudo snap install kubectl --classic
}

echo ""
echo "======== Detecting dependencies ========"
echo ""

echo -n "> checking supported OS ..."
if lsb_release -d | grep -i ubuntu >/dev/null; then 
    echo "ok"
else
    echo "os not supported"
    exit_grace
fi

echo -n "> checking docker installation ..."
if docker -v >/dev/null; then
    echo "ok"
else
    exit_grace
fi
echo -n "> checking if docker is running..."
if [ "$(systemctl status docker | grep "Active:" | awk '{ print $3 }')" == "(running)" ]; then
    echo "ok"
else
    exit_grace
fi

echo -n "> checking if minikube is installed..."
if dpkg -l | grep minikube >/dev/null; then
    echo "ok"
else
    echo "minikube not detected"
    install_minikube
fi

echo -n "> checking if kubectl is installed ..."
if kubectl version --client 2>/dev/null; then
    echo "ok"
else
    echo "WARNING: kubectl not found"
    install_kubectl
fi

echo "> Detecting docker image of instant-search..."
if ! docker image ls | grep instant-search >/dev/null; then
    echo "WARNING: instant-search image not found..."
    echo "===> building instant-search image locally..."
    cd packaging
    docker build -t instant-search .
    eval $(minikube docker-env)
    upload_image
else
    echo "===> instant-search local ok!"
    eval $(minikube docker-env)
    if ! docker image ls | grep instant-search >/dev/null; then
        upload_image
    else
        echo "===> instant-search remote ok!"
    fi
fi

echo "> checking endpoint availability ..."
http_endpoint="$(curl -sIXGET http://localhost:8080 | head -n 1 | awk '{ print $2 }')"
if  [ "$http_endpoint" == "200" ]; then
    endpoint_ready
else 
    echo "* Ensuring minikube context"
    kubectl config use-context minikube
    echo "===> installing instant-search-demo app in the kubernetes cluster...."
    kubectl apply -f cluster/app.yml

    echo "* forwarding ports:"
    nohup kubectl port-forward service/instant-search 8080:8080 &
    while [ "$(curl -sIXGET http://localhost:8080 | head -n 1 | awk '{ print $2 }')" != "200" ]; do
        echo "waiting for the endpoint to be ready... "
        http_endpoint="200"
        sleep 5
    done

    if [ "$http_endpoint" == "200" ]; then
        endpoint_ready
    fi
fi