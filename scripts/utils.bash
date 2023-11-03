#!/bin/bash

# Return the name of the project given the contents of the `package.json` file
# TODO: Generalize this to accept a file name and a key path
project_name() {
    echo $(node -e "console.log(require('./package.json').name);")
}

auth_file_suffix() {
    echo $(node -e "console.log(require('./package.json').authFileSuffix);")
}

# Return the standard Dev Hub name given the project name
devhub_name() {
    echo "$(project_name)DevHub"
}

# Return the standard production org name
prod_name() {
    echo "$(project_name)Pro"
}

# Return the standard QA org name
qa_name() {
    echo "$(project_name)QA"
}


