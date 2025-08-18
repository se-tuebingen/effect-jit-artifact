FROM nixos/nix

RUN nix-channel --update

ADD --link . /artifact

WORKDIR /artifact
RUN git submodule update --init
RUN nix-shell --command "./run setup"

ENTRYPOINT ['bash']