#!/bin/bash

# TODO:
#   - Add ability to upload build files to the public internet (plaidcloud-cdn?)
#   - Add ability to build and push root config image to Artifact Registry
#   - Add comments describing what this thing does
#   - Refactor? Error checking/handling?

function usage () {
    echo "Usage: ./build-web.sh <version-tag>"
    echo ""
    echo -e "<version-tag>\t\tThe tag used to indicate the build version, i.e. v5.3.1. This is used in CDN bucket and docker image build."
}

if [ -z "$1" ]; then
    echo -e "ERROR: <version-tag> must be specified.\n"
    usage
    exit 1
fi

CURRENT_DIR=$(pwd)

if [ "$CURRENT_DIR" == $(dirname $0) ]; then
    echo "build-web.sh must be executed with its directory, $(dirname $0)"
    exit 1
fi

MICRO_FRONT_ENDS_PATH="../forms-flow-ai-micro-front-ends"
MICRO_FRONT_ENDS=("forms-flow-admin" "forms-flow-nav" "forms-flow-service" "forms-flow-theme")
WEB_PATH="forms-flow-web"
WEB_ROOT_CONFIG_PATH="forms-flow-web-root-config"
VERSION_TAG=$1
OUT_DIR=$CURRENT_DIR/output/$VERSION_TAG


function build_micro_frontends () {
    # We're making a new 'output' dir in forms-flow-ai, and then navigating to forms-flow-ai-micro-front-ends to
    # iterate through each one and build it. The built JS files are then copied to the output dir we made. Everything
    # in the 'output' directory is what will be uploaded to the public internet so the forms-flow-web-root-config image
    # can reference them at runtime.
    cd $CURRENT_DIR/$MICRO_FRONT_ENDS_PATH
    for fe in "${MICRO_FRONT_ENDS[@]}"
    do
        cd $fe
        npm ci
        npm run build:webpack
        # NOTE: The files are given a `.gz.js` extension since the root image code expects it, despite the contents not being gzip'd.
        cp dist/$fe.js $OUT_DIR/$fe.gz.js
        cd ..
    done
}

function build_web () {
    # Same as build_micro_frontends(), but for the forms-flow-web project.
    cd $CURRENT_DIR/$WEB_PATH
    # git stash push package-lock.json
    npm ci
    npm run --only=production build
    cp -R build/static $OUT_DIR
    cp build/$WEB_PATH.js $OUT_DIR/$WEB_PATH.gz.js
    cd ..
}

function upload_to_cdn () {
    gcloud storage cp --recursive $OUT_DIR gs://plaidcloud-cdn/formsflow/$VERSION_TAG/
}

function build_root_image () {
    # This beefy docker build command was taken from the forms-flow-ai github action logs and parameterized for
    # our purposes. Note that the build args are specifying where to find the JS files from the previous steps,
    # and is thus baked in at build time. Changing the location of a JS file means the image must be rebuilt.
    mkdir -p /tmp/docker-actions-toolkit-$(git show --oneline -s | cut -d" " -f1) && docker buildx build \
    --build-arg MF_FORMSFLOW_WEB_URL=https://storage.googleapis.com/plaidcloud-cdn/formsflow/$VERSION_TAG/forms-flow-web.gz.js \
    --build-arg MF_FORMSFLOW_NAV_URL=https://storage.googleapis.com/plaidcloud-cdn/formsflow/$VERSION_TAG/forms-flow-nav.gz.js \
    --build-arg MF_FORMSFLOW_SERVICE_URL=https://storage.googleapis.com/plaidcloud-cdn/formsflow/$VERSION_TAG/forms-flow-service.gz.js \
    --build-arg MF_FORMSFLOW_ADMIN_URL=https://storage.googleapis.com/plaidcloud-cdn/formsflow/$VERSION_TAG/forms-flow-admin.gz.js \
    --build-arg MF_FORMSFLOW_THEME_URL=https://storage.googleapis.com/plaidcloud-cdn/formsflow/$VERSION_TAG/forms-flow-theme.gz.js \
    --iidfile /tmp/docker-actions-toolkit-$(git show --oneline -s | cut -d" " -f1)/iidfile \
    --label org.opencontainers.image.title=forms-flow-ai \
    --label org.opencontainers.image.description="formsflow.ai is an open source forms-workflow-analytics solution framework." \
    --label org.opencontainers.image.url=https://github.com/PlaidCloud/forms-flow-ai \
    --label org.opencontainers.image.source=https://github.com/PlaidCloud/forms-flow-ai \
    --label org.opencontainers.image.version=$VERSION_TAG \
    --label org.opencontainers.image.created=$(date +%FT%R:%S.%3NZ) \
    --label org.opencontainers.image.revision=$(git rev-parse HEAD) \
    --label org.opencontainers.image.licenses= \
    --platform linux/amd64 \
    --tag us-docker.pkg.dev/plaidcloud-build/us-plaidcloud/formsflow/forms-flow-web:$VERSION_TAG \
    --metadata-file /tmp/docker-actions-toolkit-$(git show --oneline -s | cut -d" " -f1)/metadata-file \
    --push forms-flow-web-root-config
}

mkdir -p $OUT_DIR

build_micro_frontends
build_web
#upload_to_cdn
build_root_image
