FROM julia:1.6.3

# create user with a home directory
ARG NB_USER=jovyan
ARG NB_UID=1000
ENV USER ${NB_USER}
ENV HOME /home/${NB_USER}

RUN adduser --disabled-password \
    --gecos "Default user" \
    --uid ${NB_UID} \
    ${NB_USER}

USER root

RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    unzip \
    && \
    apt-get clean && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/* # clean up

RUN apt-get update && apt-get install -y \
    htop \
    nano \
    openssh-server \
    tig \
    tree \
    && \
    apt-get clean && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/* # clean up

USER ${USER}

WORKDIR /workspace/MyVSCodeWorkspace.jl

ENV JULIA_PROJECT "@."

COPY ./src /workspace/MyVSCodeWorkspace.jl/src
COPY ./docs/Project.toml /workspace/MyVSCodeWorkspace.jl/docs
COPY ./Project.toml /workspace/MyVSCodeWorkspace.jl

USER root
RUN chown -R ${NB_UID} /workspace/MyVSCodeWorkspace.jl
USER ${USER}

RUN rm -f Manifest.toml && julia -e 'using Pkg; \
    Pkg.instantiate(); \
    Pkg.precompile()' && \
    # Check Julia version \
    julia -e 'using InteractiveUtils; versioninfo()'

WORKDIR ${HOME}
USER ${USER}
EXPOSE 8000

CMD ["julia"]
