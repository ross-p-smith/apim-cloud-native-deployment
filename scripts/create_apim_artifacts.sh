#!/bin/bash
set -euo pipefail

sourceDir=apim_templates
destDir=apim_artifacts

# Remove the apim_artifacts directory and recreate it
rm -rf "${destDir}"
mkdir -p "${destDir}"

# Control the list of environment variables that are substituted
# in case there are some $variables - especially "$ref"
to_be_substituted='$AZURE_SUBSCRIPTION_ID:$APIM_NAME:$RESOURCE_GROUP_NAME'

# Keep a copy of the file seperator
saved_IFS=$IFS
${IFS+':'} unset saved_IFS

# Recursively find all the files in apim_templates and store them in an array separated by newlines
all_files=$(find "${sourceDir}" -type f -print)
IFS=$'\n'

for fileName in ${all_files[@]}; do
    [ -e "$fileName" ] || continue
    echo "Processing ${fileName}"
    # Remove the leading "apim_templates" from the filename
    newFileName="${fileName#${sourceDir}/}"
    # Create the directory structure in apim_artifacts
    mkdir -p "./${destDir}/$(dirname ${newFileName})"
    # Do the envsubst and write the file to apim_artifacts
    envsubst "$to_be_substituted" < "${fileName}" > "./${destDir}/${newFileName}";
done

# Restore the file seperator
IFS=$saved_IFS
${saved_IFS+':'} unset IFS