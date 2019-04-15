# https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/flow-tools/flow-tools-0.68.5.1.tar.bz2

# docker build --rm -t solvaholic/flow-tools .

# docker run --rm -d -v $(realpath .)/var-db-flows:/var/db/flows \
# -p 5678:5678/udp -e KEY=VALUE solvaholic/flow-tools

# docker run --rm -it -v $(realpath .)/var-db-flows:/var/db/flows \
# -e KEY=VALUE --entrypoint /bin/sh solvaholic/flow-tools

FROM alpine:3.9

# Update and install some tools.
RUN apk -U upgrade
RUN apk add curl build-base bison flex zlib-dev

# Build flow-tools.
WORKDIR /
COPY flow-tools-0.68.5.1.tar.bz2 ./
RUN tar xf flow-tools-0.68.5.1.tar.bz2
WORKDIR flow-tools-0.68.5.1
RUN ./configure
RUN make && make install

# Set up the environment.
RUN mkdir -m 755 -p /var/db/flows
RUN touch /var/run/flow-capture.pid
ENV PATH="/usr/local/flow-tools/bin:${PATH}"

# Clean up.
RUN make clean
WORKDIR ..
RUN rm -rf flow-tools-0.68.5.1
RUN apk del build-base bison flex curl

# Set entry point and expose port.
ENTRYPOINT ["/usr/local/flow-tools/bin/flow-capture", "-p/var/run/flow-capture.pid", "-n287", "-w/var/db/flows", "-S5", "-D"]
EXPOSE 5678/udp
CMD ["0/0/5678"]
