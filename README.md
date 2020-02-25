# Tython SFDX Project Template

## Dev, Build and Test

1. Run `npm install` to bring in all development dependencies.

2. Use SFDX to create new LWC; Note files will auto-lint on git commit.

3. Generate keys and a connected app in the Dev Hub org for scratch org creation (see `Connected App Setup`) & CI/CD (see `CircleCI Setup`)

4. Scripts to spin up scratch orgs included (see `scripts/create-scratch-org.sh`)

5. If you'd like code coverage results to be retrieved when invoking Apex unit tests via sfdx (recommended) then add `"salesforcedx-vscode-core.retrieve-test-code-coverage": true` to your `.vscode/settings.json` file

## Connected App Setup

1. Run `bash scripts/generate-keys.sh`

2. Create a Connected App in the Dev Hub org. (Setup > App Manager > New Connected App)

3. Enter `CICD` and `devs@tython.co` for the Connected App name & contact email, respectively.

4. Check `Enable OAuth Settings`, enter `http://localhost:1717/OauthRedirect` for the Callback URL, & select all available OAuth scopes.

5. Select `Use digital signatures` and upload the `server.crt` file created from step 1 (if you will NOT be setting up a QA org for CI/CD then you can now delete this file)

6. Leave the remaining defaults for the connected app and save your work by selecting `Save` and then `Continue` when prompted.

7. Copy the `Consumer Key` value and paste this into the `SFDC_DEVHUB_CLIENTID` value within `scripts/create-scratch-org.sh`

8. Enter a System Administrator's username from the Dev Hub org into `SFDC_DEVHUB_USER` within `scripts/create-scratch-org.sh`

9. Click `Manage` and then `Edit Policies` on the newly created connected app and then set `Permitted Users` to `Admin approved users are pre-authorized` before clicking `Save`

10. Scroll down and click `Manage Profiles` and then select `System Administrator` and hit `Save`

11. Upload a new note to LastPass containing the server.key file contents for other devs to use. Note: NEVER track this file in git. If it is ever accidentally committed then assume it has been compromised, generate new keys, and update the connected app and LastPass and notify teammates of the change.

## CircleCI Setup

1. Follow the steps from `Connected App Setup` - note this Dev Hub org will be treated as the Production instance by CircleCI.

2. Create a Salesforce sandbox from the Dev Hub / Production org to be used for QA

3. Repeat steps 2-8 from `Connected App Setup` in this QA org (you can reuse the original server.crt file and then delete it)

4. Log into CircleCI via your Github account and click `Add Projects`

5. Select your Github repository then `Set Up Project` and `Start building`

6. Cancel the first build and click the gear icon to update the project settings

7. Choose `Environment Variables` and add the following:
    * `SFDC_SERVER_KEY` This value can be copied from the output of running `base64 server.key` locally
    * `SFDC_PROD_CLIENTID` This can be copied from `SFDC_DEVHUB_CLIENTID` in `scripts/create-scratch-org.sh`
    * `SFDC_PROD_USER` This can be copied from `SFDC_DEVHUB_USER` in `scripts/create-scratch-org.sh`
    * `SFDC_QA_CLIENTID` This can be copied from the Consumer Key of the connected app you created in the sandbox QA org
    * `SFDC_QA_USER` This should be the username of a system administrator for your sandbox QA org

8. Choose `Advanced Settings` and turn on `Only build pull requests`

9. In the Github repository set `dev` as the default branch so all PRs will be opened against it instead of master.

10. Create a new branch off `master` in the Github repository named `master-clone` and open a PR for merging master into this branch named `Dummy PR for CircleCI - NEVER CLOSE/MERGE` Since we have `dev` set as our default branch, enabling the option within CircleCI to only build on commits to branches with open PRs and/or the default branch itself builds will not run on commits to master unless this PR remains open. [See the related CircleCI forum for more info](https://discuss.circleci.com/t/option-to-enable-build-on-several-default-branches/13543)

If you've done everything correctly then opening a new PR or pushing a commit to an open PR will run a check-only deployment validation against production, merging a PR into `dev` will kick off a deployment to QA, and merging a PR into `master` will kick off a deployment to production :+1:

## Github Action CI Setup

(WIP)

1. This workflow utilizes the auth-url-file flow for connecting to orgs.
After connecting to DevHub org, [add required secrets to your project repo](https://help.github.com/en/actions/configuring-and-managing-workflows/creating-and-storing-encrypted-secrets)
E.g. `AUTH_FILE_KEY` used to encrypt the Auth URL file; See `.github/workflow/validate.yml` for other referenced secrets.

2. Note the "*_auth_url.txt" files used in this project; The default is "prod_auth_url.txt" (and "qa_auth_url.txt", if utilizing a sandbox).
If the auth file names are changed, "validate" workflow may not work without modification.

3. By default, the automated validation workflow will trigger on opening a pull request targeting either "dev" or "master" branches.
If "dev" is the target, a succesful validation run will be followed with a deployment to QA/Sandbox (WIP).
If "master" is the target, a successful validation will indicate that deployment to Production org should be ready (WIP).

## Resources

[LWC Recipes](https://github.com/trailheadapps/lwc-recipes)
[eBikes Sample App](https://github.com/trailheadapps/ebikes-lwc)
[DreamHouse Sample App](https://github.com/dreamhouseapp/dreamhouse-lwc)
[CI/CD Setup Instructions](https://mickwheelz.net/index.php/2018/10/03/continuous-integration-with-github-sfdx-and-circleci-easier-than-you-think/)
[Github Actions Documentation](https://help.github.com/en/actions)
[Sample Github Action workflow files](https://github.com/actions/starter-workflows/tree/master/ci)

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
