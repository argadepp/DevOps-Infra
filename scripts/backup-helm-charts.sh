#!/bin/bash

if [ -z "${USER_CRED_USR}" ]; then
   read -p "Enter username for access private helm repo: " username
fi

if [ -z "${USER_CRED_PWD}" ]; then
   read -p "Enter password for access private helm repo: " password
fi




appName=$1
appVersion=$2

echo "app = $appName"
echo "app version = $appVerssion"

git clone https://github.com/argadepp/helm-chart.git
cd helm-chart
git checkout master
git pull origin master

helmcmd="helm"

${helmcmd} repo add --username "${USER_CRED_USR}" --password "${USER_CRED_PWD}" helm-charts https://raw.githubusercontent.com/argadepp/helm-chart/master

$helmcmd repo update

if [ -f "${appVerssionTar}" ]; then
    echo "Private helm chart for ${appName}-${appVersion} already exists"
else
     echo "Cloning into Private helm chart ${appName}-${appVersion}"
     git checkout -b ${appName}-${appVersion}

     if [ "${appName}" == "thanos" ]; then
        rm -rf helm-chart-sources/${appName}
        ${helmcmd} pull thanos/${appName} --version=${appVersion} --untar=true --untardir=./helm-chart/sources/
        ${helmcmd} package helm-chart-sources/${appName}
         sleep 10
     else
        rm -rf helm-chart-sources/${appName}
        ${helmcmd} pull stable/${appName} --version=${appVersion} --untar=true --untardir=./helm-chart/sources/
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
     
     cat >>~/.netrc <<EOF
     machine github.com
             login $GIT_USERNAME
             password $GIT_PASSWORD
     EOF

     echo "Pushing code to repo"
     git push -f origin master
fi

cd ..
sleep 10