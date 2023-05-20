script_location=$(pwd)
LOG=/tmp/roboshop.log

print_head() {
  echo -e "\e[1m $1 \e[0m"
}

status_check() {
  if [ $? -eq 0 ]; then
    echo -e "\e[32m SUCCESS \e[0m"
  else
    echo -e "\e[31m Failure \e[0m"
    echo "Please refer log file for more info- ${LOG}"
    exit
  fi
}

Nodejs() {

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
  curl -o /tmp/.zip https://roboshop-artifacts.s3.amazonaws.com/${component}.zip &>>${LOG}
  status_check

  rm -rf /app/*

  print_head "Extracting App content"
  cd /app
  unzip /tmp/${component}.zip &>>${LOG}
  status_check

  print_head "Downloading Dependencies"
  cd /app
  npm install &>>${LOG}
  status_check

  print_head "Copying Systemd"
  cp ${script_location}/files/${component}.service /etc/systemd/system/${component}.service &>>${LOG}
  status_check

  print_head "daemon-reload"
  systemctl daemon-reload &>>${LOG}
  status_check

  print_head "Starting ${component} service"
  systemctl enable ${component} &>>${LOG}
  systemctl start ${component} &>>${LOG}
  status_check

  cp ${script_location}/files/mongodb.repo /etc/yum.repos.d/mongo.repo &>>${LOG}

  print_head "Install MONGODB"
  yum install mongodb-org-shell -y &>>${LOG}
  status_check

  print_head "Load schema"
  mongo --host mongodb-dev.ramdevops35.online </app/schema/${component}.js &>>${LOG}
  status_check

}
