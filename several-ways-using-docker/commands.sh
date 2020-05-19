docker image build --file Dockerfile-redis -t ch10/workspace:latest .
docker container run --rm --name workspace -it ch10/workspace:latest bash

# vagrantからDockerには必ずしも移行すべきではない、現状Vgrantで安定して動いているならDockerの必要なし

# hadolintでDockerの書式を検査できる
docker container run --rm -i hadolint/hadolint < Dockerfile-hadolint

docker image build --file Dockerfile-cli-version -t ch10/jq:latest .
 echo '{"version":100}' | docker container run -i --rm ch10/jq:1.5 '.version'

# aliasにして特定のunixコマンドが入ったDocker containerをrunする。これはうまく使うと便利そう
 alias jq1.5='docker container run -i --rm ch10/jq:1.5'

# CLIツールを導入することで、ホストの安定版・開発版みたいに管理できるようになる。
# 以前の依存ライブラリやツールのバージョン管理などが難しかった問題点を解決している
docker image build --file Dockerfile-shell -t ch10/show-attr:latest .
docker container run ch10/show-attr:latest username
docker container run ch10/show-attr:latest

# swarmの環境を作り直す
# ちなみにregistry, manager, worker * 3の構成
docker compose up
docker container exec -it worker01 docker swarm join --token "token"
docker container exec -it manager docker network create --driver=overlay --attachable loadtest
docker container exec -it manager docker stack deploy -c /stack/ch10-target.yml target

# 動かなかったので、dockerの中間イメージにshしてdebug
docker image ls --all

# Locustは負荷テストツール。複数ホストを利用した分散実行にも対応している
docker image build --file Dockerfile-locust -t ch10/locust:latest .

# 対象のimageにtag付け
docker image tag ch10/locust:latest localhost:5000/ch10/locust:latest
docker image push localhost:5000/ch10/locust:latest

# ENTRYPOINTに設定されているコマンドが実行される
# この場合はserviceの設定ファイルで、"-f scenario.py -H http://target_echo:8080"を指定しているので "/usr/local/bin/locust -f scenario.py -H http://target_echo:8080"が実行されるdocker
docker container exec -it manager docker stack deploy -c /stack/ch10-locust.yml locust

# multiコンテナからの負荷テストの前に上で作ったstackを消す
docker container exec -it manager docker stack rm locust
docker container exec -it manager docker stack deploy -c /stack/ch10-locust-multi.yml locust