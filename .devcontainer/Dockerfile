ARG GO_VERSION=1.23
ARG DEBIAN_VERSION=bookworm

# Go development container

FROM golang:${GO_VERSION}-${DEBIAN_VERSION}
ARG INCUS_ADMIN_GID=956
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=1000

# Install necessary tools.
RUN <<EOR
echo 'deb [trusted=yes] https://repo.goreleaser.com/apt/ /' | tee /etc/apt/sources.list.d/goreleaser.list
mkdir -p /etc/apt/keyrings/
curl -fsSL https://pkgs.zabbly.com/key.asc -o /etc/apt/keyrings/zabbly.asc
cat <<EOF > /etc/apt/sources.list.d/zabbly-incus-stable.sources
Enabled: yes
Types: deb
URIs: https://pkgs.zabbly.com/incus/stable
Suites: $(. /etc/os-release && echo ${VERSION_CODENAME})
Components: main
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/zabbly.asc

EOF
apt update
apt full-upgrade -y
apt install -y locales locales-all vim sudo man less goreleaser jq fish zsh direnv incus-client binutils debian-archive-keyring devscripts make parted pipx qemu-utils dbus-daemon
mkdir -p /run/dbus
EOR

# Add vscode user and add it to sudoers and incus-admin.
RUN <<EOR
groupadd -g $INCUS_ADMIN_GID incus-admin
groupadd -g 1000 $USERNAME
useradd -s /bin/bash -u $USER_UID -g $USER_GID -G incus-admin -m $USERNAME
mkdir -p /etc/sudoers.d
echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME
chmod 0440 /etc/sudoers.d/$USERNAME
EOR

# Setup for vscode user.
USER $USERNAME
ENV EDITOR=vi \
    LANG=en_US.UTF-8
# Build Go tools with user vscode to ensure correct file and directory permissions for the build artifacts.
RUN <<EOR
go install -v github.com/google/go-licenses@latest
go install -v github.com/766b/go-outliner@latest
GOTOOLCHAIN="" go install -v golang.org/x/tools/gopls@latest
go install -v github.com/go-delve/delve/cmd/dlv@latest
go install -v golang.org/x/tools/cmd/goimports@latest
go install -v golang.org/x/vuln/cmd/govulncheck@latest
curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $(go env GOPATH)/bin
pipx install git+https://github.com/systemd/mkosi.git@v25.3
EOR

USER root

# Since we use a volume for /go to persist the content between executions, we need to preserve the binaries.
RUN <<EOR
mv /go/bin/* /usr/local/bin
ln -s /home/vscode/.local/bin/mkosi* /usr/local/bin
EOR
