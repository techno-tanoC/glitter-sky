FROM ubuntu:18.04

RUN apt update && apt upgrade -y && apt install -y curl
RUN curl -sSL https://get.haskellstack.org/ | sh

WORKDIR /work

ADD stack.yaml .
RUN stack setup

ADD package.yaml .
ADD glitter-sky.cabal .
RUN stack build || exit 0

ADD . .
RUN stack --system-ghc --local-bin-path /sbin build --ghc-options '-optl-static -fPIC -optc-Os'

FROM ubuntu:18.04
RUN apt update && apt install -y netbase ca-certificates
COPY --from=0 /work/.stack-work/install/x86_64-linux/lts-12.1/8.4.3/bin/glitter-sky /sbin/
CMD ["/sbin/glitter-sky"]
