#!/bin/bash

terraform init

gcloud init

gcloud components update

gcloud projects list

echo -n enter_PROJECT_NAME: 

read PROJECT

echo -n enter_PROJECT_ID: 

read PROJECT_ID

gcloud config set project $(echo $PROJECT_ID)

gcloud services list --available

gcloud services enable cloudresourcemanager.googleapis.com  

echo -n create_service-account: 

read ACCOUNT

gcloud iam service-accounts create $(echo $ACCOUNT) --display-name "＄{ACCOUNT}"

PROJECT_ID=$(gcloud config get-value project)
    
gcloud iam service-accounts keys create ./account.json --iam-account $(echo $ACCOUNT)@$(gcloud config get-value project).iam.gserviceaccount.com

gcloud projects add-iam-policy-binding $(echo $PROJECT_ID) --member serviceAccount:$(echo $ACCOUNT)@$(gcloud config get-value project).iam.gserviceaccount.com \
  --role roles/editor

