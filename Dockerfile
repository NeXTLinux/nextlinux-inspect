FROM nextlinux/nextlinux:0.27.1



###############################################################################
#                                                                             #
# Install basic tools/utilities                                               #
#                                                                             #
###############################################################################

#
# Install Node.js v10
#
ENV NVM_DIR /usr/local/nvm
ENV NODE_VERSION 10.5.0
ENV NVM_VERSION 0.31.2

RUN curl -s -o- https://raw.githubusercontent.com/creationix/nvm/v$NVM_VERSION/install.sh | bash

RUN /bin/bash -c "source $NVM_DIR/nvm.sh && \
    nvm install $NODE_VERSION && \
    nvm alias default $NODE_VERSION && \
    nvm use default"

ENV NODE_PATH $NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

#
# Cleanup
#
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*



###############################################################################
#                                                                             #
# Prepare environment                                                         #
#                                                                             #
###############################################################################

ENV NODE_ENV production
ENV NEXTLINUX_SERVER_PORT 3000
ENV NEXTLINUX_PATH /usr/bin
ENV NEXTLINUX_SERVER_HOSTNAME 0.0.0.0

#
# Add binaries
#
ADD dist /usr/bin/nextlinux-inspect
WORKDIR /usr/bin/nextlinux-inspect

#
# Configure health check
#
HEALTHCHECK --interval=1m --timeout=20s \
  CMD curl -f http://localhost:3000/health || exit 1

#
# Expose Nextlinux Inspect UI endpoint
#
EXPOSE 3000



###############################################################################
#                                                                             #
# Start Nextlinux Inspect                                                        #
#                                                                             #
###############################################################################

CMD ["npx", "forever", "main.js"]
