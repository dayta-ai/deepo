FROM dayta/ml_development:latest

# Install torchreid
RUN git clone https://github.com/KaiyangZhou/deep-person-reid.git && \
    cd deep-person-reid && \
    pip install --no-warn-script-location -r requirements.txt && \
    python setup.py install --user && \
    cd ../ && \
    rm -rf deep-person-reid

ARG USERNAME
ARG USER_ID
ARG GROUP_ID
ARG REQUIREMENTS

# Create User which has the same user id as host user 
RUN groupadd -g ${GROUP_ID} ${USERNAME} && \
    useradd -rm -d /home/${USERNAME} -s /bin/bash -u ${USER_ID} -g ${USERNAME} -G sudo,video -p "$(openssl passwd -1 docker)" ${USERNAME}
USER ${USERNAME}
WORKDIR /home/${USERNAME}

# Create pytorch cache directory
RUN mkdir -p .cache/torch

# Install missing project dependencies
COPY ${REQUIREMENTS} /tmp/requirements.txt
RUN pip freeze | sed s/=.*// > requirements.txt && \
    diff /tmp/requirements.txt requirements.txt | grep "<" | sed "s/^< //" > requirements.txt && \
    pip install --user --no-warn-script-location -r requirements.txt