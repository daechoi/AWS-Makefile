#!/bin/bash
# http://docs.aws.amazon.com/cli/latest/reference/cloudformation/create-stack.html

# Constant definition
PROGNAME=$(basename $0)
VERSION="0.1.0"

# Main procedure
Main(){
  # aws --profile pf --region ap-northeast-1 cloudformation create-stack --stack-name sn --template-body fileb://tb.yaml --parameters ParameterKey=Parm1,ParameterValue=test1 ParameterKey=Parm2,ParameterValue=test2
  echo aws $PROF_OPT cloudformation create-stack --stack-name $SN --template-body fileb://$TB $PARA_OPT ${PRAMS[@]}
  aws $PROF_OPT cloudformation create-stack --stack-name $SN --template-body fileb://$TB $PARA_OPT ${PRAMS[@]}
  RC=$?
  if [[ $RC -eq 0 ]] && [[ ! -z "$WAIT" ]]; then
    echo aws $PROF_OPT cloudformation wait stack-create-complete --stack-name $SN
    aws $PROF_OPT cloudformation wait stack-create-complete --stack-name $SN
  fi
  exit $RC
}

# Function definition
Usage(){
cat <<EOF
Usage: $PROGNAME [--profile <prof>] [--wait] <stack_name> <template_file> [more parameters]
EOF
}

# getopt
for OPT in "$@"; do
  case "$OPT" in
    '-h'|'--help' )
      Usage
      exit 1
      ;;
    '--version' )
      echo $VERSION
      exit 1
      ;;
    '--profile' )
      if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
        echo "$PROGNAME: option requires an argument -- $1" 1>&2
        exit 1
      fi
      PROF="$2"
      PROF_OPT="--profile $2"
      shift 2
      ;;
    '--wait' )
      WAIT="TRUE"
      shift 1
      ;;
    '--parameters' )
      PARA_OPT="--parameters"
      shift 1
      ;;
    '--'|'-' )
      shift 1
      PRAMS+=( "$@" )
      break
      ;;
    -*)
      echo "$PROGNAME: illegal option -- '$(echo $1 | sed 's/^-*//')'" 1>&2
      exit 1
      ;;
    *)
      if [[ ! -z "$1" ]] && [[ ! "$1" =~ ^-+ ]]; then
        #PRAMS=( ${PRAMS[@]} "$1" )
        PRAMS+=( "$1" )
        shift 1
      fi
      ;;
  esac
done

SN=${PRAMS[0]}
TB=${PRAMS[1]}
unset -v PRAMS[0]
unset -v PRAMS[1]
PRAMS=(${PRAMS[@]})

# no required argument
if [[ -z "$SN" ]] || [[ -z "$TB" ]]; then
  Usage
  exit 1
fi

# call main
Main
