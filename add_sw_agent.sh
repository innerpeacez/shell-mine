ignore=$2
namespace=$1

add_agent_sw(){
    kubectl -n cloud-native get deploy | grep -vE $ignore | awk '{print $1}' |while read po 
    do
        patch_init_contaniner $po
        add_contaniner_mount $po
        patch_mount $po 
    done
}

patch_init_contaniner() {
    po=$1
    kubectl -n $namespace patch deployment $po --patch "$(cat init_contanier.yaml)"
}

add_contaniner_mount() {
    po=$1

    kubectl -n $namespace get deployment $po -oyaml | sed "/        imagePullPolicy:/a\        volumeMounts:\n        - mountPath: /usr/skywalking/agent\n          name: sw-agent" | sed "/name: JAVA_OPTS/{n;d}" | sed "/-Dskywalking.collector.backend_service=skywalking-skywalking-oap:11800/d" | sed "/name: JAVA_OPTS/a\          value: -Xmx1024m -javaagent:/usr/skywalking/agent/skywalking-agent.jar -Dskywalking.agent.service_name=$po -Dskywalking.collector.backend_service=skywalking-skywalking-oap:11800"  > tmp.yaml;

}

create_init_container_yaml() {
cat > ./init_contanier.yaml <<EOF
spec:
  template:
    spec:
      initContainers:
      - image: innerpeacez/sw-agent-sidecar:latest
        name: sw-agent-sidecar
        imagePullPolicy: IfNotPresent
        command: ['sh']
        args: ['-c','mkdir -p /skywalking/agent && cp -r /usr/skywalking/agent/* /skywalking/agent']
        volumeMounts:
        - mountPath: /skywalking/agent
          name: sw-agent
      volumes:
      - name: sw-agent
        emptyDir: {}
EOF
}

patch_mount(){
    po=$1
    kubectl -n $namespace patch deployment $po --type merge --patch "$(cat tmp.yaml)"
}

main(){
    create_init_container_yaml
    add_agent_sw
    rm -rf tmp.yaml init_contanier.yaml
}

main

