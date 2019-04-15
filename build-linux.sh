#!/bin/bash
set -e
set -x

export PATH="$HOME/miniconda/bin:$PATH"

# Check if any clang-formatting necessary

cd /vw
./utl/clang-format check

sudo apt remove --yes --force-yes cmake

# Upgrade CMake
version=3.5
build=2
mkdir ~/temp
cd ~/temp
wget https://cmake.org/files/v$version/cmake-$version.$build-Linux-x86_64.sh
sudo mkdir /opt/cmake
sudo sh cmake-$version.$build-Linux-x86_64.sh --prefix=/opt/cmake --skip-license
sudo ln -s /opt/cmake/bin/cmake /usr/local/bin/cmake

# Clear out build directory then build using GCov and run one set of tests again
NUM_PROCESSORS=2
cd /vw
mkdir build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release -DGCOV=ON -DWARNINGS=OFF -DBUILD_JAVA=Off -DBUILD_PYTHON=Off -DBUILD_TESTS=On
make vw-bin -j ${NUM_PROCESSORS}
cd ..
cd test
export PATH=../build/vowpalwabbit/:$PATH && ./RunTests -d -fe -E 0.001
cd ..
