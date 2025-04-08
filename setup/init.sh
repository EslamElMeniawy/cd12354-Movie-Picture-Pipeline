#!/bin/bash
set -e -o pipefail

echo "Fetching IAM github-action-user ARN"
userarn=$(aws iam get-user --user-name github-action-user | jq -r .User.Arn)

# Download tool for manipulating aws-auth
ARCH=$(uname -m)
OS=$(uname | tr '[:upper:]' '[:lower:]')

case $ARCH in
  x86_64) ARCH=amd64 ;;
  aarch64 | arm64) ARCH=arm64 ;;
  *) echo "Unsupported architecture: $ARCH" && exit 1 ;;
esac

FILENAME="aws-iam-authenticator_0.6.2_${OS}_${ARCH}"
URL="https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/v0.6.2/${FILENAME}"
echo "Downloading tool..."
curl -L "$URL" -o aws-iam-authenticator
chmod +x aws-iam-authenticator

echo "Updating permissions"
./aws-iam-authenticator add user --userarn="${userarn}" --username=github-action-role --groups=system:masters --kubeconfig="$HOME"/.kube/config --prompt=false

echo "Cleaning up"
rm aws-iam-authenticator
echo "Done!"