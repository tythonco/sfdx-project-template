#!/bin/bash

project_name() {
    echo $(node -e "console.log(require('./package.json').name);")
}

devhub_name() {
    echo "$(project_name)DevHub"
}

package_dir_guess() {
    local project_name = $1
    echo "$project_name"\
        | sed -E 's/[[:blank:]]+([a-z0-9])/\U\1/gi'\
        | sed -E 's/_([A-Z0-9])/\U\1/gi'\
        | sed -E 's/-([A-Z0-9])/\U\1/gi'\
        | sed -E 's/^([A-Z0-9])/\l\1/'
}
