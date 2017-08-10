#!/bin/bash
# Neova Health nh-tooling

# Immutable IDs for Jenkins activities
# Uses bashids - Bash implementation of the hashid algorithm [@benwilber](https://github.com/benwilber/bashids)

# Handles usage of script
function usage {
cat << EOF
Usage: $0 [ -e ] [ -d ] id

OPTIONS:
  - e:  Create a new NH_HASHID from unix epoch
  - d:  Decode NH_HASHID to unix epoch

EOF
}

# Call bashids with ARGS from case
function jenkID {
    ../bashids/bashids $2 -s NHTEK $1
}

# Get OPTARGS
while getopts “ed:j” OPTION
do
    case $OPTION in
        e)
            NH_ID=(`date +%s`)
            ACTION="-e"
            ACTION_NAME="encode"
            ;;
        d)
            NH_ID=$OPTARG  
            ACTION="-d"
            ACTION_NAME="decode"
            ;;
        j)
            NH_ID=(`date +%s`)
            ACTION_NAME="jenkins"
            ;;
        ?)
            usage
            exit
            ;;
    esac
done

# Call jenkID function
if [ $ACTION_NAME == encode ] ; then
    NH_ENCODE=$(jenkID ${NH_ID} ${ACTION})
    NH_RESULT=$NH_ENCODE
    echo "NH_HASHID=$NH_RESULT" > hashid.out
fi

if [ $ACTION_NAME == decode ] ; then
    NH_DECODE=$(jenkID $NH_ID $ACTION)
    NH_RESULT=("`date -d @$NH_DECODE`")
    echo "NH_DTSTAMP=$NH_RESULT" > dtstamp.out
fi

if [ $ACTION_NAME == jenkins ] ; then
    NH_ENCODE=$(jenkID ${NH_ID} -e)
    NH_HASHID=$NH_ENCODE

    NH_DECODE=$(jenkID $NH_ENCODE -d)
    NH_DTSTAMP=("`date -d @$NH_DECODE`")

    echo "NHT_HASHID=$NH_HASHID"
    echo "NHT_DTSTAMP=$NH_DTSTAMP"
fi
