#!/bin/bash
set -ex

# Redirect all output to log file for easy debugging
exec > /var/log/cloudvault-userdata.log 2>&1

echo "=== CloudVault User Data Started at $(date) ==="

# -----------------------------
# VARIABLES FROM TERRAFORM
# -----------------------------
APP_NAME="cloudvault"
DOCKER_IMAGE="amitgiri13/cloudvault:3.0.1" # demo app image
APP_DIR="/home/ec2-user/app"
CONTAINER_NAME="cloudvault"

# These will be replaced by Terraform automatically
DB_HOST="${db_host}"
DB_NAME="${db_name}"
DB_USER="${db_user}"
DB_PASSWORD="${db_pass}"
DB_PORT="${db_port}"
ALB_DNS="${alb_dns}"

# Replace these variables (optional)
AWS_STORAGE_BUCKET_NAME=cloud-vault-bucket-cloud-storage
AWS_S3_REGION_NAME=us-east-1
AWS_ACCESS_KEY_ID=ASIA5Hxxxxxxxxxxxxxxxxxxxxxxxxxxx
AWS_SECRET_ACCESS_KEY=51ODJoxxxxxxxxxxxxxxxxxxxxxxxxx
AWS_SESSION_TOKEN=IQoJb3JxxxpZ2luX2VjxxxxxxxxxxEAaCXVzLXdlc3QtMiJGMEQCIAqOjBLuc15cP0cXO16+NdLONuEFGNejh7A1VUCrf5WaAiAjDdRUQFawxLFM0t44A6v6a1vQYylUqTEA0uZXw91OtyqqAggJEAEaDDkxMDAzMzM3NTA1OCIM+LktaUifqeUrPSoNKocCCFOwngfmGOGoQFg8fPdPXFtHJEJmRbsDPVrJ5+CBAk/IfWgFHbbrblpTSjg8YmVMqOS6qtf7SW6/P27lsgbopuEhgi4G/VuIK/4wsb7pcFBrnrdyf3i/lRySGPLCY7bhJmDP9Wlbm3JjtcAUjKvIbbsoYiUSqkctvVv6n42ipFj2tC7oxkshkzeyPVMl1rKgyWb++hyq9JQgX3KLaW7IsBpAlTHJ0Pzls+9tTPOmJLRhZVVEDhET3gG+QV70pr53zQaHBFasdqdmnf9ez/BIkTD3JBSJR9vRIH1HkymsltFP66LkSl+YIKhElAwNuTJQn77trcw+3/H59ItsIutVs2/VDxBJ0gw+cb6zAY6ngF7DicOKt2NnylQvBKInfnH1cbyUjYUk6B1OB51kdzNw0+8uUggZblVOA7i8a48dWqn2eN/mTXsltariMXlwxfkEfnMQSg83UGi1AH98W0bBS3KDN41mYgJd1iVBzQNlL9UdWK5+lQwuEoeq6kDQfn+G96D4DOd2+RuY/pPAzokgd75GWErTcC4vEUGR1dLZxg9Rn2qDHQ1xUhI1QLnvw==
MAX_UPLOAD_SIZE_MB=100

# Replace with your domains
DOMAIN_1=freemaa.com
DOMAIN_2=www.freemaa.com

# -----------------------------
# SYSTEM SETUP
# -----------------------------
yum update -y

# Install Docker (Amazon Linux 2 way)
amazon-linux-extras install docker -y

systemctl enable docker
systemctl start docker

# Wait for Docker daemon
sleep 10



# -----------------------------
# APP DIRECTORY & .env FILE
# -----------------------------
mkdir -p "$APP_DIR"
cd "$APP_DIR"

cat <<EOF > .env
SECRET_KEY=change-me-in-production
DEBUG=False
ALLOWED_HOSTS=$ALB_DNS,$DOMAIN_1,$DOMAIN_2
DB_NAME=$DB_NAME
DB_USER=$DB_USER
DB_PASSWORD=$DB_PASSWORD
DB_HOST=$DB_HOST
DB_PORT=$DB_PORT
AWS_STORAGE_BUCKET_NAME=$AWS_STORAGE_BUCKET_NAME
AWS_S3_REGION_NAME=$AWS_S3_REGION_NAME
AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN
MAX_UPLOAD_SIZE_MB=$MAX_UPLOAD_SIZE_MB
EOF

# -----------------------------
# DOCKER  RUN
# -----------------------------
echo "Pulling Docker image..."
docker pull "$DOCKER_IMAGE"

echo "Starting container..."
docker run -d \
  --name "$CONTAINER_NAME" \
  -p 80:8000 \
  --env-file "./.env" \
  --restart unless-stopped \
  "$DOCKER_IMAGE"

# Wait for container to start
sleep 20

# -----------------------------
# RUN DJANGO COMMANDS
# -----------------------------
echo "Running migrations..."
docker exec "$CONTAINER_NAME" python manage.py makemigrations --noinput || true
docker exec "$CONTAINER_NAME" python manage.py migrate --noinput

echo "Collecting static files..."
docker exec "$CONTAINER_NAME" python manage.py collectstatic --noinput --clear

echo "=== Deployment completed successfully at $(date) ==="
echo "Container status:"
docker ps | grep "$CONTAINER_NAME"