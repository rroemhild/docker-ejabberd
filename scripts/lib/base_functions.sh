is_set() {
    local var=$1

    [[ -n $var ]]
}


is_zero() {
    local var=$1

    [[ -z $var ]]
}


file_exist() {
    local file=$1

    [[ -e $file ]]
}


is_true() {
    local var=${1,,}
    local choices=("yes" "1" "y" "true")
    for ((i=0;i < ${#choices[@]};i++)) {
        [[ "${choices[i]}" == $var ]] && return 0
    }
    return 1
}
