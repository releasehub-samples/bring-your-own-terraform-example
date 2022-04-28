FROM zenika/terraform-aws-cli:latest

USER root
RUN apt-get update
RUN apt install -y build-essential
RUN apt-get install --no-install-recommends -y curl
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash
RUN . ~/.nvm/nvm.sh && nvm install node

WORKDIR /app
COPY . .

# We will invoke this container as a one-time job by overriding the command below
# at runtime with one of the terraform scripts in the bin/ directory. We only
# use the infinite sleep command below so that, if you want to run the container
# as a service in your app template for troubleshooting purposes, you can do so easily.
CMD ["sleep", "infinity"]

