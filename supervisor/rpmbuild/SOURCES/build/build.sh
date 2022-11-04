#!/bin/bash
readonly CUR_DIR=$(cd $(dirname ${BASH_SOURCE:-$0}); pwd)

set -e

function hack(){
    local ver=$(find /usr/ -type f -name 'version.txt' -path '*/supervisor/*' -exec cat {} \; )
    local dt_file=$(find /usr/ -type f -name 'datatypes.py' -path '*/supervisor/*')
    local op_file=$(find /usr/ -type f -name 'options.py' -path '*/supervisor/*')

    local dt_read_line=$(awk '/^class Automatic:/{print NR-1;exit}' $dt_file)
    sed -ri "${dt_read_line}r ${CUR_DIR}/datatypes.py.append" $dt_file

    sed -ri '/import dict_of_key_value_pairs/a from supervisor.datatypes import dict_from_env_file' $op_file
    sed -ri '/environment_str\s+=.+?environment/r '<(
cat<<'EOF'
        environment_file = get(section, 'environment_file', '', do_expand=False)
EOF
  ) $op_file
    sed -ri '/expand\(environment_str/r '<(
cat<<'EOF'
            if environment_file:
                environment.update(dict_from_env_file(environment_file))
EOF
  ) $op_file

  # 设置 VERSION
  sed -ri '/^VERSION\s+=\s+/s#= .+#= "'"${ver}"'"#' $op_file
}

function main(){
    hack $@
}

main $@
