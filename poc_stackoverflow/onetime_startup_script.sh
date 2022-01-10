# Created by: Indranil Pal
# Created Date: 10/01/2022

export PROJECT_ID=indranil-24011994-01 \
export BILLING_ACCOUNT_ID=01F748-D68B6C-7BFEF3 \
export SERVICE_ACCOUNT_ID=sa-stackoverflow \
export PUBSUB_TOPIC=pubsub-topic-stackoverflow


if [[ ! $(gcloud projects list --format='json(name)' --filter='"name": "POC Stackoverflow"') ]]  
then
    gcloud projects create $PROJECT_ID --name 'POC Stackoverflow' --set-as-default;
    gcloud alpha billing projects link $PROJECT_ID --billing-account $BILLING_ACCOUNT_ID;
else 
    echo 'Project has been created already';
fi;


if [[ ! $(gcloud iam service-accounts list --filter='"displayName": "sa-stackoverflow"' --format="json") ]] 
then
    gcloud iam service-accounts create $SERVICE_ACCOUNT_ID --description='service account for POC' --display-name='sa-stackoverflow' --project=$PROJECT_ID;
else
    echo "service account has been created already";
fi;


gcloud services enable compute.googleapis.com;
gcloud services enable pubsub.googleapis.com;
gcloud services enable composer.googleapis.com;
gcloud services enable dataflow.googleapis.com;


if [[ ! $(gcloud pubsub topics list --filter="name: projects/$PROJECT_ID/topics/$PUBSUB_TOPIC" --format="json") ]]
then
    gcloud pubsub topics create $PUBSUB_TOPIC --project $PROJECT_ID;
else
    echo "Pubsub topic has been created already";
fi;




