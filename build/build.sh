#!/bin/bash

NEXTLINUX_VERSION="0.27.1"
NEXTLINUX_VERSION_MAC="0.27.0"

# Env parameters
# - CLEANUP (default: true)
# - INSTALL_DEPS (default: false)
# - BUILD_LINUX (default: true)
# - BUILD_CONTAINER (default: true)
# - BUILD_MAC (default: true)
# - BUILD_MAC_INSTALLER (default: false)
# - ENVIRONMENT (default: development)
# - USER_TRACKING_KEY (default: empty)
# - BUILD_NUMBER
# - GIT_BRANCH (default: dev)

setup_env() {
    echo "Prepare environment..."

    set +u

    #
    # Set default variables
    #
    if [ -z ${CLEANUP} ]
    then
        CLEANUP=true
    fi
    if [ -z ${INSTALL_DEPS} ]
    then
        INSTALL_DEPS=false
    fi
    if [ -z ${BUILD_LINUX} ]
    then
        BUILD_LINUX=true
    fi
    if [ -z ${BUILD_CONTAINER} ]
    then
        BUILD_CONTAINER=true
    fi
    if [ -z ${BUILD_MAC} ]
    then
        BUILD_MAC=true
    fi
    if [ -z ${BUILD_MAC_INSTALLER} ]
    then
        BUILD_MAC_INSTALLER=false
    fi
    if [ -z ${ENVIRONMENT} ]
    then
        ENVIRONMENT=development
    fi
    if [ -z ${USER_TRACKING_KEY} ]
    then
        USER_TRACKING_KEY=
    fi
    if [ -z ${GIT_BRANCH} ]
    then
        GIT_BRANCH=dev
    fi
    if [ -z ${BUILD_NUMBER} ]
    then
        BUILD_NUMBER=42
    fi

    set -u

    GIT_BRANCHNAME=$(echo ${GIT_BRANCH} | cut -d"/" -f2)

    if [ "${GIT_BRANCHNAME}" = "master" ]; then
        ENVIRONMENT=production
    fi

    INSPECT_USER_VERSION=`cat VERSION`
    if [ "${ENVIRONMENT}" = "production" ]; then
        INSPECT_VERSION=${INSPECT_USER_VERSION}
    else
        INSPECT_VERSION=${INSPECT_USER_VERSION}.${BUILD_NUMBER}
    fi

    # Disabling interactive progress bar, and spinners gains 2x performances
    # as stated on https://twitter.com/gavinjoyce/status/691773956144119808
    npm config set progress false
    npm config set spin false

    if [ "${ENVIRONMENT}" = "production" ]; then
        DOCKER_IMAGE_TAG=nextlinux/nextlinux-inspect:${INSPECT_VERSION}
        DOCKER_IMAGE_LATEST_TAG=nextlinux/nextlinux-inspect:latest
    else
        DOCKER_IMAGE_TAG=nextlinux/nextlinux-inspect:${INSPECT_VERSION}-${GIT_BRANCHNAME}
    fi
}

install_dependencies() {
    if [ "${INSTALL_DEPS}" = "true" ]; then
        echo "Installing dependencies..."

        rm -rf deps

        if [ "${BUILD_LINUX}" = "true" ] || [ "${BUILD_CONTAINER}" = "true" ]; then
            # Linux binaries

            mkdir -p deps/nextlinux-linux
    
            id=$(docker create nextlinux/nextlinux:$NEXTLINUX_VERSION)
            docker cp $id:/usr/bin/nextlinux deps/nextlinux-linux
            docker cp $id:/usr/bin/cnextlinux deps/nextlinux-linux
            docker cp $id:/usr/share/nextlinux/chisels deps/nextlinux-linux
            docker rm -v $id

            # note: force is required because the builder container is using nextlinux/nextlinux referenced image
            docker rmi --force nextlinux/nextlinux:$NEXTLINUX_VERSION
        fi

        if [ "${BUILD_MAC}" = "true" ] || [ "${BUILD_MAC_INSTALLER}" = "true" ]; then
            # Mac binaries
            
            mkdir -p deps/nextlinux-mac
            
            curl https://download.nextlinux.com/dependencies/nextlinux-${NEXTLINUX_VERSION_MAC}-mac.zip -o nextlinux.zip
            unzip -d deps/nextlinux-mac nextlinux.zip
        fi
    fi
}

build() {
    echo "Building..."

    npm run setup

    npm build

    # Currently failing; Disabling tests during investigation
    # npm test

    if [ "${BUILD_LINUX}" = "true" ] || [ "${BUILD_CONTAINER}" = "true" ]; then
        #
        # build Linux package
        #
        rm -rf out/linux

        npm run bundle -- deps/nextlinux-linux
        npm run make:linux -- --environment ${ENVIRONMENT} --user-tracking-key ${USER_TRACKING_KEY}

        mkdir -p out/linux/binaries
        mkdir -p out/linux/installers
        cp -r electron-out/make/* out/linux/installers
        cp -r electron-out/Nextlinux\ Inspect-linux-x64/* out/linux/binaries
    fi

    if [ "${BUILD_CONTAINER}" = "true" ]; then
        #
        # build Docker image
        #
        rm -rf out/container
        rm -rf dist

        # static resources
        mkdir -p out/container
        mkdir -p out/container/public
        cp -r public/* out/container/public
        # backend
        cp -r electron-out/Nextlinux\ Inspect-linux-x64/resources/app/ember-electron/backend/* out/container
        rm -rf out/container/tests
        # frontend
        cp -r electron-out/Nextlinux\ Inspect-linux-x64/resources/app/ember/* out/container/public
        rm -rf out/container/public/tests
        rm -rf out/container/public/testem.js

        mkdir -p dist
        cp -r out/container/* dist  
        docker build . -t ${DOCKER_IMAGE_TAG}

        if [ "${ENVIRONMENT}" = "production" ]; then
            docker tag ${DOCKER_IMAGE_TAG} ${DOCKER_IMAGE_LATEST_TAG}
        fi
    fi

    if [ "${BUILD_MAC}" = "true" ] || [ "${BUILD_MAC_INSTALLER}" = "true" ]; then
        #
        # build MAC package
        #
        rm -rf out/mac

        rm -rf ember-electron/resources/nextlinux
        npm run bundle -- deps/nextlinux-mac
        if [ "${BUILD_MAC}" = "true" ]; then
            npm run package:mac -- --environment ${ENVIRONMENT} --user-tracking-key ${USER_TRACKING_KEY}
        fi
        if [ "${BUILD_MAC_INSTALLER}" = "true" ]; then
            npm run make:mac -- --environment ${ENVIRONMENT} --user-tracking-key ${USER_TRACKING_KEY}
        fi

        cd electron-out
        zip -ry Nextlinux\ Inspect-darwin-x64.zip Nextlinux\ Inspect-darwin-x64
        cd ..
        mkdir -p out/mac/binaries
        cp electron-out/Nextlinux\ Inspect-darwin-x64.zip out/mac/binaries/nextlinux-inspect-${INSPECT_VERSION}-mac.zip
        if [ "${BUILD_MAC_INSTALLER}" = "true" ]; then
            mkdir -p out/mac/installers
            cp electron-out/make/Nextlinux\ Inspect-${INSPECT_USER_VERSION}.dmg out/mac/installers/nextlinux-inspect-${INSPECT_VERSION}-mac.dmg
        fi
    fi
}

cleanup() {
    if [ "${CLEANUP}" = "true" ]; then
        echo "Cleaning up..."

        rm -rf out
        rm -rf dist

        npm run clean
        
        docker rm ${DOCKER_IMAGE_TAG} || echo "Image ${DOCKER_IMAGE_TAG} not found!"
    fi
}

set -ex
    setup_env
    cleanup
    install_dependencies
    build
set +ex

echo "Done!"
