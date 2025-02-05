# Known Issues & Solutions

Place to record issues that arise and there corresponding workarounds.

## 500 Errors When Connecting to API

1. Check your permissions and verify that they match exactly as shown here: [IAM Policies](../iam_policies)
2. Did you choose `*.nip.io` as your domain name when setting up Corrino? If so, this is an untrusted domain and will be blocked when behind VPN. Either choose to deploy Corrino via custom domain or access your `*.nip.io` Corrino domain outside of VPN
