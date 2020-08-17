FROM centos:8
WORKDIR /root
RUN yum install -y openssh-clients
COPY data/ data/
COPY boto .boto
RUN curl -LO https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh && \
    bash Miniforge3-Linux-x86_64.sh -b && \
    source miniforge3/bin/activate && \
    conda install google-cloud-storage minio boto3 cfitsio
COPY harness.py bbcp run.sh ./
ENTRYPOINT ["./run.sh"]
