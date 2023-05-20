source common.sh

print_head "Copying Mongo repo"
cp ${script_location}/files/mongodb.repo /etc/yum.repos.d/mongo.repo &>>${LOG}
status_check

print_head "Installing Mongodb"
yum install mongodb-org -y &>>${LOG}
status_check

print_head "Starting Mongo service"
systemctl enable mongod &>>${LOG}
systemctl start mongod &>>${LOG}
status_check

print_head "changing Port adress"
sed -i -e 's/127.0.0.1/0.0.0.0/gi' /etc/mongod.conf &>>${LOG}
status_check

print_head "Restart mongo"
systemctl restart mongod &>>${LOG}
status_check