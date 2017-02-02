[1]: http://docs.aws.amazon.com/cli/latest/reference/ "aws cli reference (latest)"
# aws

_... a replacement for awscli binary, using docker awscli:stable ..._

    Particularly useful for locked down OS on which you can't install
    python, pip, awscli etc ... e.g. RancherOS or CoreOS

Replaces awscli binary command 'aws': invokes the awscli:stable image under the hood
to provide the same functionality.

## USAGE

Copy file to anywhere in your $PATH and make executable:

```bash
wget https://github.com/opsgang/docker_awscli/raw/master/.examples/aws -O /in/my/PATH/aws
chmod a+x /in/my/PATH/aws
```

Now run like [aws cli][1] e.g. aws ec2 describe-images

If running on an ec2 instance with an iam profile, the container will automatically
have the same aws policies. If you need to interact with aws api as a different user
or with different rights, see below about $DOCKER\_OPTS.

## DOCKER\_OPTS

You must set $DOCKER\_OPTS first if you want to:

1. **use AWS env vars.**
    The awscli will read and honour certain env vars set
    in the shell in which the command is invoked. (prefixed $AWS\_).
    This replacement runs a docker container with its own environment. It does not
    have access to your shell's vars by default.

2. **Interacting with the local filesystem.**
    The docker container does not by default have access to the host machine's filesystem.
    Commands like `aws s3 cp ...` will not be able to read and write by default.

### EXAMPLE: USING AWS\_ ENV VARS

```bash
# ... pass the AWS_ vars I've got set in my current shell
export DOCKER_OPTS="
    --env AWS_SECRET_ACCESS_KEY
    --env AWS_ACCESS_KEY_ID
    --env AWS_DEFAULT_REGION=eu-west-2
"
aws ec2 describe-images # will use the vars from your current env
```

### EXAMPLE: WRITING TO THE HOST FILESYSTEM


```bash
# mount relevant local filesystem as docker volume, and make docker work there
export DOCKER_OPTS="-v $PWD:/project -w /project" # set workdir to writeable mount

aws s3 cp s3://bucket.example.com/some/file .
```

