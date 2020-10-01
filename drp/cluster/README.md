# HTCondor on GCP

```
gcloud config set project [[PROJECT_ID]]
gcloud config set compute/region us-central1
gcloud config set compute/zone us-central1-f
```

```
gcloud source repos clone HTCondorTerraform --project=htcondor-lsst
cd HTCondorTearraform
```

```
gcloud iam service-accounts create htcondor
```

```
gcloud projects add-iam-policy-binding \
       --member serviceAccount:htcondor@[[PROJECT]]  \
       --role roles/iam.serviceAccountUser
```

### After git clone

Once the git clone is complete, running `tree` in your cloud console shell.


```
.
├── applications
│   ├── Makefile
│   ├── primes.c
│   └── submitprimes
├── htcondor
│   ├── resources.tf
│   └── startup-centos.sh
├── init.tf
├── junk.txt
├── main.tf
├── readme.md
├── terraform.tfstate
└── terraform.tfstate.backup

2 directories, 11 files
```



## Updating the main.tf Terraform file

The as-is file from the git repository will not work without modifying the _main.tf_ to the values relevant to your project. 


```
 module "htcondor" {
   source = "./htcondor/"
   zone="<ZONE>"
   project="<PROJECT_ID"
   max_replicas=20
   min_replicas=2
   metric_target=10
   service_account="<SERVICE_ACCOUNT>"
   use_preemptibles=true
 }
```



## Writing excellent procedures



*   _[Start each step with a verb (like Click, Choose, or Type), unless you need to orient the reader._
*   _Orient the reader if they need to know where or when to start._
*   _Orientation: “In the GCP Console, …”_
*   _Condition: “If the VM has started, …” _
*   _“Optionally, …”_
*   _Take care of prerequisites before you have them start to work. _
*   _Tell them every step in the right order. (Avoid “Cut the red wire. But first, cut the green wire.”)_
*   _Make sure the names of options in the UI are **exactly right.]**_


## Reusing Google Cloud content for consistency



*   <span style="text-decoration:underline;">Document [common compute- and storage-specific tasks](https://cloud.google.com/docs/includes/configurator)</span> by using the dynamic include configurator.
*   If something is out of scope for a document, let the reader know and provide them with a link to complete those steps—for example:

    This tutorial uses a Docker image that is built with a [Dockerfile that is available on GitHub](ADDLINK). You can [build your own image](https://cloud.google.com/cloud-build/docs/quickstart-build), but that step is out of scope for this tutorial.



## Using links with the reader in mind



*   _[Each link that you include in your text entails a choice by the reader -- that is, it imposes a cognitive load. _
*   _Don’t take the reader out of the flow unless it’s required. (Don’t put links in procedure steps, list them after the procedure is over.)_
*   _The first two words of link text are most important for helping the reader know what to expect at the destination. (Never do this: “Click [here](http://www.google.com) for more information.”)_
*   _Link to the most relevant information possible (that is, to a subhead in a long document, rather than just the top of the page).]_


## Using code to maximum advantage



*   _[Except for shell and gcloud commands, put the code on GitHub and use the GitHub widget to display that code in your solution.  (See next section.)_
*   _Use code listings, not screenshots of code._
*   _Make sure people know where to run the code: Cloud Shell? On a VM instance? etc._
*   _Use API and framework versions that are the most generic or flexible.\Use approved fictitious names (esp: example.com)._
*   _Sanitize examples (no internal names, IP addresses, etc.)._
*   _Follow [SQUARE BRACKETS] conventions for how to specify placeholders. _

_If you do put code directly into the document: \
_



*   _Don't put code snippets in tables. Put code into ordinary paragraphs, and just format the code using a monospace font like Courier New._
*   _Indent paragraphs that contain code to match surrounding text. (Don't outdent code.)_
*   _If code lines are longer than about 80 characters, and if it's practical, wrap the lines and use code-continuation characters.] _


### Use the GitHub widget to include sample code

To include sample code, use the GitHub widget.

For example:


```
{#% include "cloud/appengine/standard/flask/hello_world/main.py" with project="cloudsolutionsarchitects/appengine-hello-world-python" gerrit=True file="main.py" %}
```


Renders as:



<p id="gdcalert2" ><span style="color: red; font-weight: bold">>>>>>  gd2md-html alert: inline image link here (to images/HTCondor-on0.png). Store image on your image server and adjust path/filename if necessary. </span><br>(<a href="#">Back to top</a>)(<a href="#gdcalert3">Next alert</a>)<br><span style="color: red; font-weight: bold">>>>>> </span></p>


![alt_text](images/HTCondor-on0.png "image_tooltip")


For details about how to host code samples on the GCP GitHub account and include snippets from them in your doc, see [Cloud Docs + GitHub Samples Integration](https://g3doc.corp.google.com/company/teams/cloud-devrel/docs/process-documents/cloud-docs-github-guide/index.md?cl=head).



*   
Use a consistent pattern to talk about code


*   
Follow the pattern:  \
task > command/code > explanation


*   
Like this:


*   


<p id="gdcalert3" ><span style="color: red; font-weight: bold">>>>>>  gd2md-html alert: inline image link here (to images/HTCondor-on1.png). Store image on your image server and adjust path/filename if necessary. </span><br>(<a href="#">Back to top</a>)(<a href="#gdcalert4">Next alert</a>)<br><span style="color: red; font-weight: bold">>>>>> </span></p>


![alt_text](images/HTCondor-on1.png "image_tooltip")

Be sure to explain what the code is doing and why.


## Using art effectively

There are two types of art: conceptual and screenshots. 


### Prototype excellent conceptual art



*   _[Use the established process (described in [go/solutions-factory](https://goto.google.com/solutions-factory))_
*   _File an art request with design using the [Buganizer template](https://b.corp.google.com/issues/new?component=162800&template=474322)._
*   _Get a second (third, …) opinion on conceptual art_
*   _Remember that art is hard to change and can make your content go out of date quickly_
*   _Don’t use logos that we don’t have explicit permission to use. For example, don’t use AWS logos. ]_


### Make screenshots meaningful



*   [Use sparingly—they go out of date fast and can be complicated to redo.
*   Zoom in/crop to the relevant sections of UI.]

-----


## Cleaning up

_[The cleaning up section is required. Use it to ensure they don’t get billed for any extra time.]_

To avoid incurring charges to your Google Cloud Platform account for the resources used in this tutorial:


### Delete the project

The easiest way to eliminate billing is to delete the project you created for the tutorial.


    **Caution**: Deleting a project has the following effects:



    *   **Everything in the project is deleted.** If you used an existing project for this tutorial, when you delete it, you also delete any other work you've done in the project.
    *   **Custom project IDs are lost.** When you created this project, you might have created a custom project ID that you want to use in the future. To preserve the URLs that use the project ID, such as an **<code>appspot.com</code></strong> URL, delete selected resources inside the project instead of deleting the whole project.

    If you plan to explore multiple tutorials and quickstarts, reusing projects can help you avoid exceeding project quota limits.

1. In the Cloud Console, go to the **Manage resources** page. \
[Go to the Manage resources page](https://console.cloud.google.com/iam-admin/projects)
2. In the project list, select the project that you want to delete and then click **Delete **

<p id="gdcalert4" ><span style="color: red; font-weight: bold">>>>>>  gd2md-html alert: inline image link here (to images/HTCondor-on2.png). Store image on your image server and adjust path/filename if necessary. </span><br>(<a href="#">Back to top</a>)(<a href="#gdcalert5">Next alert</a>)<br><span style="color: red; font-weight: bold">>>>>> </span></p>


![alt_text](images/HTCondor-on2.png "image_tooltip")
.
3. In the dialog, type the project ID and then click **Shut down** to delete the project.

----


## What's next

_[The What’s Next section is required. Use it to list links to the following types of content:_



*   _Related tutorials they might be interested in._
*   _Conceptual articles or reference docs._

_All tutorials must include the following bullet in the What’s Next section.]_



*   Try out other Google Cloud Platform features for yourself. Have a look at our [tutorials](https://cloud.google.com/docs/tutorials).

<!-- Docs to Markdown version 1.0β22 -->
