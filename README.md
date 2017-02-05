# docker\_awscli

_... for systems such as RancherOS or coreos -_
_use this container to emulate the aws cli binary to run aws commands_

## building

**built by shippable.com**

```bash
git clone https://github.com/opsgang/docker_awscli.git
cd docker_awscli
git clone https://github.com/opsgang/alpine_build_scripts
./build.sh # adds custom labels to image
```

## installing

```bash
# ... replace /in/my/PATH below with somewhere in your $PATH
docker pull opsgang/awscli:stable # or use x.y.z version as required.
wget https://github.com/opsgang/docker_awscli/raw/master/.examples/aws -O /in/my/PATH/aws
chmod a+x /in/my/PATH/aws
```

## running

```bash
# ... run like aws cli
aws --region us-east-1 ec2 describe-images # ... or whatever else you need to do.
```

Note that the aws cmd is running within a container, so there are caveats when it comes to
making AWS\_\* env vars or the local file-system available to the container

See [README in .examples dir](https://github.com/opsgang/docker_awscli/tree/master/.examples)
for how to use $DOCKER\_OPTS to get around those caveats.
