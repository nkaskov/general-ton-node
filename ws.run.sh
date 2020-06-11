docker volume create ton-rocks-ws-db
docker run --name ton-rocks-ws0 --mount source=ton-rocks-ws-db,target=/var/ton-work/db --network host -it ton-rocks-ws


