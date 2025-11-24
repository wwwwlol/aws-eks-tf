# Install Rancher on EKS 

##### Install HELM CLI
```ssh
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3$ 
chmod 700 get_helm.sh$ 
./get_helm.sh
```
##### Install Ingress NGINX Controller as a NLB service
```ssh
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \ 
--namespace ingress-nginx \ 
--create-namespace \ 
--version 4.6.0 \ 
--set controller.service.type=LoadBalancer \ 
--set controller.service.annotations."service\.beta\.kubernetes\.io/aws-load-balancer-type"=nlb \ 
--set controller.service.annotations."service\.beta\.kubernetes\.io/aws-load-balancer-backend-protocol"=tcp
```
#### Check LB service is created
```
kubectl get svc ingress-nginx-controller -n ingress-nginx \ -o jsonpath='{.status.loadBalancer.ingress[0].hostname}{"\n"}{.status.loadBalancer.ingress[0].ip}{"\n"}' \ | grep -v '^$' | head -1
```
#### Create route 53 address in hosted zone
```
# 1. Get NLB DNS
NLB_DNS=$(kubectl get svc ingress-nginx-controller -n ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

# 2. Replace values
HOSTED_ZONE_ID="<>"  
SUBDOMAIN="<>"

aws route53 change-resource-record-sets \
  --hosted-zone-id $HOSTED_ZONE_ID \
  --change-batch "{
    \"Comment\": \"Auto-created for EKS Ingress\",
    \"Changes\": [{
      \"Action\": \"UPSERT\",
      \"ResourceRecordSet\": {
        \"Name\": \"$SUBDOMAIN\",
        \"Type\": \"A\",
        \"AliasTarget\": {
          \"HostedZoneId\": \"Z35SXDOTRQ7X7K\",
          \"DNSName\": \"$NLB_DNS\",
          \"EvaluateTargetHealth\": false
        }
      }
    }]
  }"
  ```

### Install Certmanager
```

# Add the Jetstack Helm repository
helm repo add jetstack https://charts.jetstack.io

# Update your local Helm chart repository cache
helm repo update

# Install the cert-manager Helm chart
helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --set crds.enabled=true
```
### Install Rancher
```
helm repo add rancher-stable https://releases.rancher.com/server-charts/stable
helm repo update
```
```
kubectl create ns cattle-system
```

```
helm install rancher rancher-stable/rancher \  
--namespace cattle-system \  
--set hostname=$NLB_DNS \  
--set bootstrapPassword=admin \
--set ingress.ingressClassName=nginx
```
### Check Rancher pod status
```
kubectl rollout status deployment rancher -n cattle-system
```
