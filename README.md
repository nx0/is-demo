# instant-search-demo

* [Introduction](README.md#introduction) 
* [Content](README.md#content)
* [Requeriments](README.md#requeriments)
* [Quickstart](README.md#quickstart)
* [Detailed steps](README.md#detailed-steps)
  * [Build docker image locally](README.md#build-docker-image-locally)
  * [Using the cluster](README.md#using-the-cluster)
* [Testing](README.md#testing)

## Introduction

In this demo, we are going to install the instant-search app provided by Algolia.

The system we are going to use to install everything will be docker + minikube.

Minikube will allow us to run a local kubernetes cluster to test the instant-search-demo as a Deployment in Kubernetes.

Image is built over a Dockerfile.

This Dockerfile only install all the required files:
* instant-search-demo code from github
* nvm shell

The rest of the dependencies/steps are delegated to a `docker-entrypoint.sh` file. This is because it simplifies a lot
the creation of the Dockerfile because we don't need to deal with environment variables in the creation process of the
Dockerfile.

Once the application runs (the application warm up) we install:
* Node version manager (nvm) install the 9.11.2 of Node.
* Node Pacakge Manager (npm) instal all the dependencies defined by the instant-search app.

## Content
* :file_folder: **cluster/** it contains the required files to install the *instant-search* app into the local kubernetes cluster (Service and Deployment).
* :file_folder: **doc/** constains additional doc files.
* :file_folder: **packaging/** contains all the required files to build the instant-search Docker image.
* :heavy_dollar_sign: **install.sh** The installation script of the local test environment.

## Requeriments
* Ubuntu >= or similar x86 system
* Docker installed
* Minikube installed


## Quickstart
The installation script `install.sh` will take care of executing everything needed to run the test environment.
Inside the same is-demo folder, excute
```bash install.sh```

> The script is exposing the app port in the port 8080

The script will check for all the dependencies and once meet it will start the installation process.
Once finished, we will be able to access the local test endpoint http://localhost:8080


The exit status of the script will be similar to this:

```bash
======== Detecting dependencies ========

> checking directory...incorrect directory, execute the script inside the is-demo folder
> checking supported OS ...ok
> checking docker installation ...ok
> checking if docker is running...ok
> checking if minikube is installed...ok
> checking if kubectl is installed ...ok
> Detecting docker image of instant-search...
===> instant-search local ok!
===> instant-search remote ok!
> checking endpoint availability ...


  CONGRATULATIONS:
  =====================================================
  instant-search endpoint should be ready!!
  open a web browser and head to: http://localhost:8080
```

## Detailed steps

:information_source: This is only for testing the app individually, the `install.sh` script will take care of installing everything.

### Build docker image locally
```bash
cd packaging
docker build -t instant-search .
# Expose the ports required by the app
docker run -p 3001:3001 -p 3000:3000 instant-search
```

### Using a cluster
```bash
# Ensure using the minkube context in case we are using other kubernetes contexts locally.
kubectl config use-context minikube (optional)

# Prepare the environment variables to upload the image in the remote kubernetes cluster.
eval $(minikube docker-env)
docker build -t instant-search .
minikube image load instant-search:latest

# Install the services and the deployment
kubectl create deployment instant-search --image=instant-search:latest
kubectl expose deployment instant-search --type=NodePort --port=8080:3000

# Give local access to the cluster, forwarding the localport 8080 to the port exposed by the app 8080
kubectl port-forward service/instant-search 8080:8080
```


# Testing 
curl -sIXGET http://localhost:8080

exit status should be similar to this
```bash
HTTP/1.1 200 OK
Accept-Ranges: bytes
Cache-Control: public, max-age=0
Last-Modified: Sat, 07 May 2022 13:09:55 GMT
ETag: W/"d1b-1809ea414b8"
Content-Type: text/html; charset=UTF-8
Content-Length: 3355
Date: Sun, 08 May 2022 09:49:52 GMT
Connection: keep-alive
```
