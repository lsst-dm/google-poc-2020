HTCONDOR Images Factory
==================

This directory contains codes to automate the image creation.
It relies on Packer from HashiCorp.
You will need to install Packer before being able to create images.
Visit the packer
[website](https://www.packer.io/intro/getting-started/install.html)
to install Packer from HashiCorp

## Create the LSST image

The instruction below describes how to create an image using packer.

The image creation process with Packer creates an instance, installs
the necessary software, stops the instance, creates the image and deletes
the instance.

```bash
packer build -force -var gcp_project_id=$(gcloud info --format="value(config.project)")   lsst-image.json 
```

This will create an image 

Python3 is not set as default, to avoid breaking some GCP specific things. Put this in your .bashrc
```
export PATH=/usr/local/python3/bin/:$PATH
```

Also, LSST stuff is in 
```
/opt/lsst/software/stack/
```

Make the image public with: 

```
gcloud compute images add-iam-policy-binding [[IMAGE_NAME]] --member='allAuthenticatedUsers' --role='roles/compute.imageUser'
```

You can then build a VM using:

```
gcloud compute instances create lsstvm --image-project [[PROJECT_ID]] --image-family local
```



Copyright 2020 Google LLC.
This software is provided as-is, without warranty or representation for any use or purpose.
Your use of it is subject to your agreement with Google.
