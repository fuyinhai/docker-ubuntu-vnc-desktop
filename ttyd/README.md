docker build -t ubuntu:ttyd .

docker run -p 8080:8080 -e LAB_NAME=demo -v /etc/hosts:/etc/hosts -e USERNAME=demo -e PASSWORD=password123 ubuntu:ttyd
