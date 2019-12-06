# Get the private url from environment variable, create required file for cmd
echo "Setting up Prod Connection..."
openssl enc -d -aes-256-cbc -md md5 -in prod_auth_url.txt.enc -out prod_auth_url.txt -k $AUTH_FILE_KEY

# Authenticate to salesforce Prod org
echo "Authenticating..."
sfdx force:auth:sfdxurl:store -f prod_auth_url.txt -a Prod && rm prod_auth_url.txt
