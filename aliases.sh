# A collection of potentially useful aliases that developers can place in their startup script

alias sf-list="sf org list"
alias sf-log="sf apex get log --number 1 --output-dir logs"
alias sf-alias="sf alias list"
alias sf-push="sf project deploy start --ignore-conflicts"
alias sf-test="sf apex run test --code-coverage --result-form human --synchronous"
alias sf-org="sf cofig set target-org=$1"
alias sf-pt="sf-push; sf-test"
alias soql="sf data query --query $1"
