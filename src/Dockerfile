FROM alpine
RUN apk add python3 openssh-client && ln -s /usr/bin/python3 /usr/bin/python
RUN pip3 install google-cloud-storage
RUN wget https://storage.googleapis.com/pub/gsutil.tar.gz && tar xzf gsutil.tar.gz
COPY data .
COPY boto /root/.boto
COPY harness.py .
ENTRYPOINT ["python3", "harness.py"]
