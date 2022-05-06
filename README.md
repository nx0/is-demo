# instant-search-demo

## Introduction

In this demo the system we are going to use will be minikube. Minikube will allow us to run a local kubernetes
environment locally to test the instant-search-demo as a Deployment in Kubernetes.
Image is built over a Dockerfile

This Dockerfile only install all the required files:
* instant-search-demo code from github
* nvm shell

The rest of the dependencies/steps are delegated to a `docker-entrypoint.sh` file. This is because it simplifies a lot
the creation of the Dockerfile because we don't need to deal with environment variables in the creation process of the
Dockerfile.

In this step (the application warm up) we install:
* Node version manager (nvm) install the 9.11.2 of Node.
* Node Pacakge Manager (npm) instal all the dependencies defined by the instant-search app.



## Requeriments
* Ubuntu or similar x86 system
* Docker installed
* Minikube installed


## Quickstart
The script `install.sh` will take care of execute everything needed to run the test environment.
./install.sh


brew install minikube
minikube start

## Detailed steps

### Build image locally
:info: This is only for testing the app individually, the `install.sh` script will take care of installing everything.

cd packaging
docker build -t instant-search .
# Expose the ports required by the app
docker run -p 3001:3001 -p 3000:3000 instant-search



### Using a cluster
kubectl config use-context minikube (optional)

eval $(minikube docker-env)
docker build -t instant-search .
minikube image load instant-search:latest

kubectl create deployment instant-search --image=instant-search:latest
kubectl expose deployment instant-search --type=NodePort --port=3000:3000
 # minikube service instant-search
# in another terminal
minikube tunnel



# Testing 
curl -IXGET -s http://localhost:8180