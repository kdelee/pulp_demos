BOLD=$(tput bold; tput setaf 1)
NORMAL=$(tput sgr0)
GIT_URL=https://github.com/core-api/python-client
REPO_ID=rattlesnake

demo_dependencies()
{
  echo "${BOLD} Setting up ... "
  pip install --upgrade pip > /dev/null
  pip install virtualenv > /dev/null
  mkdir -p ~/tmp
  cd ~/tmp
  python -m virtualenv env > /dev/null
  source ~/tmp/env/bin/activate > /dev/null
  pip install requests coreschema itypes uritemplate > /dev/null
}

dependencies()
{
  clear
  echo ""
  echo "${BOLD} Check that pulp python plugin is installed ${NORMAL}"
  echo ""
  read -p ":"
  echo ""
  echo "$ rpm -qa | grep pulp-python"
  rpm -qa | grep pulp-python
  echo ""
  read -p ":"
}

repo_create()
{
  clear
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
  read -p ":"
}

upload()
{
  clear
  echo ""
  echo "Pulp accepts source distributions and wheels, which are uploaded"
  echo "in the same way. Let’s clone the pulp_python plugins package and build a"
  echo "source package suitable for uploading to Pulp"
  echo ""
  echo "${BOLD}mkdir -p ~/tmp && cd ~/tmp && git clone ${GIT_URL}" \
      "&& cd python-client${NORMAL}"
  mkdir -p ~/tmp && cd ~/tmp && git clone ${GIT_URL} && cd python-client
  read -p ":"
  clear
  echo "${BOLD}Run setup.py to create tarball for upload to pulp${NORMAL}"
  echo ""
  echo "${BOLD}$ ./setup.py sdist.${NORMAL}"
  read -p ":"
  echo ""
  ./setup.py sdist
  read -p ":"
  clear
  echo ""
  read -p "${BOLD}The tar ball should now be in the dist directory:${NORMAL}"
  echo ""
  echo "${BOLD}$ ls dist${NORMAL}"
  ls dist
  echo ""
  echo "${BOLD}Upload the tarball into our repo${NORMAL}"
  echo ""
  echo "${BOLD}pulp-admin python repo upload --repo-id ${REPO_ID} -f $(ls dist/*)${NORMAL}"
  read -p ":"
  echo ""
  pulp-admin python repo upload --repo-id ${REPO_ID} -f $(ls dist/*)
  read -p ":"
}

list()
{
  clear
  echo ""
  echo "${BOLD}List content in the repository.${NORMAL}"
  read -p ":"
  echo ""
  echo "${BOLD} pulp-admin python repo packages --repo-id ${REPO_ID} --match name=coreapi ${NORMAL}"
  pulp-admin python repo packages --repo-id ${REPO_ID} --match name=coreapi
  echo ""
  read -p ":"
}

publish()
{
  clear
  echo ""
  echo "${BOLD}Publish the repository so others can access the package.${NORMAL}"
  read -p ":"
  echo ""
  echo "${BOLD} $ pulp-admin python repo publish run --repo-id ${REPO_ID} ${NORMAL}"
  pulp-admin python repo publish run --repo-id ${REPO_ID}
  read -p ":"
}

install()
{
  clear
  echo ""
  echo "${BOLD}Install the package that is hosted on the pulp server${NORMAL}"
  read -p ":"
  echo ""
  echo "${BOLD} $ pip install -i http://pulp.example.com/pulp/python/web/${REPO_ID}/simple/ coreapi"
  pip install -i http://localhost:5000/pulp/python/web/${REPO_ID}/simple/ coreapi
  echo ""
  read -p "${BOLD}Done!${NORMAL}"
  echo ""
}

clean()
{
    clear
    echo "${BOLD} Cleaning up ...${NORMAL}"
    deactivate
    cd ~
    rm -rf ~/tmp
    pulp-admin python repo delete --repo-id ${REPO_ID}
    pulp-admin orphan remove --all
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
