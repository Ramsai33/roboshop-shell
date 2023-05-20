source common.sh


print_head "Installing nginx"
yum install nginx -y  &>>${LOG}
status_check

print_head "Starting Service"
systemctl enable nginx &>>${LOG}
systemctl start nginx &>>${LOG}
status_check

print_head "Removing Default App content"
rm -rf /usr/share/nginx/html/* &>>${LOG}
status_check

print_head "Downloadig App content"
curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend.zip &>>${LOG}
status_check

print_head "Extracting App content"
cd /usr/share/nginx/html &>>${LOG}
unzip /tmp/frontend.zip &>>${LOG}
status_check

print_head "Reverse Proxy Setup"
cp ${script_location}/files/frontend.conf /etc/nginx/default.d/roboshop.conf &>>${LOG}
status_check
