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

APP_PREREQ() {
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
    curl -o /tmp/${component}.zip https://roboshop-artifacts.s3.amazonaws.com/${component}.zip &>>${LOG}
    status_check

    rm -rf /app/*

    print_head "Extracting App content"
    cd /app
    unzip /tmp/${component}.zip &>>${LOG}
    status_check

}

SYSTEMD() {

  print_head "daemon-reload"
    systemctl daemon-reload &>>${LOG}
    status_check

    print_head "Starting ${component} service"
    systemctl enable ${component} &>>${LOG}
    systemctl start ${component} &>>${LOG}
    status_check
}



LOAD_SCHEMA() {

  if [ ${schema_load}=="true" ]; then

    if [ ${schema_type}=="mongodb" ]; then

    cp ${script_location}/files/mongodb.repo /etc/yum.repos.d/mongo.repo &>>${LOG}

    print_head "Install MONGODB"
    yum install mongodb-org-shell -y &>>${LOG}
    status_check

    print_head "Load schema"
    mongo --host mongodb-dev.ramdevops35.online </app/schema/${component}.js &>>${LOG}
    status_check

    fi

    if [ ${schema_type}=="mysql" ]; then
    print_head "Install Mysql"
      yum install mysql -y &>>${LOG}
      status_check

      mysql -h mysql-dev.ramdevops35.online -uroot -p${set_root_password} < /app/schema/shipping.sql &>>${LOG}

      systemctl restart shipping &>>${LOG}

     fi
  fi
}



Nodejs() {

  print_head "Downloading Nodejs repo"
  curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>${LOG}
  status_check

  print_head "Installing Nodejs"
  yum install nodejs -y &>>${LOG}
  status_check

  APP_PREREQ

  print_head "Downloading Dependencies"
  cd /app
  npm install &>>${LOG}
  status_check

  print_head "Copying Systemd"
  cp ${script_location}/files/${component}.service /etc/systemd/system/${component}.service &>>${LOG}
  status_check

  SYSTEMD

  LOAD_SCHEMA
}

MAVEN() {
  print_head "Install Maven"
  yum install maven -y &>>${LOG}
  status_check

  APP_PREREQ

  cd /app &>>${LOG}

  print_head " Clean Package"
  mvn clean package &>>${LOG}
  status_check

  print_head "Moving Package"
  mv target/shipping-1.0.jar shipping.jar &>>${LOG}
  status_check

  cp ${script_location}/files/shipping.service /etc/systemd/system/shipping.service &>>${LOG}

  SYSTEMD

  LOAD_SCHEMA


}