# Corrino Quick Start

## Create Prerequisites

---

### Administrative Role

You will need roles to:

* Create a compartment
* Create a dynamic group within an Identity Domain
* Create a policy at the root Compartment level
* Create an OKE Cluster
* Create a VCN
* Create a LoadBalancer
* Create an Object Storage Bucket

### Compartment

* Create a compartment
  * Capture the OCID for the compartment
  * Assuming your compartment is named `corrino-compartment`

  
### Dynamic Group

* Create a dynamic group
  * Assuming you are creating dynamic group in the `Default` Identity Domain:
  * Assuming your dynamic group name is `corrino-dg`:


    ALL {instance.compartment.id = 'ocid1.compartment.oc1..'}	
    ALL {resource.compartment.id = 'ocid1.compartment.oc1..'}

### Policy

* Create a new policy in the root compartment.
  * Assuming you are creating dynamic group in the `Default` Identity Domain:
  * Assuming your dynamic group name is `corrino-dg`


    Allow dynamic-group 'Default'/'corrino-dg' to use all-resources in tenancy	
    Allow dynamic-group 'Default'/'corrino-dg' to manage all-resources in compartment corrino-compartment

If your compartment is nested beneath other compartments (ie not at the top level) as in:

* root
  * compA
    * compB
      * compC
        * corrino-compartment


    Allow dynamic-group 'Default'/'corrino-dg' to manage all-resources in compartment compA:compB:compC:corrino-compartment

### OKE Cluster

* Create an OKE cluster using the OCI Console
* Using the wizard is fine.

Write Down:

* The OKE Cluster OCID
* The VCN OCID
* Each Subnet OCID (there will be 3)

---

## Create a Resource Manager Stack

* Use the `Deploy to Oracle Cloud` link.
* Provide the inputs for OCIDS
  * Compartment OCID
  * OKE Cluster OCID
  * VCN OCID
    * Node Subnet
    * LB Subnet
    * Endpoint Subnet


