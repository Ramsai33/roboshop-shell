source common.sh
if [ -z "${set_root_password}" ]; then
  echo "Please enter mysql Password"
  exit
fi

print_head "Disable Module"
yum module disable mysql -y &>>${LOG}
status_check

print_head "Copying Repo"
cp ${script_location}/files/mysql.repo /etc/yum.repos.d/mysql.repo &>>${LOG}
status_check

print_head "Installing Mysql"
yum install mysql-community-server -y &>>${LOG}
status_check

print_head "Starting Mysql Service"
systemctl enable mysqld &>>${LOG}
systemctl start mysqld &>>${LOG}
status_check

mysql_secure_installation --set-root-pass ${set_root_password}

