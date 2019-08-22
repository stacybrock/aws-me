#!/bin/bash

PROFILE=$1
if [[ $1 = '--help' ]] || [[ $1 = '-h' ]]; then
    cat << EOF
Usage: awsme.sh [-u|--unset] [PROFILE]

 -u, --unset  (optional) Unset all AWS-related ENVVARs
 PROFILE      (optional) Set ENVVARs for PROFILE

Retrieves credentials stored in a Pass store by default. To use
an AWS credentials file, set the USE_AWS_CREDENTIALS_FILE
environment variable to the absolute path where the file is
located.

If no arguments are given, lists all profiles defined in the
pass store or credentials file.
EOF
    exit
fi

PASS_STORE="$HOME/.password-store/AWS"

if [[ $1 = '' ]]; then
    if [[ ! -z ${USE_AWS_CREDENTIALS_FILE+x} ]]; then
        # list profiles configured in the credentials file
        ARGS=(-ne 'print "$1\n" if /\[(.*)\]/' $USE_AWS_CREDENTIALS_FILE)
        PROFILES=$(perl "${ARGS[@]}" | sort)
        for profile in $PROFILES
        do
            echo $profile
        done
    else
        # list profiles in the pass store
        ls -1 $PASS_STORE
    fi
elif [[ $1 = '-u' || $1 = '--unset' ]]; then
    # unset AWS environment variables
    AWS_ENVVARS=("AWS_ACCESS_KEY_ID" "AWS_SECRET_ACCESS_KEY")
    for envvar in ${AWS_ENVVARS[*]}
    do
        unset $envvar
    done

    # reset prompt if we changed it previously
    if [ ! -z ${_OLD_AWSME_PROMPT+x} ]; then
        export PS1=$_OLD_AWSME_PROMPT
        unset _OLD_AWSME_PROMPT
    fi
    echo "AWS environment cleared."
else
    # configure environment for the given profile

    # check if USE_AWS_CREDENTIALS_FILE envvar is set
    if [[ ! -z ${USE_AWS_CREDENTIALS_FILE+x} ]]; then
        echo "Extracting keys from credentials file..."
        AKEY=`grep -A2 "$1" $USE_AWS_CREDENTIALS_FILE | grep aws_access_key_id | awk '{ print $3 }'`
        SKEY=`grep -A2 "$1" $USE_AWS_CREDENTIALS_FILE | grep aws_secret_access_key | awk '{ print $3 }'`
    else
        echo "Extracting keys from pass store..."
        AKEY=`pass AWS/$1/aws_access_key_id`
        SKEY=`pass AWS/$1/aws_secret_access_key`
    fi

    # check for errors
    if [[ $AKEY = '' || $SKEY = '' ]]; then
        echo "Error finding credentials for profile '$1'"
    else
        export AWS_ACCESS_KEY_ID=$AKEY
        export AWS_SECRET_ACCESS_KEY=$SKEY

        # add current profile to prompt
        if [ -z ${_OLD_AWSME_PROMPT+x} ]; then
            export _OLD_AWSME_PROMPT=$PS1
        fi
        export PS1="\e[1;33m[$1]\e[m $_OLD_AWSME_PROMPT"
    fi
fi
