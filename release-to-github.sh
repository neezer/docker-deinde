#!/bin/sh

set -o errexit

if [[ ! "$(deinde)" ]]; then
  exit 0
fi

if [[ ! "${GIT_AUTHOR_NAME}" ]]; then
  echo "Must provide a GIT_AUTHOR_NAME!"
  exit 1
fi

if [[ ! "${GIT_AUTHOR_EMAIL}" ]]; then
  echo "Must provide a GIT_AUTHOR_EMAIL!"
  exit 1
fi

if [[ ! "${GITHUB_ACCESS_TOKEN}" ]]; then
  echo "Must provide a GITHUB_ACCESS_TOKEN!"
  exit 1
fi

if [[ ! "${GITHUB_REPO}" ]]; then
  echo "Must provide a GITHUB_REPO!"
  exit 1
fi

DRAFT="${DRAFT:="false"}"
PRERELEASE="${PRERELEASE:="false"}"

git config user.name "${GIT_AUTHOR_NAME}"
git config user.email "${GIT_AUTHOR_EMAIL}"

version=$(deinde)

git tag -a "${version}"
git push --tags

json=$(printf '{ "tag_name": "%s", "target_commitish": "master", "name": "%s", "body": "[TODO add release notes here]", "draft": %s, "prerelease": %s }' $version $version $DRAFT $PRERELEASE)

curl \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Content-Type: application/json" \
  --data "${json}" \
  "https://api.github.com/repos/${GITHUB_REPO}/releases"

if [[ "${ARTIFACTS_DIR}" ]]; then
  for filename in "${ARTIFACTS_DIR}/*"; do
    curl \
      -H "Authorization: token $GITHUB_TOKEN" \
      --data-binary @"${filename}" \
      "https://uploads.github.com/repos/${GITHUB_REPO}/releases/tag/${version}/assets"
  done
fi
