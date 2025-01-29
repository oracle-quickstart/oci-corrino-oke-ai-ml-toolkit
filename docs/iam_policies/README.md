## IAM Policies

Many Corrino users choose to give full admin access to Corrino when using it for the first time or developing a POC, and making the permissions more granular overtime. We provide you with two different variations of IAM Policies for you to choose from - depending on your situation.

**Note:** `'Default'/'SecondUserGroup'` -> please modify this to match the user group that your user is in
**Note:** All these policies will be in the root compartment of your tenancy (NOT in the Corrino compartment itself)

**Option #1: Full Admin Access:**

```
Allow group 'Default'/'SecondUserGroup' to inspect all-resources in tenancy
Allow group 'Default'/'SecondUserGroup' to manage all-resources in compartment {comparment_name}
```

**Option #2: Fine-Grain Access:**

```
Allow group 'Default'/'SecondUserGroup' to inspect all-resources in tenancy

Allow group 'Default'/'SecondUserGroup' to manage instance-family in compartment {compartment_name}

Allow group 'Default'/'SecondUserGroup' to use subnets in compartment {compartment_name}

Allow group 'Default'/'SecondUserGroup' to manage virtual-network-family in compartment {compartment_name}

Allow group 'Default'/'SecondUserGroup' to use vnics in compartment {compartment_name}

Allow group 'Default'/'SecondUserGroup' to use network-security-groups in compartment {compartment_name}

Allow group 'Default'/'SecondUserGroup' to manage public-ips in compartment {compartment_name}

Allow group 'Default'/'SecondUserGroup' to manage cluster-family in compartment {compartment_name}

Allow group 'Default'/'SecondUserGroup' to manage orm-stacks in compartment {compartment_name}

Allow group 'Default'/'SecondUserGroup' to manage orm-jobs in compartment {compartment_name}

Allow group 'Default'/'SecondUserGroup' to manage vcns in compartment {compartment_name}

Allow group 'Default'/'SecondUserGroup' to manage subnets in compartment {compartment_name}

Allow group 'Default'/'SecondUserGroup' to manage internet-gateways in compartment {compartment_name}

Allow group 'Default'/'SecondUserGroup' to manage nat-gateways in compartment {compartment_name}

Allow group 'Default'/'SecondUserGroup' to manage route-tables in compartment {compartment_name}

Allow group 'Default'/'SecondUserGroup' to manage security-lists in compartment {compartment_name}

Allow group 'Default'/'SecondUserGroup' to inspect clusters in compartment {compartment_name}

Allow group 'Default'/'SecondUserGroup' to use cluster-node-pools in compartment {compartment_name}

Allow group 'Default'/'SecondUserGroup' to read cluster-work-requests in compartment {compartment_name}

Allow group 'Default'/'SecondUserGroup' to manage service-gateways in compartment {compartment_name}

Allow group 'Default'/'SecondUserGroup' to use cloud-shell in compartment {compartment_name}

Allow group 'Default'/'SecondUserGroup' to read vaults in compartment {compartment_name}

Allow group 'Default'/'SecondUserGroup' to read keys in compartment {compartment_name}

Allow group 'Default'/'SecondUserGroup' to use compute-capacity-reservations in compartment {compartment_name}

Allow group 'Default'/'SecondUserGroup' to read metrics in compartment {compartment_name}

Allow group 'Default'/'SecondUserGroup' to manage autonomous-database-family in compartment {compartment_name}

Allow dynamic-group 'Default'/'SecondUserGroup' to read virtual-network-family in compartment {compartment_name}

Allow dynamic-group 'Default'/'SecondUserGroup' to inspect compartments in compartment {compartment_name}

Allow dynamic-group 'Default'/'SecondUserGroup' to manage cluster-node-pools in compartment {compartment_name}
```
