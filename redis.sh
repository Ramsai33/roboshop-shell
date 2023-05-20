source common.sh

print_head "Download Repo"
yum install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y
status_check

print_head "disable REPo"
yum module enable redis:remi-6.2 -y
status_check

print_head "Install Redis"
yum install redis -y
status_check

print_head "Changing Port"
sed -i -e 's/127.0.0.1/0.0.0.0/gi' /etc/redis.conf /etc/redis/redis.conf
status_check

print_head "Starting Service"
systemctl enable redis
systemctl start redis
status_check