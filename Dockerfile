# Define custom function directory
ARG FUNCTION_DIR="/function"

FROM public.ecr.aws/docker/library/python:buster as build-image

# Include global arg in this stage of the build
ARG FUNCTION_DIR

# Install aws-lambda-cpp build dependencies
RUN apt-get update --allow-insecure-repositories

RUN apt-get install -y \
  g++ \
  make \
  cmake \
  unzip \
  libcurl4-openssl-dev

# Copy function code
RUN mkdir -p ${FUNCTION_DIR}
COPY app/* ${FUNCTION_DIR}

# Install the function's dependencies
RUN pip install \
    --target ${FUNCTION_DIR} \
        awslambdaric


FROM public.ecr.aws/docker/library/python:buster

# Include global arg in this stage of the build
ARG FUNCTION_DIR
# Set working directory to function root directory
WORKDIR ${FUNCTION_DIR}

# Copy in the built dependencies
COPY --from=build-image ${FUNCTION_DIR} ${FUNCTION_DIR}

# RUN mkdir -p ~/.aws-lambda-rie && curl -Lo ~/.aws-lambda-rie/aws-lambda-rie \
# https://github.com/aws/aws-lambda-runtime-interface-emulator/releases/latest/download/aws-lambda-rie \
# && chmod +x ~/.aws-lambda-rie/aws-lambda-rie  

RUN curl -Lo /usr/local/bin/aws-lambda-rie \
https://github.com/aws/aws-lambda-runtime-interface-emulator/releases/latest/download/aws-lambda-rie \
&& chmod +x /usr/local/bin/aws-lambda-rie

# COPY ./entry_script.sh /entry_script.sh
# COPY ./aws-lambda-rie /usr/local/bin/aws-lambda-rie
# ENTRYPOINT [ "/entry_script.sh" ]

# # ENTRYPOINT [ "/usr/local/bin/python", "-m", "awslambdaric" ]
ENTRYPOINT [ "/usr/local/bin/aws-lambda-rie","/usr/local/bin/python", "-m", "awslambdaric" ]
CMD [ "app.handler" ]
