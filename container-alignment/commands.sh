docker-compose up -d

docker container exec -it manager docker swarm init
docker container exec -it worker01 docker swarm join --token "token here"

docker container exec -it manager docker node ls # show manager and 3 workers

docker image tag example/echo:latest localhost:5000/example/echo:latest # [the registry host to push/]repository[:tag]
docker image push localhost:5000/example/echo:latest # push to the registry on localhost

docker container exec -it worker01 docker image pull registry:5000/example/echo:latest # pull image from registry because dind cannot pull from host
docker container exec -it worker01 docker image ls

# FYI: "service" is the group of container
docker container exec -it manager docker service create --replicas 1 --publish 8000:8080 --name echo registry:5000/example/echo:latest

docker container exec -it manager docker service ls
docker container exec -it manager docker service scale echo=6 # scale out
docker container exec -it manager docker service ps echo | grep Running # check if scale out succeed
docker container exec -it manager docker service rm echo # remove service by service name

# stack is the group of services
#   kind of compose, which enable scale in/scale out and constraint on swarm
# put services in same network to enable connection between services => use overlay
docker container exec -it manager docker network create --driver=overlay --attachable ch03
docker container exec -it manager docker stack deploy -c /stack/ch03-webapi.yml echo
docker container exec -it manager docker stack services echo # make sure if the deployment succeeded

docker container exec -it manager docker stack ps echo

# visualize the containers alignments http://localhost:9000
docker container exec -it manager docker stack deploy -c /stack/visualizer.yml visualizer

docker container exec -it manager docker stack rm echo # remove stack including services by stach name

# add "stack/ch03-ingress.yml"
docker container exec -it manager docker stack deploy -c /stack/ch03-webapi.yml echo

# check if all of replicas are working ok
docker container exec -it manager docker service ls

curl http://localhost:8000