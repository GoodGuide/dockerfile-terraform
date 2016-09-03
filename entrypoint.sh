#!/bin/bash

set -euo pipefail
# set -x

echo 'welcome to terraform-shell'

[ -f .envrc ] && source .envrc

getUserEmail() {
	aws iam get-user | jq -r '.User.UserName'
}

lockResource() {
	local modulePath="$1"; shift
	local email="$1"; shift
	local time="$(date --utc '+%s')"

	local lockObj="$(cat <<-EOF
		{
			"module_path": {"S": "${modulePath}"},
			"user": {"S": "${email}"},
			"time": {"N": "${time}"}
		}
	EOF
	)"

	local eav="$(cat <<-EOF
		{
			":leaseStartTime": {"N": "$(($(date --utc '+%s') - 3600))"}
		}
	EOF
	)"

	aws dynamodb put-item \
			--table-name terraform-locks \
			--item "${lockObj}" \
			--condition-expression "attribute_not_exists(module_path) OR #T < :leaseStartTime" \
			--expression-attribute-values "${eav}" \
			--expression-attribute-names '{"#T": "time"}' \
	|| die "Failed to lock ${modulePath}"

	echo "locked ${modulePath} successfully"
}

releaseLock() {
	local modulePath="$1"; shift
	local email="$1"; shift

	local key="$(cat <<-EOF
		{
			"module_path": {"S": "${modulePath}"}
		}
	EOF
	)"

	local eav="$(cat <<-EOF
		{
			":user": {"S": "${email}"}
		}
	EOF
	)"

	aws dynamodb delete-item \
			--table-name terraform-locks \
			--key "${key}" \
			--condition-expression "#U = :user" \
			--expression-attribute-values "${eav}" \
			--expression-attribute-names '{"#U": "user"}' \
	|| die "Failed to release lock on ${modulePath}"

	echo "released lock on ${modulePath} successfully"
}


die() {
	echo "$1"
	exit 1
}

main() {
	me="$(getUserEmail)"

	lockResource "${module_path}" "${me}"
	bash
	releaseLock "${module_path}" "${me}"
}

main $@
