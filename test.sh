
function_with_retry(){
    #arguments $1: function $2: retry_times
    retry=${2:-3}
    echo $retry
    for (( i=0; i<$retry; i++ ))
        do
            $1 && break
        done
}

function_echo(){
    echo test
    exit 1
}

function_with_retry function_echo 