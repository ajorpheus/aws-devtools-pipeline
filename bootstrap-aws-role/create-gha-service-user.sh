#!/usr/bin/env bash
# bashsupport disable=BP2001

# shellcheck disable=SC2034
__script_init_vars() {
  readonly required_binaries_list="aws,jq,terraform"
  readonly required_env_args="GH_TOKEN"
  readonly tfplan_file_name="tfplan"
}

cleanup_local_terraform_files() {
  log_info "Cleaning terraform"
  if [ -d ".terraform" ]; then rm -rf .terraform; fi

  if compgen -G "./*.tfstate*" >/dev/null; then
    echo "pattern exists!"
  fi
}

terraform_apply_with_confirmation() {
  while true; do
    local input
    read -r -p "Are you sure you wish to apply the above plan? [y/n/yes/no] " input

    case $input in
    [yY][eE][sS] | [yY])
      log_info "Executing terraform apply"
      terraform apply -auto-approve "${tfplan_file_name}"
      break
      ;;
    [nN][oO] | [nN])
      log_info "Not executing terraform apply"
      break
      ;;
    *)
      log_simple "Invalid input. Try again!"
      ;;
    esac
  done
}

execute_terraform() {
  cd "$__dir" || exit
  log_info "Initialising state locally"
  export TF_VAR_github_token="$GH_TOKEN"
  terraform init -upgrade -get=true -input=false

  log_info "Executing Terraform plan and checking if changes need to be made: $(ls ./*.tf)"
  #Capture the exit code of plan and use that to conditionally execute apply
  {
    terraform plan -out=tfplan -detailed-exitcode -compact-warnings
    local terraform_plan_exit_code="$?"
  } || true

  case $terraform_plan_exit_code in
  0)
    highlight "terraform plan succeeded with empty diff (no changes). Nothing to do."
    ;;
  1)
    log_error "There was an error executing terraform plan"
    exit 1
    ;;
  2)
    highlight "terraform plan succeeded with non-empty diff (changes present). Changes needed."
    terraform_apply_with_confirmation
    ;;
  esac


  SECRET_ROLE="$(terraform output -json | jq -r '.iam_role_arn.value')"
  readonly SECRET_ROLE
  printf "SECRET_GITHUB_OIDC_ROLE_ARN=%s\n" "$SECRET_ROLE" > .env

  printf "AWS_REGION=%s\n" "$(terraform output -json | jq -r '.aws_region.value')" >> .env
  printf "GH_TOKEN=%s\n" "$GH_TOKEN" >> .env

  gh secret set -f .env

  export TF_VAR_deployment_role="$SECRET_ROLE"
  export TF_VAR_github_token="$GH_TOKEN"
}

__execute_script_core_logic() {
  execute_function "execute_terraform" "$@"
}

__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
readonly __dir

# shellcheck source=util_scripts/util_generic_bash_template.sh
source "${__dir}/util_scripts/util_generic_bash_template.sh" "$@"
