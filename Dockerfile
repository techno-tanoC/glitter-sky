FROM fpco/stack-build:lts-11.17
WORKDIR /usr/lib/gcc/x86_64-linux-gnu/5.4.0
RUN cp crtbeginT.o crtbeginT.o.orig
RUN cp crtbeginS.o crtbeginT.o

WORKDIR /work

ADD stack.yaml .
RUN stack setup

ADD package.yaml .
ADD glitter-sky.cabal .
RUN stack --system-ghc --local-bin-path /sbin build --ghc-options '-optl-static -fPIC -optc-Os' || exit 0

ADD . .
RUN stack --system-ghc --local-bin-path /sbin build --ghc-options '-optl-static -fPIC -optc-Os'

FROM ubuntu:18.04
RUN apt update && apt install -y netbase ca-certificates
COPY --from=0 /work/.stack-work/install/x86_64-linux/lts-11.17/8.2.2/bin/glitter-sky /sbin/
CMD ["/sbin/glitter-sky"]
