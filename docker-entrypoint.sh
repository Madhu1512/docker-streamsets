#!/bin/bash
set -e

# We translate environment variables to sdc.properties and ldap-login.conf and rewrite them.
set_conf() {
  if [ $# -ne 3 ]; then
    echo "set_conf requires three arguments: <key> <value> <conf>"
    exit 1
  fi

  if [ -z "$SDC_CONF" ]; then
    echo "SDC_CONF is not set."
    exit 1
  fi

  if [ "$3" == "conf" ]; then
    sed -i 's|^#\?\('"$1"'=\).*|\1'"$2"'|' "${SDC_CONF}/sdc.properties"
  elif [ "$3" == "ldap" ]; then
    sed -i 's|\('"$1"'=\"\).*|\1'"$2"'\"|i' "${SDC_CONF}/ldap-login.conf" 
  fi
}

# In some environments such as Marathon $HOST and $PORT0 can be used to
# determine the correct external URL to reach SDC.
if [ ! -z "$HOST" ] && [ ! -z "$PORT0" ] && [ -z "$SDC_CONF_SDC_BASE_HTTP_URL" ]; then
  export SDC_CONF_SDC_BASE_HTTP_URL="http://${HOST}:${PORT0}"
fi

for e in $(env); do
  key=${e%=*}
  value=${e#*=}
  if [[ $key == SDC_CONF_* ]]; then
    lowercase=$(echo $key | tr '[:upper:]' '[:lower:]')
    key=$(echo ${lowercase#*sdc_conf_} | sed 's|_|.|g')
    set_conf $key $value conf
  elif [[ $key == SDC_LDAP_* ]]; then
    lowercase=$(echo $key | tr '[:upper:]' '[:lower:]')
    key=$(echo ${lowercase#*sdc_ldap_} | sed 's|_|.|g')
    set_conf $key $value ldap
  fi
done

if [ ! -z "$SDC_ADMIN_PW" ]; then
   sed -i -e "/admin:\s*MD5:/ s/:.*/: MD5:${SDC_ADMIN_PW},user,admin/" "${SDC_CONF}/form-realm.properties"
fi

if [ ! -z "$SDC_AD_PW" ]; then
   echo ${SDC_AD_PW} > ${SDC_CONF}/ldap-bind-password.txt
fi

exec "${SDC_DIST}/bin/streamsets" "$@"
