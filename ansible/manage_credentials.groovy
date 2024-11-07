import com.cloudbees.plugins.credentials.CredentialsScope
import com.cloudbees.plugins.credentials.SystemCredentialsProvider
import com.cloudbees.plugins.credentials.domains.Domain
import com.cloudbees.plugins.credentials.impl.*
import com.cloudbees.plugins.credentials.common.*
import hudson.util.Secret
import jenkins.model.Jenkins
import com.cloudbees.plugins.credentials.SecretBytes

def domain = Domain.global()
def store = SystemCredentialsProvider.getInstance().getStore()

def updateOrAddCredential(existingCred, newCred) {
    if (existingCred) {
        store.updateCredentials(domain, existingCred, newCred)
    } else {
        store.addCredentials(domain, newCred)
    }
}

// AWS Credentials
def awsCredId = "aws-credentials"
def existingAwsCred = store.getCredentials(domain).find { it.id == awsCredId }
def awsCred = new AWSCredentialsImpl(
    CredentialsScope.GLOBAL,
    awsCredId,
    "{{ credentials['aws-credentials']['access_key_id'] }}",
    "{{ credentials['aws-credentials']['secret_access_key'] }}",
    "AWS Credentials"
)
updateOrAddCredential(existingAwsCred, awsCred)

// AWS Account ID (Text)
def awsAccountIdCredId = "aws-account-id"
def existingAwsAccountIdCred = store.getCredentials(domain).find { it.id == awsAccountIdCredId }
def awsAccountIdCred = new StringCredentialsImpl(
    CredentialsScope.GLOBAL,
    awsAccountIdCredId,
    "AWS Account ID",
    Secret.fromString("{{ credentials['aws-account-id'] }}")
)
updateOrAddCredential(existingAwsAccountIdCred, awsAccountIdCred)

// AWS Hosted Zone ID (Text)
def awsHostedZoneIdCredId = "aws-hosted-zone-id"
def existingAwsHostedZoneIdCred = store.getCredentials(domain).find { it.id == awsHostedZoneIdCredId }
def awsHostedZoneIdCred = new StringCredentialsImpl(
    CredentialsScope.GLOBAL,
    awsHostedZoneIdCredId,
    "AWS Hosted Zone ID",
    Secret.fromString("{{ credentials['aws-hosted-zone-id'] }}")
)
updateOrAddCredential(existingAwsHostedZoneIdCred, awsHostedZoneIdCred)

// GCP Project ID (Text)
def gcpProjectCredId = "gcp-project"
def existingGcpProjectCred = store.getCredentials(domain).find { it.id == gcpProjectCredId }
def gcpProjectCred = new StringCredentialsImpl(
    CredentialsScope.GLOBAL,
    gcpProjectCredId,
    "GCP Project ID",
    Secret.fromString("{{ credentials['gcp-project'] }}")
)
updateOrAddCredential(existingGcpProjectCred, gcpProjectCred)

// GCP Credentials File
{% if credentials['gcp-credentials-file'] is defined %}
def gcpFileCredId = "gcp-credentials-file"
def existingGcpFileCred = store.getCredentials(domain).find { it.id == gcpFileCredId }
def gcpFileBytes = SecretBytes.fromBytes({{ gcp_file_base64 }}.decodeBase64())
def gcpFileCred = new FileCredentialsImpl(
    CredentialsScope.GLOBAL,
    gcpFileCredId,
    "GCP Credentials File",
    "{{ gcp_file_name }}",
    gcpFileBytes
)
updateOrAddCredential(existingGcpFileCred, gcpFileCred)
{% endif %}

// Twilio Auth Token (Text)
def twilioAuthTokenCredId = "twilio-auth-token"
def existingTwilioAuthTokenCred = store.getCredentials(domain).find { it.id == twilioAuthTokenCredId }
def twilioAuthTokenCred = new StringCredentialsImpl(
    CredentialsScope.GLOBAL,
    twilioAuthTokenCredId,
    "Twilio Auth Token",
    Secret.fromString("{{ credentials['twilio-auth-token'] }}")
)
updateOrAddCredential(existingTwilioAuthTokenCred, twilioAuthTokenCred)

// Azure ACR Credentials (Username/Password)
def azureAcrCredId = "azure-acr-credentials"
def existingAzureAcrCred = store.getCredentials(domain).find { it.id == azureAcrCredId }
def azureAcrCred = new UsernamePasswordCredentialsImpl(
    CredentialsScope.GLOBAL,
    azureAcrCredId,
    "Azure ACR Credentials",
    "{{ credentials['azure-acr-credentials']['username'] }}",
    "{{ credentials['azure-acr-credentials']['password'] }}"
)
updateOrAddCredential(existingAzureAcrCred, azureAcrCred)

// Azure Client ID (Text)
def azureClientIdCredId = "azure-client-id"
def existingAzureClientIdCred = store.getCredentials(domain).find { it.id == azureClientIdCredId }
def azureClientIdCred = new StringCredentialsImpl(
    CredentialsScope.GLOBAL,
    azureClientIdCredId,
    "Azure Client ID",
    Secret.fromString("{{ credentials['azure-client-id'] }}")
)
updateOrAddCredential(existingAzureClientIdCred, azureClientIdCred)

// Azure Subscription ID (Text)
def azureSubscriptionIdCredId = "azure-subscription-id"
def existingAzureSubscriptionIdCred = store.getCredentials(domain).find { it.id == azureSubscriptionIdCredId }
def azureSubscriptionIdCred = new StringCredentialsImpl(
    CredentialsScope.GLOBAL,
    azureSubscriptionIdCredId,
    "Azure Subscription ID",
    Secret.fromString("{{ credentials['azure-subscription-id'] }}")
)
updateOrAddCredential(existingAzureSubscriptionIdCred, azureSubscriptionIdCred)

// Azure Tenant ID (Text)
def azureTenantIdCredId = "azure-tenant-id"
def existingAzureTenantIdCred = store.getCredentials(domain).find { it.id == azureTenantIdCredId }
def azureTenantIdCred = new StringCredentialsImpl(
    CredentialsScope.GLOBAL,
    azureTenantIdCredId,
    "Azure Tenant ID",
    Secret.fromString("{{ credentials['azure-tenant-id'] }}")
)
updateOrAddCredential(existingAzureTenantIdCred, azureTenantIdCred)

// Azure Client Secret (Text)
def azureClientSecretCredId = "azure-client-secret"
def existingAzureClientSecretCred = store.getCredentials(domain).find { it.id == azureClientSecretCredId }
def azureClientSecretCred = new StringCredentialsImpl(
    CredentialsScope.GLOBAL,
    azureClientSecretCredId,
    "Azure Client Secret",
    Secret.fromString("{{ credentials['azure-client-secret'] }}")
)
updateOrAddCredential(existingAzureClientSecretCred, azureClientSecretCred)
