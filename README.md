# Tython SFDX Project Template

## Dev, Build and Test

(PRE-REQ: `Node`, `sfdx-cli`, `openssl`, `sed` are required, installation depending on your system!)

1. Run `npm install` to bring in all development dependencies.

2. Configuration (if project starter):
In `config/project-scratch-def.json` there *might* be org features that need to be enabled case-by-case. See [docs](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_scratch_orgs_def_file.htm).

Make sure you have set up and identified a Dev Hub org, a Prod org (if different from Dev Hub org), and a QA sandbox org.

For ISV projects, be sure to [link the managed package namespace to the Dev Hub](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_reg_namespace.htm) and then set the namespace in `sfdx-project.json`

3. Authenticate to Dev Hub org for scratch org creation using auth flow
(see `Org Authentication`) and if project starter, set up CI/CD (see `CI Setup`)

4. Script to spin up scratch orgs included (see `scripts/create-scratch-org.sh`); Use shortcut `npm start` once auth is set up.

5. If you'd like code coverage results to be retrieved when invoking Apex unit tests via sfdx (recommended) then add `"salesforcedx-vscode-core.retrieve-test-code-coverage": true` to your `.vscode/settings.json` file

### Org Authentication

*Use the shortcut:*

1. `npm run setup`.

OR

*Manual steps for project starter:*

1. Setup Dev Hub:
Run command `sfdx force:auth:web:login -s -a {ProjectName}DevHub`. (Note the namespaced alias.)
Login portal page will open; login to org using the appropriate user/pass.

2. Once the web auth flow completes successfully, run `sfdx force:org:display --verbose`
Note the "Sfdx Auth Url" value.

3. Create a local file `sfdx_auth_url.txt` and paste the value for "SFDX_AUTH_URL" obtained above (and nothing else).
This is for spinning up new scratch orgs locally via `create-scratch-org` script and must be kept out of source control!

4. Generate a secure password that will be used for encryption/decryption of the auth_url file, e.g. obtained via 1Password generator.
This password will be set in both CI and securely shared with other team members.

5. Use the `openssl` utility to encrypt `sfdx_auth_url.txt`. This *will* be checked into source.
NOTE: from the command below you need to sub in the secure password for the `-k` argument.

```bash
openssl enc -aes-256-cbc -md md5 -k “Super Secure Password!!!” -in sfdx_auth_url.txt -out sfdx_auth_url.txt.enc
```

6. Share the auth_url file password via secure organization methods, such as a 1Password secure note.

7. Modify variable in `create-scratch-org.sh` with the project name.

8a. If the target org for production deployments is the Dev Hub org then use `cp` to copy `sfdx_auth_url.txt` and `sfdx_auth_url.txt.enc` to `prod_auth_url.txt` and `prod_auth_url.txt.enc`, respectively

8b. If the target org for production deployments is NOT the Dev Hub org (such as for ISV projects) then repeat steps 1 through 5 using `{ProjectName}Prod` as an org alias and `prod_auth_url.txt` for the auth url

For the encryption password just use the same one from the Dev Hub org.

9. If a Salesforce sandbox has been set up for QA then repeat `Org Authentication` for QA org using `sfdx force:auth:web:login -a {ProjectName}QA -r https://test.salesforce.com`.

To get the QA org's auth url, use `sfdx force:org:display -u {ProjectName}QA --verbose`.

For the auth file creation/encryption, follow steps 3-5 in `Org Authentication`. (Use `qa_auth_url.txt` to differentiate.)

For the encryption password just use the same one from the Dev Hub & Prod org(s).

OR

*Manual steps for non project starter(s):*

1. Retrieve secure encryption/decryption password via secure sharing method, such as 1Password

2. Use the `openssl` utility to decrypt `sfdx_auth_url.txt.enc`

```bash
openssl enc -d -aes-256-cbc -md md5 -k "Super Secure Password!!!" -in sfdx_auth_url.txt.enc -out sfdx_auth_url.txt
```

### CircleCI Setup for Project Starter

1. Follow steps from `Org Authentication`, making sure a Salesforce sandbox has been set up for QA.

2. Login to CircleCI under the org account. Goto "Add Project" and link the new project repo.
NOTE: This kicks off a first build; Immediately cancel that build because it will fail.

3. Go into "Settings" => "Environment Variables" for this project.
Add a new env var named `AUTH_FILE_KEY` and give it the password you used when encrypting production & QA auth_url files.

4. Choose `Advanced Settings` and turn on `Only build pull requests`

5. In the Github repository set `dev` as the default branch so all PRs will be opened against it instead of master.

6. Create a new branch that is one commit behind `master` in the Github repository named `master-clone` and open a PR for merging master into this branch named `Dummy PR for CircleCI - NEVER CLOSE/MERGE` Since we have `dev` set as our default branch, enabling the option within CircleCI to only build on commits to branches with open PRs and/or the default branch itself builds will not run on commits to master unless this PR remains open. [See the related CircleCI forum for more info](https://discuss.circleci.com/t/option-to-enable-build-on-several-default-branches/13543)

If you've done everything correctly then opening a new PR or pushing a commit to an open PR will run a check-only deployment validation against production, merging a PR into `dev` will kick off a deployment to QA, and merging a PR into `master` will kick off a deployment to production :+1:

## Resources

[LWC Recipes](https://github.com/trailheadapps/lwc-recipes)

[eBikes Sample App](https://github.com/trailheadapps/ebikes-lwc)

[DreamHouse Sample App](https://github.com/dreamhouseapp/dreamhouse-lwc)

[CI/CD Setup Instructions](https://mickwheelz.net/index.php/2018/10/03/continuous-integration-with-github-sfdx-and-circleci-easier-than-you-think/)

[Salesforce Logins with Auth Url for CI/CD](http://www.crmscience.com/single-post/2018/01/22/Salesforce-Logins-for-Continuous-Integration-and-Delivery)

## Description of Files and Directories

`force-app/` is the main src directory. Note `tests/` here is for global testing utils/mocks. Individual component unit test files live in the same folder as said component.

`scripts/` directory contains shell scripts for orchestrating project flows

`data/` folder contains sample data for hydrating a newly created scratch org

`.circleci` directory houses continuous integration configs; Note that this requires creating a Connected App in the Salesforce org and then hooking into CircleCI [how to](https://docs.google.com/document/d/1deSus_938pt4832rDeND51ppnOgKNZxM-dFIyZJJUsw/edit?usp=sharing)

`.editorconfig` contains common editor settings for our projects. Note that VSCode currently requires an extension (see below)

`.vscode/` contains VSCode-specific editor settings and extension recommendations for sharing amongst team members

## Recommended Extensions for VSCode

[Salesforce Extension pack bundle, incl LWC, Apex, CLI support](https://marketplace.visualstudio.com/items?itemName=salesforce.salesforcedx-vscode)

[ESLint](https://marketplace.visualstudio.com/items?itemName=dbaeumer.vscode-eslint)

[Editor config](https://marketplace.visualstudio.com/items?itemName=EditorConfig.EditorConfig)

[Markdown Linter](https://marketplace.visualstudio.com/items?itemName=DavidAnson.vscode-markdownlint)

## Issues

-Should we add automatic `__tests__` folder/file creation when creating new LWC?

-Should unit test scripts be run on pre-commit?

-Install stylelint for css, can be added to lint-staged
