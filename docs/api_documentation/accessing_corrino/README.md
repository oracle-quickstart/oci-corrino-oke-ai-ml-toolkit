# Ways to Access OCI AI Blueprints

Once OCI AI Blueprints has been deployed into your tenancy via Resource Manager, you can work with OCI AI Blueprints three ways:

## **Option #1: OCI AI Blueprints APIs via Web:**

Corrino's APIs are accessible via web interface. The APIs are shown as human-friendly HTML output for each OCI AI Blueprints API resource . These pages allow for easy browsing of resources, as well as forms for submitting data to the resources using `POST`, `PUT`, and `DELETE`.

1. Inside the OCI Console > Resource Manager, select the stack you created for OCI AI Blueprints

2. Go to "Variables" on the left-hand side under Resources section and copy the values for "corrino_admin_username" and "corrino_admin_nonce"

3. Go to the "Application Information" tab under Stack Details

4. Copy the "OCI AI Blueprints API URL" into your browser

5. Upon first access, you must login - providing the "corrino_admin_username" for username and "corrino_admin_nonce" for password

6. Now, you can view and access all API endpoints for your instance of OCI AI Blueprints

## **Option #2: OCI AI Blueprints APIs via Curl/Postman**

You can interact with the APIs locally using Postman, curl or any API platform by doing the following:

1. Get your `OCI AI Blueprints API URL` (will reference this as **API URL** going forward), `corrino_admin_username` (will reference this as **username** going forward) and `corrino_admin_nonce` (will reference this as **password** going forward) by following steps 1 - 3 above in Option #1
2. Once you have your username, password and API URL make a POST request to`<your-oci-ai-blueprints-api-url>/login` API to get your auth token:

```
curl --location --request POST '<your_api_url_here>/login/' \
--header 'Authorization: Token <your_token_here>' \
--form 'username="<your_username_here>"' \
--form 'password="<your_password_here>"'
```

The return JSON will be in the following format:

```
{

"token": "<your_auth_token>",

"is_new": true

}
```

3. Copy the `token` from the response
4. Now you can access any OCI AI Blueprints API by passing in this `token` for Authorization

### Curl Example

```
curl --location --request GET '<your_api_url_here>/oci_shapes/' \
--header 'Authorization: Token <your_token_here>'
```

### Postman

1. Click on the Authorization Tab for the request
2. Select Auth Type = OAuth 2.0
3. Paste your token value
4. Leave Header Prefix as "Token"

## **Option #3: OCI AI Blueprints UI Portal (Under Construction):**

For now, we recommend working with OCI AI Blueprints via the API server. An updated UI experience is being developed currently.
