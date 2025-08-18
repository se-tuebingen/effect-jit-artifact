FROM nixos/nix

RUN nix-channel --update

ADD --link . /artifact

WORKDIR /artifact
RUN git submodule update --init

ENTRYPOINT ["bash", "-i"]