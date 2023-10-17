kubectl delete -f echoserver-ingress.yaml

kubectl describe ing -n echoserver echoserver

kubectl delete -f https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.6.0/docs/examples/echoservice/echoserver-service.yaml
kubectl delete -f https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.6.0/docs/examples/echoservice/echoserver-deployment.yaml
kubectl delete -f https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.6.0/docs/examples/echoservice/echoserver-namespace.yaml

kubectl get -n echoserver deploy,svc
