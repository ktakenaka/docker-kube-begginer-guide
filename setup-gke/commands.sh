gcloud init
gcloud config set compute/zone asia-northeast1-a
gcloud container clusters create gihyo --cluster-version=1.15.11-gke.3 --machine-type=n1-standard-1 --num-nodes=3
gcloud container clusters get-credentials gihyo
kubectl get nodes

# 以下でMySQLのMaster-Slaveを定義していく
# StorageClassはPersistentVolumeが確保するストレージの種類を定義できるリソース（たとえば、SSDとか）
# PersistentVolumeとは永続化したいリソース
kubectl apply -f storage-class-ssd.yaml

# StatefulSetはデータストアとか、継続的にデータを永続化するステートフルなアプリの管理に使う
# DeploymentではPodを作成するときに、それぞれのPodにランダムな識別子をつけるが、StatefullSetの場合には、連番で一意な識別子をつけて、Podを再作成しても保たれる => ステートフル
kubectl apply -f mysql-master.yaml

# 中で "mysql-master" とか "mysq-slave" のlabelをつかって代入している
kubectl apply -f todo-api.yaml

# エラーが起きて、deployできない...
kubectl logs $(kubectl get pods -l app=todoapi | grep todoapi | awk '{print $1}' | head -n 1) -c api

# volumeMountを使って、nginxとnuxtの間でvolumeを共有して、nginxから静的ファイルを直接配信できるようにしている
# その際に、nuxtで共有したいファイルを、"postStart" を使うことで、vokumeMountで指定したパスにコピーしている
kubectl apply -f todo-web.yaml

kubectl apply -f ingress.yaml
kubectl get ingress