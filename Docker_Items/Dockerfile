# Use Ubuntu 22.04 as the base image
FROM ubuntu:22.04

# Set the maintainer (optional but good practice)
LABEL maintainer="Ethan M (22knc5@queensu.ca)"

# Avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive
ENV ROS2_DISTRO=humble
#New docker buildx
ENV DOCKER_BUILDKIT=1
#Old dokcer build
#ENV DOCKER_BUILDKIT=0

# Update and install dependencies
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
	astyle \
	build-essential \
	ccache \
	cmake \
	cppcheck \
	file \
	g++ \
	gcc \
	gdb \
	git \
	lcov \
	libssl-dev \
	libxml2-dev \
	libxml2-utils \
	make \
	ninja-build \
	python3 \
	python3-dev \
	python3-pip \
	python3-setuptools \
	python3-wheel \
	rsync \
	shellcheck \
	unzip \
	zip \
    ca-certificates \
    gnupg \
    gosu \
    lsb-release \
    software-properties-common \
    sudo \
    wget \
    nano \
    vim \
        lsb-release \
        build-essential \
        software-properties-common \
        && apt-get clean \
        && rm -rf /var/lib/apt/lists/*

# Ros2 Humble installation from px4
RUN apt update && apt install -y locales && \
    locale-gen en_US en_US.UTF-8 && \
    update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 && \
    export LANG=en_US.UTF-8 && \
    apt install -y software-properties-common && \
    add-apt-repository universe && \
    apt update && apt install -y curl && \
    curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null && \
    apt update && apt upgrade -y && \
    apt install -y ros-humble-desktop ros-dev-tools && \
    echo "source /opt/ros/humble/setup.bash" >> /etc/bash.bashrc

WORKDIR /home/qadt

# Copy files in the same directory into the container
COPY . .

# Miicrodds adapted from https://docs.px4.io/main/en/ros2/user_guide
# Used to be v2.4.2 but updating to v2.4.3 as v2.4.2 had issues with docker build
RUN git clone -b v2.4.3 https://github.com/eProsima/Micro-XRCE-DDS-Agent.git && \
	mkdir Micro-XRCE-DDS-Agent/build 

WORKDIR /home/qadt/Micro-XRCE-DDS-Agent/build

WORKDIR /home/qadt/Micro-XRCE-DDS-Agent/build
RUN cmake ..
RUN make && make install && ldconfig /usr/local/lib/

WORKDIR /home/qadt

# Run the setup for PX4
RUN git clone --branch v1.16.0 --single-branch https://github.com/PX4/PX4-Autopilot.git --recursive 

# effectivly copied from "bash ./Tools/setup/ubuntu.sh" above
RUN bash px4_ubuntu.sh

#Python dependencies in requirements .txt
RUN pip3 install --no-cache-dir -r requirements.txt

WORKDIR /home/qadt/PX4-Autopilot

RUN make px4_sitl

# Create a non-root user for security
RUN useradd -m qadt && \
    echo "qadt:aero" | chpasswd && \
    usermod -aG sudo qadt

RUN chown -R qadt:qadt /home/qadt

USER qadt
WORKDIR /home/qadt
CMD ["bash"]