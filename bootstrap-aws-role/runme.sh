#!/usr/bin/env bash

__script_init_vars() {
  # shellcheck disable=SC2034
  readonly required_binaries_list="docker"
}

rebuild_docker_image_if_needed() {
  local image_id="aws_script_executor"
  local image_tag

  # The docker image will be rebuilt if executed after an hour.
  image_tag="$(date +'%Y-%m-%d_%H')"
  # Use seconds in the timestamp if modifying this script for a quicker 'refresh' of the image
  #image_tag="$(date +'%Y-%m-%d_%H-%M-%S')"

  IMAGE_ID_WITH_TAG="${image_id}:${image_tag}"
  readonly IMAGE_ID_WITH_TAG

  if docker inspect "${IMAGE_ID_WITH_TAG}" &>/dev/null; then
    # shellcheck disable=SC2154
    log_info_inline "${__base}: Reusing existing ${IMAGE_ID_WITH_TAG}"
  else
    log_info "${__base}: ${IMAGE_ID_WITH_TAG} does not exist! Building it now."
    docker build -t "${IMAGE_ID_WITH_TAG}" -f "${__dir}/Dockerfile" .
  fi
}

execute_docker_script() {
  cd "$__dir/.." || exit

  # shellcheck disable=SC2046
  docker run --rm -t $(tty &>/dev/null && echo "-i") \
    -e AWS_ACCESS_KEY_ID \
    -e AWS_SESSION_TOKEN \
    -e AWS_DEFAULT_REGION="eu-west-2" \
    -e AWS_SECRET_ACCESS_KEY \
    -e GH_TOKEN \
    -v "$(pwd):/project" \
    -w "/project" \
    "$IMAGE_ID_WITH_TAG" \
    bash "/project/bootstrap-aws-role/create-gha-service-user.sh" "$@"

  cd "$OLDPWD" || exit
}

__execute_script_core_logic() {
  rebuild_docker_image_if_needed
  execute_docker_script "$@"
}

__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
readonly __dir

# shellcheck source-path=SCRIPTDIR/util_scripts
source "${__dir}/util_scripts/util_generic_bash_template.sh" "$@"
