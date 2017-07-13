BOLD=$(tput bold)
NORMAL=$(tput sgr0)
GIT_URL=https://github.com/core-api/python-client
REPO_ID=rattlesnake

demo_dependencies()
{
    pip install virtualenv
    mkdir -p ~/tmp
    cd ~/tmp
    python -m virtualenv env
    source ~/tmp/env/bin/activate
    pip install coreschema itypes uritemplate
}

dependencies()
{
    echo ""
    echo "${BOLD} Check that pulp python plugin is installed ${NORMAL}"
    echo ""
    read -p ":"
    echo ""
    echo "$ rpm -qa | grep pulp-python"
    rpm -qa | grep pulp-python
    echo ""
}

repo_create()
{
  echo ""
  echo "${BOLD}Login as pulp-admin${NORMAL}"
  echo ""
  pulp-admin login -u "${PULP_USER:-admin}" -p "${PULP_PASSWORD:-admin}"
  echo ""
  echo "${BOLD} Create a python repository ${NORMAL}"
  echo ""
  echo "${BOLD}pulp-admin python repo create --repo-id ${REPO_ID}.${NORMAL}"
  read -p ":"
  echo ""
  pulp-admin python repo create --repo-id rattlesnake
}

upload()
{
  echo ""
  echo "${BOLD}Pulp accepts source distributions and wheels, which are uploaded"
  echo "in the same way. Let’s clone the pulp_python plugins package and build a"
  echo "source package suitable for uploading to Pulp${NORMAL}"
  echo ""
  echo "${BOLD}mkdir ~/tmp && cd ~/tmp && git clone ${GIT_URL}" \
      "&& cd python-client"
  mkdir ~/tmp && cd ~/tmp && git clone ${GIT_URL} && cd python-client
  echo "${BOLD}Run setup.py to create tarball for upload to pulp${NORMAL}"
  echo ""
  echo "${BOLD}$ ./setup.py sdist.${NORMAL}"
  read -p ":"
  echo ""
  ./setup.py sdist
  echo ""
  read -p "The tar ball should now be in the dist directory:"
  echo ""
  echo "${BOLD}$ ls dist${NORMAL}"
  ls dist
  echo ""
  read -p ":"
  echo ""
  echo "${BOLD}Upload the tarball into our repo${NORMAL}"
  echo ""
  echo "${BOLD}pulp-admin python repo upload --repo-id ${REPO_ID} -f $(ls dist/*)${NORMAL}"
  read -p ":"
  echo ""
  pulp-admin python repo upload --repo-id ${REPO_ID} -f $(ls dist/*)
}

list()
{
  echo ""
  echo "${BOLD}List content in the repository.${NORMAL}"
  read -p ":"
  echo ""
  echo "${BOLD} pulp-admin python repo packages --repo-id ${REPO_ID} --match name=coreapi ${NORMAL}"
  pulp-admin python repo packages --repo-id ${REPO_ID} --match name=coreapi
  echo ""
}

publish()
{
  echo ""
  echo "${BOLD}Publish the repository so others can access the package.${NORMAL}"
  read -p ":"
  echo ""
  echo "${BOLD} $ pulp-admin python repo publish run --repo-id ${REPO_ID} ${NORMAL}"
  pulp-admin python repo publish run --repo-id ${REPO_ID}
}

install()
{
  echo ""
  echo "${BOLD}Install the package that is hosted on the pulp server${NORMAL}"
  read -p ":"
  echo ""
  echo "${BOLD} $ pip install -i http://pulp.example.com/pulp/python/web/${REPO_ID}/simple/ coreapi"
  pip install -i http://pulp.example.com/pulp/python/web/${REPO_ID}/simple/ coreapi
  echo ""
  read -p "${BOLD}Done!${NORMAL}"
}

clean()
{
    deactivate
    cd ~
    rm -rf ~/tmp
    pulp-admin python repo delete --repo-id ${REPO_ID}
}

clear
demo_dependencies
dependencies
repo_create
upload
list
publish
install
clean
clear
