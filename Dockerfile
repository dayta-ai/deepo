# ==================================================================
# base image
# ------------------------------------------------------------------
FROM deepo_tmp

# Get existing python package list and block opencv-python
RUN pip freeze | sed s/=.*// > /tmp/existing_requirements.txt && \
    echo "opencv-python" >> /tmp/existing_requirements.txt

# ==================================================================
# common dependencies
# ------------------------------------------------------------------

# ==================================================================
# user space
# ------------------------------------------------------------------
ARG USERNAME
ARG USER_ID
ARG GROUP_ID
ARG REQUIREMENTS
ARG INIT_SCRIPT

# Create User which has the same user id as host user 
RUN groupadd -g ${GROUP_ID} ${USERNAME} && \
    useradd -rm -d /home/${USERNAME} -s /bin/bash -u ${USER_ID} -g ${USERNAME} -G sudo,video -p "$(openssl passwd -1 docker)" ${USERNAME}
USER ${USERNAME}
WORKDIR /home/${USERNAME}

# Create pytorch cache directory
RUN mkdir -p .cache/torch

# ==================================================================
# project dependencies
# ------------------------------------------------------------------
# Install missing project dependencies
COPY ${REQUIREMENTS} /tmp/requirements.txt
RUN diff /tmp/requirements.txt /tmp/existing_requirements.txt | grep "<" | sed "s/^< //" > requirements.txt && \
    pip install --user --no-warn-script-location -r requirements.txt && \
    rm requirements.txt
COPY ${INIT_SCRIPT} /tmp/init.sh
RUN cp /tmp/init.sh /home/${USERNAME}/init.sh && chmod u+x /home/${USERNAME}/init.sh
