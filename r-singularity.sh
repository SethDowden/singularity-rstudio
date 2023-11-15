#!/usr/bin/env bash

# check if /R/3.6.2/singularity-rstudio.simg exists
if [ -f /R/3.6.2/singularity-rstudio.simg ]; then
    echo "singularity-rstudio.simg exists. Skipping..."
else
    echo "singularity-rstudio.simg does not exist. Creating..."
    singularity pull --name singularity-rstudio.simg shub://nickjer/singularity-rstudio
    mv singularity-rstudio.simg /R/3.6.2/singularity-rstudio.simg
fi 

# Confirm username is supplied
echo "Username: ${USERNAME}"

read -sp 'Enter password: ' password
echo
read -sp 'Confirm password: ' password_confirm
echo

if [[ "$password" == "$password_confirm" ]]; then
    export RSTUDIO_PASSWORD=$password
else
    echo "Passwords do not match. Exiting..."
    exit 1
fi

echo "Starting RStudio Server..."
echo "Run the following command in a new terminal window to connect to RStudio Server:"
echo "ssh -Nf -L 8787:localhost:8787 ${USERNAME}@${HOSTNAME}"
echo "Then open a web browser and go to http://localhost:8787"
cd R && singularity exec --bind /R/3.6.2:/srv/shiny-server /R/3.6.2/singula