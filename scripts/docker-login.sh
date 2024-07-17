export GHCR_USERNAME=${DUSERNAME}
export GHCR_TOKEN=${DPASSWORD}

echo $GHCR_TOKEN | docker login ghcr.io -u $GHCR_USERNAME --password-stdin
