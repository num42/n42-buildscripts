#!/bin/sh

# exit script, if error
set -e

# define colors
RED=`tput setaf 1`
GREEN=`tput setaf 2`
NOCOLOR=`tput sgr0`

SCRIPT_FILE="bootstrap.sh"
SCRIPT_SOURCE="https://raw.githubusercontent.com/num42/n42-buildscripts/master/${SCRIPT_FILE}"

echo "${GREEN}Running N42 Bootstrap v2.01 (2020-10-19)${NOCOLOR}"
echo "${GREEN}If the script fails, there might be a newer Version on $SCRIPT_SOURCE ${NOCOLOR}"
echo "${GREEN}You can directly download it with 'curl -L $SCRIPT_SOURCE -o ${SCRIPT_FILE}' ${NOCOLOR}"
echo "${GREEN}You can update the script by running "sh ${SCRIPT_FILE} -u"' ${NOCOLOR}"


if [[ $1 == "-u" ]] ; then
  echo ""
  echo  "${GREEN} Updating ${SCRIPT_FILE} ${NOCOLOR}";
  curl -L $SCRIPT_SOURCE?$(date +%s) -o $0
  exit 1
fi

installYarn(){
  echo ""
  echo "${GREEN} INSTALLING YARN ${NOCOLOR}"
  echo 'If you have trouble with yarn, add this to your ~/.bashrc | ~/.zshrc'
  echo 'export PATH="$HOME/.yarn/bin:$PATH"'

  (curl -o- -L https://yarnpkg.com/install.sh | bash ) || echo "${RED} FAILED TO INSTALL YARN ${NOCOLOR}"
}

if [ \( -e ".env-sample" \) -a \( ! -e ".env" \) ]; then
  echo ""
  echo  "${GREEN} COPYING .env-sample TO .env ${NOCOLOR}";
  cp .env-sample .env
fi

if [ -e "Brewfile" ]; then
  echo ""
  echo  "${GREEN} INSTALLING BREW DEPENDENCIES ${NOCOLOR}";
  echo  "${GREEN} HINT: If any tools (e.g. n, rbenv, protobuf) are not found during bootstrap, adding them to the Brewfile might solve the issue.${NOCOLOR}";
  echo  "${GREEN} For an example Brewfile, see https://github.com/Homebrew/homebrew-bundle${NOCOLOR}";

  brew update
  brew bundle
fi

if [ -e ".ruby-version" ]; then
  echo ""
  echo  "${GREEN} SETTING UP RUBY ${NOCOLOR}";

  # install ruby version from .ruby-version, skipping if already installed (-s)
  rbenv install -s
fi

if [ -e "Gemfile" ]; then
  echo ""
  echo  "${GREEN} INSTALLING GEMS ${NOCOLOR}";

  # install bundler gem for ruby dependency management
  gem install bundler --no-document || echo "${RED} FAILED TO INSTALL BUNDLER ${NOCOLOR}";
  bundle install || echo "${RED} FAILED TO INSTALL BUNDLE ${NOCOLOR}";
fi


if [ -e ".node-version" ]; then
  echo ""
  echo  "${GREEN} SETTING UP NODE ${NOCOLOR}";

  # install node version from .node-version
  n auto
fi

if [ -e "package-lock.json" ]; then
  echo ""
  echo  "${GREEN} INSTALLING node-modules (NPM) ${NOCOLOR}";

  # we expect npm to be installed via node.
  npm install || echo "${RED} FAILED TO INSTALL NODE-MODULES (NPM) ${NOCOLOR}";
fi

if [ -e "yarn.lock" ]; then
  echo ""
  echo  "${GREEN} INSTALLING node-modules (YARN) ${NOCOLOR}";

  # we expect yarn to be installed via brew(file)
  yarn install || echo "${RED} FAILED TO INSTALL NODE-MODULES (YARN) ${NOCOLOR}";
fi

if [ -e "mix.exs" ]; then
  echo ""
  echo  "${GREEN} INSTALLING elixir(MIX) DEPENDENCIES ${NOCOLOR}";

  mix deps.get || echo "${RED} FAILED TO INSTALL ELIXIR(MIX) DEPENDENCIES ${NOCOLOR}";
fi

if [ -e ".gitmodules" ]; then
  echo ""
  echo  "${GREEN} SETTING UP GITMODULES ${NOCOLOR}";

  # keep submodules up to date, see https://git-scm.com/book/en/v2/Git-Tools-Submodules
  git submodule init || echo "${RED} FAILED TO INIT SUBMODULES ${NOCOLOR}";
  git submodule update || echo "${RED} FAILED TO UPDATE SUBMODULES ${NOCOLOR}";
fi

if [ -e "bootstrap-specialized.sh" ]; then
  echo ""
  echo  "${GREEN} RUNNING SPECIALIZED BOOTSTRAP SCRIPT  ${NOCOLOR}";

  source bootstrap-specialized.sh
fi
