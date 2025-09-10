# --------------------------
# Base image & environment
# --------------------------

FROM ros:humble

ENV ROS_DISTRO=humble \
	DEBIAN_FRONTEND=noninteractive  \
	DOCKER_BUILDKIT=1 \
	HOME_DIR=/home/qadt

SHELL ["/bin/bash", "-c"] 

# --------------------------
# System Dependencies
# --------------------------

# Update and install necessary dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    wget \
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
    # Put extra apt packages here for example:
    # ros-humble-rmw-fastrtps-cpp \
    && rm -rf /var/lib/apt/lists/*

# --------------------------
# Workspace and Development Dependencies
# --------------------------

# Create your workspace here
WORKDIR $HOME_DIR

# Clone QADT 2026 repository
RUN git clone https://github.com/Queens-Aerospace/QADT2026.git

# MicroDDS adapted from https://docs.px4.io/main/en/ros2/user_guide
# NOTE: Used to be v2.4.2 but updating to v2.4.3 as v2.4.2 had issues with docker build.
# Build MicroDDS using cmake via Unix Makefiles generator. '-j $(nproc)' will use all processors to speed up build times.
RUN git clone -b v2.4.3 https://github.com/eProsima/Micro-XRCE-DDS-Agent.git --depth 1 \
	&& cmake -S Micro-XRCE-DDS-Agent -B Micro-XRCE-DDS-Agent/build -G "Unix Makefiles" \
    && cmake --build Micro-XRCE-DDS-Agent/build -j $(nproc) \
    && cmake --install Micro-XRCE-DDS-Agent/build \
    && ldconfig \
	&& rm -rf Micro-XRCE-DDS-Agent/build

# Effectively copied 'px4_ubuntu.sh' from "bash ./Tools/setup/ubuntu.sh" above
# Python dependencies in requirements.txt
COPY px4_ubuntu.sh requirements.txt .
RUN bash px4_ubuntu.sh 

# Run the setup and build for PX4
RUN git clone --branch v1.16.0 --single-branch https://github.com/PX4/PX4-Autopilot.git --depth 1 \
	# &&  \
	# && pip3 install --no-cache-dir -r requirements.txt \ 
	&& make -C PX4-Autopilot \
	&& rm -rf PX4-Autopilot/build

# --------------------------
# Entrypoint and User
# --------------------------

# Add new user 'qadt'
RUN useradd -ms /bin/bash qadt && \
    echo "qadt:aero" | chpasswd && \
    usermod -aG sudo qadt 
	# Uncomment if you want sudo access without a password
	# && echo "qadt ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/qadt \
    # && chmod 0440 /etc/sudoers.d/qadt
	
# Copy files in the dockerfile's directory into the container
COPY . .
 
# Make user 'qadt' own all files in home directory
RUN chown -R qadt:qadt $HOME_DIR \
	&& chmod +x $HOME_DIR/entrypoint.sh

# Switch to user and run entry point
USER qadt
ENTRYPOINT [ "/home/qadt/entrypoint.sh" ]
CMD [ "bash" ]
