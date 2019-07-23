# aws-me

Set/unset AWS profile credentials in a bash shell environment

By default, this script will retrieve AWS credentials stored in a [Pass](https://www.passwordstore.org/) store provided that they follow the following structure:

```
$ pass
Password Store
└── AWS
    ├── someprofile
    │   ├── aws_access_key_id
    │   └── aws_secret_access_key
    └── anotherprofile
        ├── aws_access_key_id
        └── aws_secret_access_key
```

Alternatively, you can retrieve AWS credentials stored in the default `$HOME/.aws/credentials` file. To enable this, create an empty file called `.use-credentials-file` in the same dir as this script.

This script has only been tested in Bash 5.0.x on Mac OS.

## Usage

```
Usage: aws-me.sh [-u|--unset] [PROFILE]

 -u, --unset  (optional) Unset all AWS-related ENVVARs
 PROFILE      (optional) Set ENVVARs for PROFILE

If no arguments are given, lists all profiles defined in the
credentials file.
```

You'll want to run this in conjunction with `source` to make the changes stick in the current shell.

```
$ echo $AWS_ACCESS_KEY_ID

$ source aws-me.sh someprofile
[someprofile] $ echo $AWS_ACCESS_KEY_ID
AXXXXXXXXXXXXXXXXXXX
```
