#!/bin/sh

# exit script, if error
set -e

# define colors
RED=`tput setaf 1`
GREEN=`tput setaf 2`
NOCOLOR=`tput sgr0`

BOOTSTRAP_FILE="bootstrap.sh"
BOOTSTRAP_SOURCE="https://raw.githubusercontent.com/num42/n42-ios-bootstrap-shell/master/${BOOTSTRAP_FILE}"

echo "${GREEN}Running N42 Bootstrap v1.15 (2017-03-27)${NOCOLOR}"
echo "${GREEN}If the script fails, there might be a newer Version on $BOOTSTRAP_SOURCE ${NOCOLOR}"
echo "${GREEN}You can directly download it with 'curl -L $BOOTSTRAP_SOURCE -o ${BOOTSTRAP_FILE}' ${NOCOLOR}"
echo "${GREEN}You can update the script by running "sh ${BOOTSTRAP_FILE} -u"' ${NOCOLOR}"


if [[ $1 == "-u" ]] ; then
  echo ""
  echo  "${GREEN} Updating ${BOOTSTRAP_FILE} ${NOCOLOR}";
  curl -L $BOOTSTRAP_SOURCE?$(date +%s) -o $0
  exit 1
fi

# Guard to update brew only once and only if necessary
NEEDS_TO_UPDATE_BREW=1

installDependencyWithBrew(){
  if [ $NEEDS_TO_UPDATE_BREW -eq 1 ]; then
    echo ""
    echo  "${GREEN} UPDATING BREW ${NOCOLOR}";

    # update brew to keep dependencies up to date
    brew update || echo "${RED} FAILED TO UPDATE BREW ${NOCOLOR}";
    NEEDS_TO_UPDATE_BREW=0
  fi

  echo ""
  echo  "${GREEN} INSTALLING $1 WITH BREW ${NOCOLOR}";

  # install dependency, if is not installed
  brew list $1 || brew install $1 || echo "${RED} FAILED TO INSTALL $1 ${NOCOLOR}";

  # upgrade dependency, if it is outdated
  brew outdated $1 || brew upgrade $1 || echo "${RED} FAILED TO UPGRADE $1 ${NOCOLOR}";
}

installYarn(){
  echo ""
  echo "${GREEN} INSTALLING YARN ${NOCOLOR}"
  echo 'If you have trouble with yarn, add this to your ~/.bashrc | ~/.zshrc'
  echo 'export PATH="$HOME/.yarn/bin:$PATH"'

  (curl -o- -L https://yarnpkg.com/install.sh | bash ) || echo "${RED} FAILED TO INSTALL YARN ${NOCOLOR}"
}

if [ -e ".ruby-version" ]; then
  echo ""
  echo  "${GREEN} SETTING UP RUBY ${NOCOLOR}";

  installDependencyWithBrew rbenv
  installDependencyWithBrew ruby-build
  # install ruby version from .ruby-version, skipping if already installed (-s)
  rbenv install -s
fi

if [ -e "Gemfile" ]; then
  echo ""
  echo  "${GREEN} INSTALLING GEMS ${NOCOLOR}";

  # install bundler gem for ruby dependency management
  gem install bundler || echo "${RED} FAILED TO INSTALL BUNDLER ${NOCOLOR}";
  bundle install || echo "${RED} FAILED TO INSTALL BUNDLE ${NOCOLOR}";
fi

if [ -e "package.json" ]; then
  echo ""
  echo  "${GREEN} INSTALLING node-modules ${NOCOLOR}";

  which yarn || installYarn
  yarn install || echo "${RED} FAILED TO INSTALL NODE-MODULES ${NOCOLOR}";
fi

if [ -e "podfile" ]; then
  echo ""
  echo  "${GREEN} RUNNING COCOAPODS ${NOCOLOR}";

  # install cocoapods dependencies
  bundle exec pod repo update
  bundle exec pod install || echo "${RED} FAILED TO INSTALL PODS ${NOCOLOR}";
fi

if [ -e "Cartfile" ]; then
  echo ""
  echo  "${GREEN} INSTALLING CARTHAGE ${NOCOLOR}";

  installDependencyWithBrew carthage
fi

if [ -e ".gitmodules" ]; then
  echo ""
  echo  "${GREEN} SETTING UP GITMODULES ${NOCOLOR}";

  # keep submodules up to date, see https://git-scm.com/book/en/v2/Git-Tools-Submodules
  git submodule init || echo "${RED} FAILED TO INIT SUBMODULES ${NOCOLOR}";
  git submodule update || echo "${RED} FAILED TO UPDATE SUBMODULES ${NOCOLOR}";
fi

if [ -e "fastlane/Fastfile" ]; then
  if bundle exec fastlane lanes | grep "match_all"; then
    echo ""
    echo  "${GREEN} SYNCING CERTIFICATES AND PROFILES ${NOCOLOR}";
    # Run fastlane to ensure certs and profiles are installed
    bundle exec fastlane ios match_all || echo "${RED} FAILED TO RUN MATCH ${NOCOLOR}";
  fi
fi

if [ -e "bootstrap-specialized.sh" ]; then
  echo ""
  echo  "${GREEN} RUNNING SPECIALIZED BOOTSTRAP SCRIPT  ${NOCOLOR}";

  source bootstrap-specialized.sh
fi


for file in $(find ./*/ -name "bootstrap.sh" -maxdepth 1); do
  cd $(dirname $file)
  source "bootstrap.sh"
  cd ..
done
