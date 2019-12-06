# Get file key from environment variable, decrypt req'd file for cmd
echo "Setting up QA Connection..."
openssl enc -d -aes-256-cbc -md md5 -in qa_auth_url.txt.enc -out qa_auth_url.txt -k $AUTH_FILE_KEY

# Authenticate to salesforce QA org
echo "Authenticating to Salesforce..."
sfdx force:auth:sfdxurl:store -f qa_auth_url.txt -a QA && rm qa_auth_url.txt
