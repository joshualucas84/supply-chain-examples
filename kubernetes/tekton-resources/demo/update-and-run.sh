#kubectl apply -f admission-control-verify-image.yaml
#kubectl apply -f gatekeeper-signing-checker-resources.yaml
#kubectl apply -f gatekeeper-signing-checker.yaml
#kubectl apply -f gatekeeper-constraints-template.yaml
#kubectl apply -f gatekeeper-constraints.yaml
#kubectl apply -f kaniko-with-cosign.yaml
#kubectl apply -f pipeline.yaml
#kubectl create -f pipeline-run.yaml
#!/usr/bin/env bash
set -u
set -e

remove_old_helm_charts(){
    rm gatekeeper-demo-*.tgz || true
}


remove_old_template_charts() {
    kubectl delete -f gatekeeper-constraints-template.yaml || true
    kubectl delete -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/master/demo/basic/templates/k8srequiredlabels_template.yaml || true
}

build_charts() {
    helm package . --debug
}

install_new_charts() {
    ## Install gatekeeper helm charts
    kubectl apply -f gatekeeper-constraints-template.yaml || true
    kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/master/demo/basic/templates/k8srequiredlabels_template.yaml || true
    ## Install
    helm install -f values.yaml gatekeeper-demo-*.tgz --generate-name || true
}


main(){
    remove_old_helm_charts "$@"
    remove_old_template_charts "$@"
    build_charts "$@"
    install_new_charts "$@"
    remove_old_helm_charts "$@"
}

main "$@"
