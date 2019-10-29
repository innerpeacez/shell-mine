#!/bin/bash

# Add istio official repo
add_repo(){
  VERSION=$1
  REPO="https://storage.googleapis.com/istio-release/releases/${VERSION}/charts/"
  helm repo add istio $REPO

  STATUS_CMD=`echo $?`
  CHECK_REPO_CMD=`helm repo list | grep $REPO | wc -l`
  echo "$STATUS_CMD"
  echo "$CHECK_REPO_CMD"
  while [[ $STATUS_CMD != 0 && $CHECK_REPO_CMD -ge 1 ]]
  do
    sleep 5
    helm repo add istio $REPO

    STATUS_CMD=`echo $?`
    CHECK_REPO_CMD=`helm repo list | grep $REPO | wc -l`
  done
}

# Create istio-system namespace
create_namespace() {
  NAMESPACE=$1
  kubectl create ns ${NAMESPACE}

  STATUS_CMD=`echo $?`
  while [[ $STATUS_CMD != 0 ]]
  do
    sleep 5
    kubectl create ns ${NAMESPACE}
    STATUS_CMD=`echo $?`
  done
}

# Create CRD need for istio
create_crd() {
  NAMESPACE=$1
  helm install istio-init istio/istio-init -n ${NAMESPACE}
  CRD_COUNT=`kubectl get crds | grep 'istio.i' | wc -l`

  while [[ ${CRD_COUNT} != 23 ]]
  do
    sleep 5
    CRD_COUNT=`kubectl get crds | grep 'istio.io' | wc -l`
  done

  echo 'Istio crd create successful'
}

# Deploy istio related components
deploy_istio() {
  NAMESPACE=$1
  VERSION=$2
  helm install istio istio/istio -n ${NAMESPACE}

  check() {
     kubectl -n ${NAMESPACE}  get deploy | grep istio | awk '{print "deployment/"$1}' | while read line ;
     do
       kubectl rollout status $line -n ${NAMESPACE};
     done
  }
  check

  echo "Istio is deployed successful"
}

main(){
  ISTIO_VERSION="1.3.3"
  ISTIO_NAMESPACE="istio-system"
  add_repo $ISTIO_VERSION
  if [[ `kubectl get ns | grep $ISTIO_NAMESPACE | wc -l ` == 0 && `kubectl get ns $ISTIO_NAMESPACE | grep -v NAME | wc -l` == 0 ]] ;then
    create_namespace $ISTIO_NAMESPACE
  fi
  create_crd $ISTIO_NAMESPACE
  deploy_istio $ISTIO_NAMESPACE $ISTIO_VERSION
}

main