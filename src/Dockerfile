FROM centos:7
RUN yum install -y python3 openssh-clients
RUN pip3 install google-cloud-storage minio boto3
WORKDIR /root
COPY data/ data/
COPY bbcp bbcp
COPY boto .boto
COPY harness.py .
ENTRYPOINT ["python3", "harness.py"]
