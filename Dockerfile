FROM dayta/ml_development:latest
ARG USERNAME
ARG USER_ID
ARG GROUP_ID
ARG REQUIREMENTS

# Create User which has the same user id as host user 
RUN groupadd -g ${GROUP_ID} ${USERNAME} && \
    useradd -rm -d /home/${USERNAME} -s /bin/bash -u ${USER_ID} -g ${USERNAME} -G sudo,video -p "$(openssl passwd -1 docker)" ${USERNAME}
USER ${USERNAME}
WORKDIR /home/${USERNAME}

# Install torchreid
RUN git clone https://github.com/KaiyangZhou/deep-person-reid.git && \
    cd deep-person-reid && \
    pip install --user --no-warn-script-location -r requirements.txt && \
    python setup.py install --user && \
    cd ../ && \
    rm -rf deep-person-reid

# Install project dependencies
COPY ${REQUIREMENTS} /tmp/requirements.txt
RUN  pip install --user --no-warn-script-location -r /tmp/requirements.txt