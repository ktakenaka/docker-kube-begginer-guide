curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/darwin/amd64/kubectl"
chmod +x ./kubectl
mv ./kubectl /usr/local/bin/kubectl
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v1.8.3/src/deploy/recommended/kubernetes-dashboard.yaml
kubectl get pod --namespace=kube-system -l k8s-app=kubernetes-dashboard
kubectl proxy
kubectl get nodes
kubectl get namespace
kubectl apply -f simple-pod.yml
kubectl delete pod simple-echo

# replica set is a unit of a group of containers
#   it defines the number of replicas and template (group of container)
kubectl apply -f simple-replicaset.yaml
kubectl delete -f simple-replicaset.yaml

# difference of files are `kind`.
# we can mange genearations in the case of deployment, it's different from ReplicaSet
# Deployment is literally a unit of "デプロイ"
# DeploymentはたぶんReplicasetを新しく交換することで世代管理してるんじゃないかな
kubectl apply -f simple-deployment.yaml --record
kubectl get pod,replicaset,deployment --selector app=echo

# deployのrevisionを確認 => Revision
kubectl rollout history deployment echo

# rollback to the previous revision
kubectl rollout history deployment echo --revision=1

# rollbackの取り消し
kubectl rollout undo deployment echo

# serviceの検証のためにReplicaSetを作成
# release tagで管理する
kubectl apply -f simple-replicaset-with-lable.yaml
kubectl get pod -l release=spring
kubectl get pod -l release=summer

# serviceはPodの集合に対する経路やサービスディスカバリを提供するリソース
# ReplicaSetのmetadataで定義したapp/releaseをつかう
# kubectl ってyamlのkindで何を定義しているのかしてすれば、あとは共通でapplyだから簡単だな
kubectl apply -f simple-service.yaml

# Podではなく、Serviceなのでsvc
kubectl get svc echo

# Serviceはクラスタ内からしかアクセスできない
# クラスタ内に一時的にデバックコンテナを作る
kubectl run -i --rm --tty debug --image=gihyodocker/fundamental:0.1.0 --restart=Never -- bash -il

kubectl logs -f echo-summer-kv4r8 -c echo

# Pod同士のやりとりは、Serviceを介して、名前解決をして行う
# NodePortServiceはクラスタ外からアクセス可能
#   *NodePortでは実際の運用には不十分なので、ingressを使う
#   NodePort => L4, Ingress => L7
kubectl apply -f simple-service.yaml
kubectl get svc # localからアクセスする場合のPort番号確認
curl http://127.0.0.1:30891

# ingressのリソース作成
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/nginx-0.16.2/deploy/mandatory.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/nginx-0.16.2/deploy/provider/cloud-generic.yaml

kubectl apply -f simple-ingress.yaml
kubectl get ingress

# fresh podを使うことで、イメージの更新を検知してPodを自動更新してくれる
#   つまりは docker image build -t `name` で更新されたら、Podを入れ替えにいく
kubectl apply -f https://raw.githubusercontent.com/kubernetes/minikube/ec1b443722227428bd2b23967e1b48d94350a5ac/deploy/addons/freshpod/freshpod-rc.yaml
