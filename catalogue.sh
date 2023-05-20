source common.sh

print_head "Downloading Nodejs repo"
curl -sL https://rpm.nodesource.com/setup_lts.x | bash
status_check

print_head "Installing Nodejs"
yum install nodejs -y
status_check

print_head "Adding user"
id roboshop
if [ $? -ne 0 ]; then
  useradd roboshop
  status_check
fi

print_head "Creating App directory"
mkdir -p /app
status_check

print_head "Downloading App content"
curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue.zip
status_check

print_head "Extracting App content"
cd /app
unzip /tmp/catalogue.zip
status_check

print_head "Downloading Dependencies"
cd /app
npm install
status_check

print_head "Copying Systemd"
cp ${script_location}/files/catalogue.service /etc/systemd/system/catalogue.service
status_check

print_head "daemon-reload"
systemctl daemon-reload
status_check

print_head "Starting catalogue service"
systemctl enable catalogue
systemctl start catalogue
status_check

print_head "Install MONGODB"
yum install mongodb-org-shell -y
status_check

print_head "Load schema"
mongo --host mongodb-dev.ramdevops35.online </app/schema/catalogue.js
status_check