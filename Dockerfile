FROM nixos/nix

RUN nix-channel --update

ADD --link . /artifact

WORKDIR /artifact

ENTRYPOINT ["bash", "-i"]