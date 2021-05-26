# Tython SFDX Project Template

## Setup

(PRE-REQ: `Node`, `sfdx-cli`, `openssl`, `sed` are required, installation depending on your system!)

1. Run `npm install` to bring in all development dependencies.

2. Run `npm run setup` for Org Authentication - you will need the project auth key from 1Password

## Dev/Build
### For Single Org or 1st Generation Managed Package Development

1. Run `npm start` to spin up a scratch org and run the initial metadata deployment

2. A GitHub Action will run a check-only deploy against production upon opening a PR

3. A GitHub Action will deploy to a QA org upon merging a PR into `dev`

4. A GitHub Action will deploy to the production/packaging org upon merging a PR into `master`

### For 2nd Generation Managed Package Developmment

1. Run `npm start` to spin up a scratch org and run the initial metadata deployment

2. Manually :scream: tweak the version name & number info in `sfdx-project.json` then run `npm run prep-beta` to generate a new build version of an in-development/beta package, which can then be installed to a new test scratch org

3. Run `npm run prep-release` to run through the pre-release flow to ready the package for new version release, including automatic installation to one final test org

## Test

### For Single Org or 1st Generation Managed Package Development

1. Run `npm start` after pulling down feature branch to push changes to a new scratch org for testing

### For 2nd Generation Managed Package Developmment

1. Run `npm run test-pkg` to install the latest version of the package to a scratch org for testing
## Description of Files and Directories

`force-app/` is the main src directory. Note `tests/` here is for global testing utils/mocks. Individual component unit test files live in the same folder as said component.

`scripts/` directory contains shell scripts for orchestrating project flows

`data/` folder contains sample data for hydrating a newly created scratch org

`.github` directory houses GitHub Action workflows for continuous integration; requires adding the project auth key from 1Password as a GitHub secret named AUTH_FILE_KEY

`.editorconfig` contains common editor settings for our projects. Note that VSCode currently requires an extension (see below)

`.vscode/` contains VSCode-specific editor settings and extension recommendations for sharing amongst team members

## Recommended Extensions for VSCode

[Salesforce Extension pack bundle, incl LWC, Apex, CLI support](https://marketplace.visualstudio.com/items?itemName=salesforce.salesforcedx-vscode)

[ESLint](https://marketplace.visualstudio.com/items?itemName=dbaeumer.vscode-eslint)

[Editor config](https://marketplace.visualstudio.com/items?itemName=EditorConfig.EditorConfig)

[Markdown Linter](https://marketplace.visualstudio.com/items?itemName=DavidAnson.vscode-markdownlint)
