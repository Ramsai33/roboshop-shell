source common.sh

print_head "Downloading Nodejs repo"
curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>${LOG}
status_check

print_head "Installing Nodejs"
yum install nodejs -y &>>${LOG}
status_check

print_head "Adding user"
id roboshop &>>${LOG}
if [ $? -ne 0 ]; then
  useradd roboshop &>>${LOG}
  status_check
fi

print_head "Creating App directory"
mkdir -p /app &>>${LOG}
status_check

print_head "Downloading App content"
curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue.zip &>>${LOG}
status_check

rm -rf /app/*

print_head "Extracting App content"
cd /app
unzip /tmp/catalogue.zip &>>${LOG}
status_check

print_head "Downloading Dependencies"
cd /app
npm install &>>${LOG}
status_check

print_head "Copying Systemd"
cp ${script_location}/files/catalogue.service /etc/systemd/system/catalogue.service &>>${LOG}
status_check

print_head "daemon-reload"
systemctl daemon-reload &>>${LOG}
status_check

print_head "Starting catalogue service"
systemctl enable catalogue &>>${LOG}
systemctl start catalogue &>>${LOG}
status_check

cp ${script_location}/files/mongodb.repo /etc/yum.repos.d/mongo.repo &>>${LOG}

print_head "Install MONGODB"
yum install mongodb-org-shell -y &>>${LOG}
status_check

print_head "Load schema"
mongo --host mongodb-dev.ramdevops35.online </app/schema/catalogue.js &>>${LOG}
status_check