# infos

ip: 
  192.168.50.4

# commands

```bash
sudo snap install microk8s --classic
sudo ufw allow in on cni0 && sudo ufw allow out on cni0
sudo ufw default allow routed
# add additional services
sudo microk8s enable dns dashboard storage
# check the deployment progress
microk8s kubectl get all --all-namespaces
#get dashboard access token
token=$(sudo microk8s kubectl -n kube-system get secret | grep default-token | cut -d " " -f1)
sudo microk8s kubectl -n kube-system describe secret $token
# expose dashboard port to 8443
sudo microk8s kubectl port-forward -n kube-system service/kubernetes-dashboard --address 0.0.0.0 8443:443

# create a new deployment
microk8s kubectl create deployment microbot --image=dontrebootme/microbot:v1
microk8s kubectl scale deployment microbot --replicas=2
# expose it through a service
microk8s kubectl expose deployment microbot --type=NodePort --port=80 --name=microbot-service

#microk8s commands
#https://ubuntu.com/tutorials/install-a-local-kubernetes-with-microk8s#6-integrated-commands

```


salt:

sudo salt "*" cmd.run "snap install microk8s --classic"
sudo salt "h0" cmd.run  "microk8s enable dns dashboard storage" env='{"LC_ALL":"C.UTF-8", "LANG":"C.UTF-8"}'
sudo salt "*" cmd.run  "microk8s enable dns storage" env='{"LC_ALL":"C.UTF-8", "LANG":"C.UTF-8"}'
IP=$( ip -f inet addr show eth1 | sed -En -e 's/.*inet ([0-9.]+).*/\1/p' )

readarray -t MINIONS <<< $(sudo salt-run manage.up |grep -v "h0" |sed -En "s/^- (.*)$/\1/p");
for minion in "${MINIONS[@]}"
do
   : 
   JOIN_URL=$(sudo microk8s add-node -l 9999 -t $(uuidgen |tr -d "-")|grep $IP)
   sudo salt "$minion" cmd.run "$JOIN_URL" &
done

token=$(sudo microk8s kubectl -n kube-system get secret | grep default-token | cut -d " " -f1)
sudo microk8s kubectl -n kube-system describe secret $token

sudo microk8s kubectl port-forward -n kube-system service/kubernetes-dashboard --address 0.0.0.0 8443:443 &