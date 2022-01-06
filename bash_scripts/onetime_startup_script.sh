# Environment Variable
export PROJECT_ID=indranil-24011994-03\
export BILLING_ACCOUNT_ID=01F748-D68B6C-7BFEF3 \
export SERVICE_ACCOUNT_ID=sa-composer-dataflow \
export REGION=us-central1 \
export GCS_BUCKET_01="$PROJECT_ID" \
export PUBSUB_TOPIC=pubsub-topic-poc-01 \
export PUBSUB_SUBSCRIPTION_01=pubsub-subscription-poc-01 \
export BIGQUERY_DATASET=poc_dataflow \
export BIGQUERY_TABLE_01=detailed_view 

echo "Variable Setup Done"

# Create the Project
gcloud projects create $PROJECT_ID --name 'Composer Dataflow POC'
echo "New Project has been created"

# Enable billing for newly created project
gcloud alpha billing projects link $PROJECT_ID --billing-account $BILLING_ACCOUNT_ID
echo "Billing account has been assigned to the project"

# Set to the newly created Project
gcloud config set project $PROJECT_ID
echo "set the project"

# Enable the API
gcloud services enable dataflow.googleapis.com
gcloud services enable pubsub.googleapis.com
gcloud services enable composer.googleapis.com
echo "APIs has been enabled"

# create the service account
gcloud iam service-accounts create $SERVICE_ACCOUNT_ID \
--description='service account for POC' \
--display-name='sa-composer-dataflow'
echo "Service Account has been created"

# assign the role to that specific service account
gcloud projects add-iam-policy-binding $PROJECT_ID \
--member="serviceAccount:$SERVICE_ACCOUNT_ID@$PROJECT_ID.iam.gserviceaccount.com" \
--role="roles/editor"
echo "role has been assigned to that service account"

# Create GCS Bucket
gsutil mb -c standard -b off -l us-central1 gs://$GCS_BUCKET_01
echo "GCS Bucket has been created"

# Create Pub/Sub Topic
gcloud pubsub topics create $PUBSUB_TOPIC --project $PROJECT_ID
echo "pubsub topic has been created"

# Bigquery Dataset Creation
bq mk --location us --description 'for demo poc' --dataset $PROJECT_ID:$BIGQUERY_DATASET
echo "Bigquery Dataset has been created"

# Bigquery Table Creation
bq mk --location us-central1 --table $PROJECT_ID:$BIGQUERY_DATASET.$BIGQUERY_TABLE_01

#Create/Setup Composer Env 
gcloud composer environments create $COMPOSER_ENV_NAME \
--env-variables GCP_PROJECTID=$PROJECTID,GCP_BUCKET=$GCP_BUCKET,AWS_BUCKET=$AWS_BUCKET,AWS_FILE_PREFIX=$AWS_FILE_PREFIX,BQ_DATASET=$BQ_DATASET,BQ_TABLE=$BQ_TABLE \
--location $COMPOSER_LOC \
--image-version $COMPOSER_IMAGE_VERSION
echo "Composer env has been created @ $(date)"

#Move the DAG to the Composer Env
#gcloud composer environments storage dags import --environment bq-composer-env --source dags/Composer_DAG_01.py --location us-central1
gcloud composer environments storage dags import --environment $COMPOSER_ENV_NAME --source $DAG_SOURCE_PATH --location $COMPOSER_LOC
echo "Dag file also moved to the composer environment"
