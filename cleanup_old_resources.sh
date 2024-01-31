#!/bin/bash

echo "Starting the Cleanup old tf resources script..."

# Get resource blocks for resources created without a module (excluding data sources)
echo "Getting resource blocks for resources created without a module..."
resource_blocks=$(terraform show -json | jq -r '.values.root_module.resources[] | select(.type != "terraform_remote_state") | select(.values.tags.creationDate | if . then (now - (strptime("%m/%d/%Y") | mktime)) > 7776000 else false end) | .address | select(startswith("data.") | not)')

# Get resource blocks for resources created via a module (excluding data sources)
echo "Getting resource blocks for resources created via a module..."
module_resource_blocks=$(terraform show -json | jq -r '.values.root_module.child_modules[]? | select(.type != "terraform_remote_state") | .resources[]? | select(.values.tags.creationDate | if . then (now - (strptime("%m/%d/%Y") | mktime)) > 7776000 else false end) | .address' | uniq)

# Combine results of resource blocks created with and without a module
old_resource_blocks="${resource_blocks} ${module_resource_blocks}"

# Iterate over old resource blocks and comment them out
echo "Iterating over old resource blocks and commenting out the blocks..."

for old_resource_block in $old_resource_blocks
do
    # Check if it's a module resource or a general resource
    if [[ $old_resource_block == module* ]]; then
        # It's a module resource, find the corresponding block in the .tf files
        module_name=$(echo $old_resource_block | cut -d. -f2)
        echo "Commenting out the block for module resource: module $module_name"
        grep -rl "module \"$module_name\"" *.tf | xargs sed -i.bak "/module \"$module_name\" {/,/^}/ s/^/#/"
    else
        # It's a general resource, extract the type and name of the resource
        resource_type=$(echo $old_resource_block | cut -d. -f1)
        resource_name=$(echo $old_resource_block | cut -d. -f2)
        
        # Find the corresponding block in the .tf files
        echo "Commenting out the block for general resource: $resource_type $resource_name"
        grep -rl "\"$resource_type\" \"$resource_name\" {" *.tf | xargs sed -i.bak "/$resource_type\" \"$resource_name\" {/,/^}/ s/^/#/"
    fi
done

echo "Completed! Removing temporary files created by sed..."

# Cleanup: remove temporary files created by sed
find . -name "*.bak" -type f -delete

echo "Resources over 90 days commented!"
