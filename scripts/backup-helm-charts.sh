#!/bin/bash


cat >>~/.netrc <<EOF
machine github.com
        login $GIT_USERNAME
        password $GIT_PASSWORD
EOF

appName=$1
appVersion=$2

echo "app = $appName"
echo "app version = $appVersion"

git clone https://github.com/argadepp/helm-chart.git
cd helm-chart
git checkout master
git pull origin master

helmcmd="helm"


$helmcmd repo update

if [ -f "${versionTar}" ]; then
    echo "Private helm chart for ${appName}-${appVersion} already exists"
else
     echo "Cloning into Private helm chart ${appName}-${appVersion}"
     git checkout -b ${appName}-${appVersion}

     if [ "${appName}" == "thanos" ]; then
        rm -rf helm-chart-sources/${appName}
        echo "In if"
        ${helmcmd} pull thanos/${appName} --version=${appVersion} --untar=true --untardir=./helm-chart-sources/
        ${helmcmd} package helm-chart-sources/${appName}
        sleep 10
     elif [ "${appName}" == "prom" ]; then
        rm -rf helm-chart-sources/kube-prometheus-stack
        echo "In if"
        ${helmcmd} pull prometheus-community/kube-prometheus-stack --version=${appVersion} --untar=true --untardir=./helm-chart-sources/
        ${helmcmd} package helm-chart-sources/kube-prometheus-stack
        sleep 10     
     elif [ "${appName}" == "argo" ]; then
        rm -rf helm-chart-sources/argo-cd
        echo "In if"
        ${helmcmd} pull argo/argo-cd --version=${appVersion} --untar=true --untardir=./helm-chart-sources/
        ${helmcmd} package helm-chart-sources/argo-cd
        sleep 10           
     else
        echo "In else"
        rm -rf helm-chart-sources/${appName}
        ${helmcmd} pull stable/${appName} --version=${appVersion} --untar=true --untardir=./helm-chart-sources/
        ${helmcmd} package helm-chart-sources/${appName}
     fi
     echo "Stating code"
     
     git add .
     
     echo "Commiting code"
     git commit -m "Adding code for ${appName}-${appVersion}"
     
     echo "Cheking merge"
     git checkout master
     ${helmcmd} repo index --url https://raw.githubusercontent.com/argadepp/helm-chart/master --merge index.yaml
     git add -u
     git commit --amend --no-edit 
     

     echo "Pushing code to repo"
     git push -f origin master
fi

cd ..
sleep 10
