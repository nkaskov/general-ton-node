FROM ubuntu:18.04 as builder
ARG core_count
ARG ton_repo
ARG ton_commit
ENV env_core_count=$core_count
RUN apt-get update && \
	apt-get install -y build-essential cmake clang-6.0 openssl libssl-dev zlib1g-dev gperf wget vim tar git curl chrony ca-certificates gnupg python python3 libmicrohttpd-dev && \
	rm -rf /var/lib/apt/lists/*

ENV CC clang-6.0
ENV CXX clang++-6.0
WORKDIR /
RUN git clone --recursive $ton_repo /ton
RUN cd /ton && git checkout $ton_commit
WORKDIR /ton

RUN mkdir build && \
        cd build && \
        cmake .. -DCMAKE_BUILD_TYPE=Release && \
        make -j $env_core_count


FROM ubuntu:18.04
RUN apt-get update && \
	apt-get install -y openssl wget python nano libmicrohttpd-dev mc && \
	rm -rf /var/lib/apt/lists/*
RUN mkdir -p /var/ton-work/db && \
	mkdir -p /var/ton-work/db/static

COPY --from=builder /ton/build/lite-client/lite-client /usr/local/bin/
#COPY --from=builder /ton/build/validator-engine/validator-engine /usr/local/bin/
COPY --from=builder /ton/build/validator-engine-console/validator-engine-console /usr/local/bin/
COPY --from=builder /ton/build/utils/generate-random-id /usr/local/bin/
COPY --from=builder /ton/build/blockchain-explorer/blockchain-explorer /usr/local/bin/
COPY --from=builder /ton/build/test-ton-collator /usr/local/bin
COPY --from=builder /ton/build/crypto/fift /usr/local/bin
COPY --from=builder /ton/build/crypto/func /usr/local/bin
RUN mkdir /usr/local/lib/fift
ENV FIFTPATH /usr/local/lib/fift
COPY --from=builder /ton/crypto/fift/lib /usr/local/lib/fift
RUN mkdir /var/ton-work/contracts
COPY --from=builder /ton/crypto/smartcont /var/ton-work/contracts
COPY --from=builder /ton/build/crypto/create-state /var/ton-work/contracts
#COPY --from=builder /ton/build/dht-server/dht-server /usr/local/bin





WORKDIR /usr/local/bin
COPY wallet_create.sh wallet_deploy.sh wallet_main_transfer.sh wallet_status.sh wallet_transfer.sh ./
RUN chmod +x wallet_create.sh wallet_deploy.sh wallet_main_transfer.sh wallet_status.sh wallet_transfer.sh

COPY validator_scripts/participate.sh validator_scripts/reap.sh ./
RUN chmod +x participate.sh reap.sh

RUN mkdir -p /var/ton-work
ADD validator_scripts /var/ton-work/validator_scripts

WORKDIR /var/ton-work

ENTRYPOINT ["/bin/bash"]
