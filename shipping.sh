source common.sh

if [ -z "${set_root_password}" ]; then
  echo "Please set password for Mysql"
  exit
fi

component=shipping

schema_load=true

schema_type=mysql

Maven

