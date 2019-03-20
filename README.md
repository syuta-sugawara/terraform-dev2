# gcp-terraform

## Dependency

before you begin
those are needed to be installed.

terraform v0.11.3  
https://www.terraform.io/  

Google Cloud SDK 239.0.0  
bq 2.0.42　　
core 2019.03.17　　
gsutil 4.37　　

https://cloud.google.com/sdk/docs/downloads-interactive　　

and create project in your gcp, then enable billing for a project


## set up staging environment using shell

```
git clone git@github.com:ca-rpa/gcp-terraform.git

cd stg
./quickstart.sh

terraform apply

```

## set up staging environment manually

```
git clone git@github.com:ca-rpa/gcp-terraform.git

cd stg

terraform init

gcloud init

gcloud components update

gcloud projects list

PROJECT_ID="enter your project_id"

gcloud config set project $(echo $PROJECT_ID)

gcloud services list --available

gcloud services enable cloudresourcemanager.googleapis.com　sourcerepo.googleapis.com cloudbuild.googleapis.com 

gcloud services enable compute.googleapis.com　serviceusage.googleapis.com container.googleapis.com

gcloud services enable containerregistry.googleapis.com storage-api.googleapis.com oslogin.googleapis.com


ACCOUNT="service account name creating environment"

gcloud iam service-accounts create $(echo $ACCOUNT) --display-name "＄{ACCOUNT}"

PROJECT_ID=$(gcloud config get-value project)
    
gcloud iam service-accounts keys create ./account.json --iam-account $(echo $ACCOUNT)@$(gcloud config get-value project).iam.gserviceaccount.com

gcloud projects add-iam-policy-binding $(echo $PROJECT_ID) --member serviceAccount:$(echo $ACCOUNT)@$(gcloud config get-value project).iam.gserviceaccount.com \
  --role roles/owner

terraform apply


```


