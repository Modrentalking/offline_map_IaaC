### It is necessary to enable serviceusage.googleapis.com before terraform init. 
### It is needed for terraform API managment 

```bash
gcloud config set project offline-map-prod
gcloud services enable serviceusage.googleapis.com
gcloud services enable cloudresourcemanager.googleapis.com
```
### It is necessary to create private range network for CloudSql managment and communication without public IP

## Disable CLoudSql via gcloud cli
```bash 
gcloud sql instances patch offline-map-postgres-dev-01 \
  --activation-policy=NEVER \
  --project=offline-map-prod
```
