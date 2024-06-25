#!/bin/bash

# Required env variables:
# CI_COMMIT_BRANCH - Git branch name
# CI_COMMIT_TAG - Git tag

if [[ -z "$CI_COMMIT_BRANCH" ]]
then
  app_build_git_branch=$(git rev-parse --abbrev-ref HEAD)
else
  app_build_git_branch="$CI_COMMIT_BRANCH"
fi

if [[ -z "$CI_COMMIT_TAG" ]]
then
  app_build_git_tag=$(git describe --tags --abbrev=0)
else
  app_build_git_tag="$CI_COMMIT_TAG"
fi

app_version_name_from_tag="$app_build_git_tag"
app_version_name_from_tag=${app_version_name_from_tag#"stage/"}
app_version_name_from_tag=${app_version_name_from_tag#"prod/"}

# Remove version suffix to allow for new builds with the same version name
app_version_name_from_tag="$(echo -ne "$app_version_name_from_tag" | sed -e "s/+.*$//")"

if
[[ $app_build_git_branch == develop ]] ||
[[ $app_build_git_branch == feature/* ]] ||
[[ $app_build_git_branch == hotfix/* ]] ||
[[ $app_build_git_branch == fix/* ]] ||
[[ $app_build_git_branch =~ SM-* ]]
then
  #
  # Version name for feature branches is formed by appending the
  # task number to the latest tag version.
  #
  # Version name for develop branch is formed by appending the
  # "-develop" suffix to the latest tag version.
  #

  # converts "feature/MB-2000" into "MB-2000"
  git_branch_suffix=$(echo -ne "$app_build_git_branch" | sed 's/.*[/]//')
  # replace all special characters with '-'
  app_version_name_suffix=$(echo "$git_branch_suffix" | tr "\'\"\` _|;:<>?\/[]{}!@#$%^&*()=+" "-")
  # echo "<version name>-<task number>"
  echo -ne "$app_version_name_from_tag-$app_version_name_suffix"
else
  #
  # Version name for any other branch (including "master" and "release/*" branches) is formed using
  # only the version from the latest git tag in that branch excluding the flavor prefix.
  #
  echo -ne "$app_version_name_from_tag"
fi
