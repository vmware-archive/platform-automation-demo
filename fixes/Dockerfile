FROM golang as builder
RUN mkdir -p $GOPATH/src/code.cloudfoundry.org && mkdir -p /assets
RUN cd $GOPATH/src/code.cloudfoundry.org && git clone https://github.com/calebwashburn/credhub-cli.git
RUN cd $GOPATH/src/code.cloudfoundry.org/credhub-cli && go build -o /assets/credhub

FROM platform-automation:latest

WORKDIR tmp
COPY --from=builder assets/credhub credhub
RUN chmod +x credhub && mv credhub /usr/bin/credhub
WORKDIR /
