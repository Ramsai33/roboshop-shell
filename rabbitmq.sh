source common.sh

if [ -z ${set_root_password} ]; then
  echo "Please set password for rabbitmq"
  exit
fi

print_head "Configuring Yum Repo"
curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash &>>${LOG}
curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash &>>${LOG}
status_check

print_head "Install Rabbitmq"
yum install rabbitmq-server -y &>>${LOG}
status_check

print_head "Start Service"
systemctl enable rabbitmq-server
systemctl start rabbitmq-server
status_check

print_head "Setting Password"
rabbitmqctl add_user roboshop ${set_root_password} &>>${LOG}
status_check

print_head "Set permissions"
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>${LOG}
status_check