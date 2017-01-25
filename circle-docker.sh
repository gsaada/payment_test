#!/usr/bin/env bash

set -o errexit

DOCKER_STEP=$1
DOCKER_IMAGE=$2

do_env(){
  # Docker environment
  docker version
  docker info
}

do_slack(){
  do_check SLACK_WEBHOOK

  local BOTNAME=circle-docker
  local CHANNEL=${SLACK_CHANNEL:-"#test"}
  local URL=${SLACK_WEBHOOK}
  local MESSAGE=$1

  curl --connect-timeout 3 --max-time 5 -X POST --data-urlencode "payload={\"channel\": \"${CHANNEL}\", \"username\": \"${BOTNAME}\", \"text\": \"${MESSAGE}\"}" ${URL}
}

do_debug(){
  echo "[$(date +"%T")] $1"
}

do_info(){
  do_debug "$1"
  if [ ! -z "${SLACK_WEBHOOK}" ] ; then
    do_slack "$1"
  fi
}

do_error(){
  # Print an error message
  do_debug "$1"
  exit 1
}

do_check(){
  # Check whether a particular variable has been set
  # (this is why we don't set -o nounset)
  if [ -z ${!1} ] ; then
    do_error "$1 must be set."
  fi
}

do_build(){
  # Build Docker image with Docker tag as CircleCI build number
  do_check DOCKER_IMAGE
  do_info "Building ${DOCKER_IMAGE}"

  docker build -rm=false -t ${DOCKER_IMAGE}:${CIRCLE_SHA1} .
}

do_run(){
  #run and check the docker
  do_check DOCKER_IMAGE
  do_debug "Running ${DOCKER_IMAGE}:${CIRCLE_SHA1}"
  docker run -d ${DOCKER_IMAGE}:${CIRCLE_SHA1}
}

do_push(){
  # Tag and push an image for this build, and create a latest tag
  do_check DOCKER_IMAGE
  do_debug "Pushing and tagging ${DOCKER_IMAGE}"

  # Push to Docker registry
  local NUMBERED_BUILD=${DOCKER_IMAGE}:${CIRCLE_SHA1}
  do_info "Pushing ${NUMBERED_BUILD}"
  docker push ${NUMBER_BUILD}

  # Push a 'latest' tag to the registry
  local LATEST_BUILD=${DOCKER_IMAGE}:latest
  do_info "Pushing ${LATEST_BUILD}"
  docker push ${LATEST_BUILD}

  do_info "${DOCKER_IMAGE} has been pushed and tagged as ${NUMBERED_BUILD}"
}

do_login(){
  do_check ROLLOUT_DOCKER_USR
  do_check ROLLOUT_DOCKER_PASS
  do_check ROLLOUT_DOCKER_MAIL

  docker login -u ${ROLLOUT_DOCKER_USR} -p ${ROLLOUT_DOCKER_PASS} -e ${ROLLOUT_DOCKER_MAIL}
}

do_help(){
  cat <<- EndHelp
circle-docker - helper for pushing Docker images from CircleCI

Commands:

build <image name>           Build an image.
run   <image name>	     Run the image.
push  <image name>           Push a build to the docker hub.

This tool expects the following enviroment variables (in addition to Circle's built in ones):
- ROLLOUT_DOCKER_USR
- ROLLOUT_DOCKER_PASS
- ROLLOUT_DOCKER_MAIL
EndHelp
}

# Run
case ${DOCKER_STEP} in
  build)
    do_login
    do_build
    ;;
  run)
    do_run
    ;;
  push)
    do_config
    do_push
    ;;
  env)
    do_env
    ;;
  *)
  do_help
  exit 1
    ;;
esac
