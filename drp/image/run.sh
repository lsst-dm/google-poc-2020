#!/bin/bash

packer build -force -var gcp_project_id=$(gcloud info --format="value(config.project)") lsst-image.json
