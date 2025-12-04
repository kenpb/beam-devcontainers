ARG VARIANT="bullseye"
ARG USERNAME="vscode"
ARG ERLANG_VERSION="27"
ARG ELIXIR_VERSION="1_18"

FROM mcr.microsoft.com/vscode/devcontainers/base:${VARIANT} AS erlang-only

ARG USERNAME
ARG ERLANG_VERSION
ENV PATH=$PATH:/home/${USERNAME}/.nix-profile/bin
ENV LANG=C.UTF-8

RUN apt-get update \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get install -y curl xz-utils inotify-tools \
    && su ${USERNAME} -c "curl -L https://nixos.org/nix/install | sh -s -- --no-daemon" \
    && su ${USERNAME} -c ". /home/${USERNAME}/.nix-profile/etc/profile.d/nix.sh \
       && nix-env -f '<nixpkgs>' -iA beam${ERLANG_VERSION}Packages.erlang \
          beam${ERLANG_VERSION}Packages.rebar3 \
          beam${ERLANG_VERSION}Packages.rebar" \
    && apt-get remove -y curl xz-utils \
    && apt-get autoremove -y \
    && apt-get clean -y \
    && su ${USERNAME} -c ". /home/${USERNAME}/.nix-profile/etc/profile.d/nix.sh \
       && nix-collect-garbage" \
    && rm -rf /var/lib/apt/lists/* /home/${USERNAME}/.cache/nix/*

FROM erlang-only AS erlang-elixir

ARG USERNAME
ARG ERLANG_VERSION
ARG ELIXIR_VERSION
ENV PATH=$PATH:/home/${USERNAME}/.nix-profile/bin
ENV LANG=C.UTF-8

RUN su ${USERNAME} -c ". /home/${USERNAME}/.nix-profile/etc/profile.d/nix.sh \
       && nix-env -f '<nixpkgs>' -iA beam${ERLANG_VERSION}Packages.elixir_${ELIXIR_VERSION} \
       && mix local.hex --force \
       && mix local.rebar --force"
