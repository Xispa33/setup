Installation here was tested on Ubuntu 24.04 only

## Usage ##
```
git clone https://github.com/Xispa33/setup.git
cd setup; ./install.sh
```

To test:
```
docker pull ubuntu:24.04
docker run -it -v $THIS_REPO:/home/ ubuntu:24.04
./install.sh
```
