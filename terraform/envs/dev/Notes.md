### It is necessary to enable serviceusage.googleapis.com before terraform init. 
### It is needed for terraform API managment 

```bash
gcloud config set project offline-map-prod
gcloud services enable serviceusage.googleapis.com
gcloud services enable cloudresourcemanager.googleapis.com
```
### It is necessary to create private range network for CloudSql managment and communication without public IP
