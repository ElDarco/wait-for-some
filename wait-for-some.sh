#!/usr/bin/env bash

exitCode=0

MAN=`cat <<EOF
wait-for-some.sh is a pure bash script waiting for a positive execution of the command, before the execution of the main command.
Can be used to delay the launch of docker container, and synchronize them.
Usage:
-h          | --help                Request help
-c COMMAND  | --cmd=COMMAND         Command "check" pending exit code 0
-t TIMEOUT  | --timeout=TIMEOUT     The time allocated for the execution of the verification command.
                                    If the team will work longer than the specified time, the attempt will be considered unsuccessful. (s) (default:5)
-i INTERVAL | --interval=INTERVAL   Sets the interval between the start, the first check and the next check (s) (default:5)
-r RETRIES  | --retries=RETRIES     The number of attempts before exiting the script with an error. (default:3)

-- COMMAND ARGS                     Execute command with args after the test finishes

Example:
./wait-for-some.sh --cmd="ls -la | grep README.md" -t 10 -i 5 -r 10 -- echo 123
EOF
`

POSITIONAL=()
while [[ $# -gt 0 ]]
do
    case $1 in
        -h|--help)
        echo -e "${MAN}"
        exit;
        ;;
        -c)
        WAIT_FOR_COMMAND="$2"
        shift # past argument
        shift # past value
        ;;
        --cmd=*)
        WAIT_FOR_COMMAND="${1#*=}"
        shift # past value and argument
        ;;
        -t)
        WAIT_FOR_TIMEOUT="$2"
        shift # past argument
        shift # past value
        ;;
        --timeout=*)
        WAIT_FOR_TIMEOUT="${1#*=}"
        shift # past value and argument
        ;;
        -i)
        WAIT_FOR_INTERVAL="$2"
        shift # past argument
        shift # past value
        ;;
        --interval=*)
        WAIT_FOR_INTERVAL="${1#*=}"
        shift # past value and argument
        ;;
        -r)
        WAIT_FOR_RETRIES="$2"
        shift # past argument
        shift # past value
        ;;
        --retries=*)
        WAIT_FOR_RETRIES="${1#*=}"
        shift # past value and argument
        ;;
        --)
        shift
        WAIT_FOR_MAINCOMMAND=("$@")
        break
        ;;
        *)    # unknown option
        POSITIONAL+=("$1") # save it in an array for later
        echo -e "unknown option $1"
        echo -e "${MAN}"
        exit;
        ;;
    esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

if [[ -n $1 ]]; then
    echo "Last line of file specified as non-opt/last argument:"
    tail -1 "$1"
fi

if [[ "$WAIT_FOR_COMMAND" == "" ]]; then
    echo "Error: please enter check command"
    echo -e "${MAN}"
fi

WAIT_FOR_TIMEOUT=${WAIT_FOR_TIMEOUT:-5}
WAIT_FOR_INTERVAL=${WAIT_FOR_INTERVAL:-5}
WAIT_FOR_RETRIES=${WAIT_FOR_RETRIES:-3}

echo "waiting for execution: ${WAIT_FOR_COMMAND}"
echo "timeout: ${WAIT_FOR_TIMEOUT}"
echo "interval: ${WAIT_FOR_INTERVAL}"
echo "retries: ${WAIT_FOR_RETRIES}"
echo ""

for (( iteration = 1; iteration <= ${WAIT_FOR_RETRIES}; iteration++ ))
do
echo "waiting with a interval"
sleep ${WAIT_FOR_INTERVAL}

if eval "timeout ${WAIT_FOR_TIMEOUT} $WAIT_FOR_COMMAND" >> /dev/null; then
    echo "success"
    if [[ $WAIT_FOR_MAINCOMMAND != "" ]]; then
        exec "${WAIT_FOR_MAINCOMMAND[@]}"
    fi
    exit $exitCode;
fi

echo "failed"
done

exit $exitCode