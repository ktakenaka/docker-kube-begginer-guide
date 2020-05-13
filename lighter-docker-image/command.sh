docker image build -t ch09/hello:lates .
# このtagの管理地味に大事なんやろなあ
# Goみたいなシングルバイナリのアプリケーションをそのままコンテナに含めるようなケースでは、依存ライブラリをstatic linkとしてビルドさえすればイメージを作る手間がかなりはぶける
# rubyみたいな言語では無理ってことか

GOOS=linux GOARCH=amd64 go build hello.go

curl -O https://curl.haxx.se/ca/cacert.pem

# scrachは最小のベースイメージだけど、shすらないので、必要なミドルウエアのビルドとか考えるとwebアプリケーションで使うのは非現実的
# BusyBoxは組み込みでよく使われているLinuxのディストリビューション、サイズが小さいのが特徴
docker container run -it busybox sh

# === commands in container ===
ls -lh busy*

# BusyBoxは小さいけど、パッケージマネージャが含まれていないので使い勝手が良くはない
# サイズを問われないビルドの手間がかかるときは、UbuntuやCentOSでおけ、AlpineLinuxも

# Alpine LinuxはBusyBoxベースのディストリビューションで、apkが入っている
docker container run -it alpine:3.7 sh

# === commands in container ===
apk update
apk search node
apk add nodejs
apk add --no-cache --virtual=build-deps ruby-dev perl-dev
apk del --no-cache build-deps

docker image build -t ch09/hello:alpine --file Dockerfile-alpine .
docker container run -p9000:8080 tmp

# dockerはLayer構造になっていて、各Layerがtar.gzファイルで保存されている=>ある時点までのイメージが使える
docker image build -t ch09/entrykit:standard --file Docker-standard .
docker image ls | grep entrykit | grep standard
docker image history ch09/entrykit:standard

# 実務的には、初めはRUNをたくさん書いておいて、差分ビルドの恩恵をうける、固まってからつなげる
# たくさんRUNがあるような場合以外は使わないのが賢明
docker image build --file Docker-light -t ch09/entrykit:light .

# multi stage buildではFROMを複数かけて、ASで指定したタグで `--from=タグ名` みたいにして、ビルドコンテナと実行コンテナを分けられる