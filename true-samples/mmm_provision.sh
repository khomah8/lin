#!/bin/bash

## __respective-developer__@__respective-company__
# [ ops_mtl_provision_mta_chk.sh ]


VER="0.3.1"
cT_GREEN="\e[32m"
cT_YELLOW="\e[33m"
cT_RED="\e[31m"
cT_CYAN="\e[36m"
cT_MAGENTA="\e[35m"
cB_CYAN="\e[46m"
cB_RED="\e[41m"
cBOLD="\e[1m"
cRESET="\e[0m"
pRESET=$(tput sgr0)
pEND=$(tput hpa $(tput cols))$(tput cub 50)
BASE_IFACE="ifcfg-eth0"


function func_MSG_OK {
  echo -e " ${TEXT_INFO}   ${pEND}[${cT_GREEN} OK ${cRESET}]${pRESET}"
}

function func_MSG_FAIL {
  echo -e " ${TEXT_INFO}   ${pEND}[${cT_RED} FAIL ${cRESET}]${pRESET}"
}

function func_CHK_VALID_IP_ADDR {
  local ip="$1"
  if ip -o address show to "${IP_ADDR}" >/dev/null 2>&1; then
    return 0
  else
    echo -e "\n ${cB_RED} > ${cRESET} ${cT_RED}IP address '${cT_YELLOW}${IP_ADDR}${cRESET}${cT_RED}' not valid! ${cRESET}\n"
    exit 1
  fi
}

function func_USAGE {
  echo -e "\n  ${cT_CYAN}-h${cRESET}   This message"
  echo -e "  ${cT_CYAN}-b${cRESET}   Bindig group name"
  echo -e "  ${cT_CYAN}-i${cRESET}   IP address"
  echo -e "\n Usage: ${cT_YELLOW}$0${cRESET} ${cBOLD}${cT_CYAN}-b${cRESET} <${cT_CYAN}binding_group_name${cRESET}> ${cBOLD}${cT_CYAN}-i${cRESET} <${cT_CYAN}'ip_address'${cRESET}> [${cT_CYAN}-h${cRESET}]\n"
  exit
}


while getopts ":hb:i:" opt; do
  case ${opt} in
    h )
      echo
      echo -e " ${cT_MAGENTA}Script for OPS MTL check MTA provision${cRESET}"
      func_USAGE
      ;;
    b )
      BINDING_GROUP_NAME=${OPTARG}
      ;;
    i )
      IP_ADDR=${OPTARG}
      ;;
    \? )
      echo -e "\n ${cB_RED} Error: ${cRESET} Invalid option ${cT_CYAN}-${OPTARG}${cRESET}. Use ${cT_CYAN}-h${cRESET} for help.\n" 1>&2
      exit 1
      ;;
    : )
      echo -e "\n ${cB_RED} Error: ${cRESET} Option ${cT_CYAN}-${OPTARG}${cRESET} requires an argument. Use ${cT_CYAN}-h${cRESET} for help.\n" 1>&2
      exit 1
      ;;
  esac
done

## Check binding group name
if [[ -z ${BINDING_GROUP_NAME} ]]; then
  echo -e "\n ${cB_RED} > ${cRESET} ${cT_RED}'Binding group name' can't be empty! ${cRESET}\n"
  func_USAGE
  exit 1
else
  BINDING_GROUP_NAME=$(echo ${BINDING_GROUP_NAME} | sed 's/ //g')
  POOL_NAME=$(echo ${BINDING_GROUP_NAME} | cut -d'_' -f1)
fi

## Check ip address(es)
if [[ -z ${IP_ADDR} ]]; then
  echo -e "\n ${cB_RED} > ${cRESET} ${cT_RED}'IP address(es)' can't be empty! ${cRESET}\n"
  func_USAGE
  exit 1
else
  func_CHK_VALID_IP_ADDR "${IP_ADDR}"
  BINDING=$(echo ${BINDING_GROUP_NAME}_$(echo ${IP_ADDR} | tr . _))
fi

if [[ $(whoami) != 'root' ]]; then
  echo -e "\n ${cB_RED} > ${cRESET} ${cT_RED}Run script via sudo! ${cRESET}\n"
  exit 1
fi

## Show requirement data
echo -e "\n Binding group name: '${cT_CYAN}${BINDING_GROUP_NAME}${cRESET}'\n Pool name: '${cT_CYAN}${POOL_NAME}${cRESET}'\n IP addresses list: '${cT_CYAN}${IP_ADDR}${cRESET}'\n Binding: '${cT_CYAN}${BINDING}${cR}'\n"
echo -e " ${cB_CYAN} > ${cRESET} All data is correct? (y/n):"
function func_DATA_CHK {
  read -p ":|" VAR_CORRECT
  case ${VAR_CORRECT} in
    y|Y )
      :
      ;;
    n|N )
      exit
      ;;
    * )
      func_DATA_CHK
      ;;
  esac
}
func_DATA_CHK

## Checker configuration
#ip addr | grep -q "${IP_ADDR}"
for HOST_ADDR in $(hostname -I); do
  echo ${HOST_ADDR} | grep -q "^${IP_ADDR}$"
  CHK_IP__CODE_EXT=$?

  case ${CHK_IP__CODE_EXT} in
    0 ) break ;;
  esac
done

ehco
IP_ADDR__SUB_IFACE=$(ip addr | grep "${IP_ADDR}/32" | awk -F':' {'print $2'})
ls /etc/sysconfig/network-scripts/${BASE_IFACE}:${IP_ADDR__SUB_IFACE}
SUB_IFACE_EXIST__CODE_EXIT=$?

TEXT_INFO="Network sub-interface ('${cT_CYAN}${IP_ADDR__SUB_IFACE}${cRESET}') add..."
if [[ ${SUB_IFACE_EXIST__CODE_EXIT} -eq 0 ]]; then
  func_MSG_OK
else
  func_MSG_FAIL
fi
CURRENT_CONFIG_ADDR=$(cat /etc/sysconfig/network-scripts/${BASE_IFACE}:${IP_ADDR__SUB_IFACE} | awk -F= {'print $2'} | cut -d' ' -f1)

TEXT_INFO="IP address ('${cT_CYAN}${IP_ADDR}${cRESET}') set up..."
if [[ ${CHK_IP__CODE_EXT} -eq 0 ]] && [[ ${IP_ADDR} == ${CURRENT_CONFIG_ADDR} ]]; then
  func_MSG_OK
else
  func_MSG_FAIL
fi

grep -q "Bind_address = \"${IP_ADDR}\"" /opt/msys/ecelerity/etc/conf/default/bindings.conf
CHK_BINDING__IP_ADDR__CODE_EXT=$?

grep -q "^Binding_Group \"${BINDING_GROUP_NAME}\"" /opt/msys/ecelerity/etc/conf/default/bindings.conf
CHK_BINDING__BINDING_GROUP__CODE_EXT=$?

grep -q "Binding \"${BINDING}\"" /opt/msys/ecelerity/etc/conf/default/bindings.conf
CHK_BINDING__BINDING__CODE_EXT=$?

TEXT_INFO="Binding group ('${cT_CYAN}${BINDING_GROUP_NAME}${cRESET}') configure... "
if [[ ${CHK_BINDING__IP_ADDR__CODE_EXT} -eq 0 && ${CHK_BINDING__BINDING_GROUP__CODE_EXT} -eq 0 && ${CHK_BINDING__BINDING__CODE_EXT} -eq 0 ]]; then
  func_MSG_OK
else
  func_MSG_FAIL
fi
echo
