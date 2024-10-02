#!/bin/bash

sudo docker build -t hostmachine:5000/minikube-demo_samplefrontend:latest .
sudo docker push hostmachine:5000/minikube-demo_samplefrontend:latest
