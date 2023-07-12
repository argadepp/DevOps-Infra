#!/bin/bash

set -x -o errexit -o pipefail
REPO_GIT="https://argadepp.github.io/helm-chart/"
# REPO="argadepp.github.io"

k8s_script_dir="${job_root_dir}/scripts" 
thanos_version=$(cat ${k8s_script_dir}/utilities-version.json | jq -r .thanos_version )
prom_version=$(cat ${k8s_script_dir}/utilities-version.json | jq -r .prom_version )


run_backup_thanos() {
    bash ${WORKSPACE}/scripts/backup-helm-charts.sh "thanos" "${thanos_version}"
    helm repo update
    echo "Testing Dry Run"
   # helm upgrade --install thanos $REPO_GIT/thanos --version "${thanos_version}" --namespace utilities --dry-run -o json | jq 
}

run_backup_prom() {
    bash ${WORKSPACE}/scripts/backup-helm-charts.sh "prom" "${prom_version}"
    helm repo update
    echo "Testing Dry Run"
   # helm upgrade --install thanos $REPO_GIT/thanos --version "${thanos_version}" --namespace utilities --dry-run -o json | jq 
}



helm repo add thanos https://charts.bitnami.com/bitnami
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

utilities_list="thanos \
                prom"

for utility_name in ${utilities_list}; do
    toggle_variable="backup_${utility_name}"
    if [[ "${!toggle_variable}" == true ]]; then
         run_backup_${utility_name}
    else 
        echo "Skipping update of '${utility_name}'. Value of '${toggle_variable}' is '${!toggle_variable}' "
    fi
done             
