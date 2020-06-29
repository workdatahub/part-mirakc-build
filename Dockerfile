# mirakcのビルド
# mirakcコマンドを作り出して他のDckerfileの中で利用する
FROM workdatahub/alpine-build-env AS Mirakc-build

RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
ENV PATH $PATH:/root/.cargo/bin

RUN mkdir -p /build/mirakc
WORKDIR /build/mirakc
RUN curl -fsSL https://github.com/masnagam/mirakc/tarball/master | tar -zx --strip-components=1
RUN cargo build --release
RUN cp target/release/mirakc /usr/local/bin/

RUN mkdir -p /build/librarycopy
WORKDIR /build/librarycopy
COPY exliblist.sh exliblist.sh
COPY lcopy.sh lcopy.sh

RUN echo /usr/local/bin/mirakc >> binlist
RUN ./exliblist.sh binlist copylist

RUN echo /usr/local/bin/mirakc >> copylist
RUN ./lcopy.sh copylist /copydir

# dockerhubにビルドおまかせ、生成物のみ取り出す。
FROM scratch

COPY --from=Mirakc-build /copydir /copydir
