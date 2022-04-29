FROM zenika/terraform-aws-cli:latest
WORKDIR /app
COPY . .

# We will invoke this container as a one-time job by overriding the command below
# at runtime with one of the terraform scripts in the bin/ directory. We only
# use the infinite sleep command below so that, if you want to run the container
# as a service in your app template for troubleshooting purposes, you can do so easily.
CMD ["sleep", "infinity"]

