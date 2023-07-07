#!/bin/bash

set -x -o errexit -o pipefail
REPO_GIT="https://argadepp.github.io/helm-chart/"
# REPO="argadepp.github.io"

run_backup_thanos() {
    bash ${WORKSPACE}/scripts/backup-helm-charts.sh "thanos" "${thanos_version}"
    helm repo update
    echo "Testing Dry Run"
   # helm upgrade --install thanos $REPO_GIT/thanos --version "${thanos_version}" --namespace utilities --dry-run -o json | jq 
}

k8s_script_dir="${job_root_dir}/scripts/" 
thanos_version=$(cat ${k8s_script_dir}/utilities-versoin.json | jq -r .thanos_version )

# add repo

helm repo add https://charts.bitnami.com/bitnami

utilities_list="thanos"

for utility_name in ${utilities_list}; do
    toggle_version="backup_${utility_name}"
    if [[ "${!toggle_version}" == true ]]; then
         run_backup_${utility_name}
    else 
        echo "Skipping update of '${utility_name}'. Value of '${toggle_variable}' is '${!toggle_variable}' "
    fi
done             