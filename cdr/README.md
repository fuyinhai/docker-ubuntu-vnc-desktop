docker build -t ubuntu:cdr .

docker run -p 8080:8080 -e LAB_NAME=demo -e USERNAME=demo -e PASSWORD=password123 -v $(PWD):/root/workspace ubuntu:cdr
