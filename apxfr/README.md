Code to test data transfer from Chile to storage destinations.

* Dockerfile specifies how to create a container.
* bbcp is the binary of an efficient site-to-site copy program.
* boto is a configuration file for Boto/gsutil
* data/S00.fits is a representative uncompressed sky image from AuxTel (1 CCD).
* src/harness.py is the test harness.
* src/run.sh is a minimal container entrypoint script that activates conda.
