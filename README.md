# GCP-POC-DataPipeline
1. Using **Composer**, migrate the data from AWS S3 or Azure Blob Storage to Google Cloud Storage and then move to datastore
2. Using **Pubsub** for passing Barcode (Fact data)
3. Using **Datastore** for Product Catalog (Product Dimentions)
4. Using **Dataflow**, join data between Pubsub (streaming) and Cloud Datastore (Static Data) and do some transformation and load into Bigquery
5. Use **BigQuery** for data warehouse
---

### Step1: CLone the code from GIT Repo
	git clone git@github.com:buaindra/GCP-POC-DataPipeline.git
	cd GCP-POC-DataPipeline
	git pull origin main
---

### Step2: Execute the Onetime Startup Script
	bash onetime_startup-script.sh
---

### Step3: Create Python Virtual Environment and install the Apache Beam SDKs
	python3 -m virtualenv env
	source env/bin/activate
---
	pip install -m 'apache-beam[gcp]'

### Step4: Run the Beam Pipeline Locally for testing
	python hello-beam.py --project $PROJECT_ID --topic $PUBSUB_TOPIC --output beam.out --runner DirectRunner

### Step5: Then run the pipeline in dataflow runner
	python -m apache_beam.examples.wordcount \
	--region $REGION \
	--input gs://dataflow-samples/shakespeare/kinglear.txt \
	--output gs://$GCS_BUCKET_01/results/outputs \
	--runner DataflowRunner \
	--project $PROJECT_ID \
	--temp_location gs://$GCS_BUCKET_01/tmp/ 

### Step6: Verify the output
> #List the output files
	gsutil ls -lh "gs://$GCS_BUCKET_01/results/outputs*"  
> 
> #View the results in the output files:
	gsutil cat "gs://$GCS_BUCKET_01/results/outputs*"


