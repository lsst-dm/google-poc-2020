FROM centos:8
RUN yum install -y python38 openssh-clients
RUN pip3.8 install google-cloud-storage minio boto3
WORKDIR /root
COPY data/ data/
COPY bbcp bbcp
COPY boto .boto
COPY harness.py .
ENTRYPOINT ["python3.8", "harness.py"]
