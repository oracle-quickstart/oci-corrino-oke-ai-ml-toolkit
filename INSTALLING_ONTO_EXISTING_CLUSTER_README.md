# Install OCI AI Blueprints onto an Existing OKE Cluster

This guide helps you install and use **OCI AI Blueprints** for the first time on an existing OKE cluster that was created outside of blueprints which already has workflows running on it. You will:

1. Ensure you have the correct IAM policies in place.
2. Retrieve existing cluster OKE and VCN names from console.
3. Deploy the **OCI AI Blueprints** application onto the existing cluster.
4. Learn how to add existing nodes in the cluster to be used by blueprints.

---

## Overview

Rather than installing blueprints onto a new cluster, a user may want to leverage an existing cluster with node pools and tools already installed. This doc will cover the components needed to deploy to an existing cluster, how to add existing node pools to be used by blueprints, and additional considerations which should be considered.

## Step 1: Set Up Policies in Your Tenancy

Some or all of these policies may be in place as required by OKE. Please review the required policies listed [here](docs/iam_policies/README.md) and add any required policies which are missing.

1. If you are **not** a tenancy administrator, ask your admin to add additional required policies in the **root compartment**.
2. If you **are** a tenancy administrator, you can either manually add the additional policies to an existing dynamic group, or let the resource manager deploy the required policies during stack creation.

## Step 2: Retrieve Existing OKE OCID and VCN OCID

1. Navigate to the console.
2. Go to the region that contains the cluster you wish to deploy blueprints onto.
3. Navigate to **Developer Services -> Containers & Artifacts -> Kubernetes Clusters (OKE) -> YourCluster**
4. Click your cluster, and then capture the name of the cluster and the name of the VCN as they will be used during stack creation.

## Step 3: Deploy the OCI AI Blueprints Application

1. Go to [Deploy the OCI AI Blueprints Application](./GETTING_STARTED_README.md#step-3-deploy-the-oci-ai-blueprints-application) and click the button to deploy.
2. Go to the correct region where your cluster is deployed.
3. If you have not created policies and are an admin, and would like the stack to deploy the policies for you:

   - select "NO" for the question "Have you enabled the required policies in the root tenancy for OCI AI Blueprints?"
   - select "YES" for the question "Are you an administrator for this tenancy?".
   - Under the section "OCI AI Blueprints IAM", click the checkbox to create the policies. (If you do not see this, ensure you've selected the correct choices for the questions above.)

- Otherwise, create the policies if you are an admin, or have your admin create the policies.
4. Select "YES" for all other options.
5. Fill out additional fields for username and password, as well as Home Region.
6. Under "OKE Cluster & VCN", select the cluster name and vcn name you found in step 2.
7. Populate the subnets with the appropriate values. As a note, there is a "hint" under each field which corresponds to possible naming conventions. If your subnets are named differently, navigate back to the console page with the cluster and find them there.
8. **Important**: uncheck any boxes for "add-ons" which you already have installed. The stack will fail if a box is left checked and you already have the tool installed in any namespace.
   - if you leave a box checked and the stack fails:
     - click on stack details at the top
     - click on variables
     - Click "Edit variables" box
     - Click "Next"
     - Fill the drop downs back in at the top (the rest will persist)
     - Uncheck the box of the previously installed application.
     - Click "Next"
     - Check the "Run apply" box"
     - Click "Save changes"
   - **Currently autoscaling requires prometheus to be installed in the `cluster-tools` namespace** and keda in the `default` namespace. This will change in an upcoming release.

## Step 4: Add Existing Nodes to Cluster (optional)
If you have existing node pools in your original OKE cluster that you'd like Blueprints to be able to use, follow these steps after the stack is finished:

1. Go to the stack and click "Application information". Click the API Url.
   - If you get a warning about security, sometimes it takes a bit for the certificates to get signed. This will go away once that process completes on the OKE side.
2. Login with the `Admin Username` and `Admin Password` in the Application information tab.
3. 
