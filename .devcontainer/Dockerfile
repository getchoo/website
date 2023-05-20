ARG VARIANT=18-bullseye
ARG NODE_VERSION=18.16.0
FROM mcr.microsoft.com/vscode/devcontainers/javascript-node:${VARIANT}

WORKDIR /home 

RUN su node -c "source /usr/local/share/nvm/nvm.sh && nvm install ${NODE_VERSION}"
RUN su node -c "npm install -g pnpm"
