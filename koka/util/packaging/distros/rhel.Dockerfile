FROM rockylinux/rockylinux:8.5

# The koka source should be mounted here readonly
# It will use overlays to build the bundle and then export it the output directory
# So /output should be mounted as readwrite
VOLUME /code
VOLUME /output 

ARG pkgman=dnf
# Install all the necessary packages
RUN ${pkgman} update -y
RUN ${pkgman} groupinstall -y "Development Tools"
RUN ${pkgman} install -y gmp-devel cmake

# Conan
RUN ${pkgman} install -y python3-pip
RUN pip3 install conan

# Easy hackage update trigger
ARG UPDATE_HACKAGE=1

# RHEL8 does not have cabal-install.
ADD ./rhel/*.sh /helpers/
RUN /helpers/install-ghc.sh
RUN cabal update

# Add and run the builder script specifying the postfix of the bundle
ADD ./builder.sh /builder.sh
RUN chmod +x /builder.sh

ENTRYPOINT [ "/builder.sh" ]

CMD [ "rhel", "cabal" ]