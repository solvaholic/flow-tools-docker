# https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/flow-tools/flow-tools-0.68.5.1.tar.bz2

# docker build --rm -t solvaholic/flow-tools .

# docker run --rm -d -v $(realpath .)/var-db-flows:/var/db/flows \
# -p 5678:5678/udp solvaholic/flow-tools

# docker run --rm -it -v $(realpath .)/var-db-flows:/var/db/flows \
# solvaholic/flow-tools /bin/ash

FROM alpine:3.9 AS build

# Update and install some tools.
RUN apk -U upgrade
RUN apk add curl build-base bison flex zlib-dev

# Build flow-tools.
WORKDIR /
COPY flow-tools-0.68.5.1.tar.bz2 ./
RUN tar xf flow-tools-0.68.5.1.tar.bz2
WORKDIR flow-tools-0.68.5.1
ADD https://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.guess;hb=HEAD config.guess
ADD https://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.sub;hb=HEAD config.sub
RUN ./configure
RUN make && make install


FROM alpine:3.9 AS run

# Update and install some tools.
RUN apk -U upgrade
RUN apk add zlib-dev

# Copy flow-tools from build.
COPY --from=build /usr/local/flow-tools /usr/local/flow-tools

# Set up the environment.
RUN mkdir -m 755 -p /var/db/flows
RUN touch /var/run/flow-capture.pid
ENV PATH="/usr/local/flow-tools/bin:${PATH}"

# Set entry point and expose port.
ENTRYPOINT [ "/bin/sh", "-c"]
EXPOSE 5678/udp
CMD ["/usr/local/flow-tools/bin/flow-capture", "-p/var/run/flow-capture.pid", "-n287", "-w/var/db/flows", "-S5", "-D" "0/0/5678"]
