{ config, pkgs, lib, ... }:
let
  domain = "homelab";
  ip = "192.168.1.2";
in
{
  services.k3s = {
    enable = true;
    role = "server";
    package = pkgs.k3s;
    extraFlags = [
      "--write-kubeconfig-mode=0644"
      "--disable=traefik"
      "--disable=servicelb"
      "--disable=metrics-server"
      "--disable=local-storage"
      "--disable=coredns"
      "--disable=flannel"
      "--cluster-init"
      "--cluster-cidr=10.42.0.0/16"
      "--service-cidr=10.43.0.0/16"
      "--flannel-backend=vxlan"
    ];
  };

  environment.variables = {
    KUBECONFIG = "/etc/rancher/k3s/k3s.yaml";
  };

  environment.shellInit = ''
    export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
  '';

  environment.shellAliases = {
    k = "kubectl";
  };

  environment.etc."k3s/coredns-custom.yaml" = {
    mode = "0750";
    text = ''
      apiVersion: v1
      kind: ConfigMap
      metadata:
        name: coredns-custom
        namespace: kube-system
      data:
        domain.server: |
          ${domain}:53 {
            errors
            health
            ready
            hosts {
              ${ip} ${domain}
              fallthrough
            }
            prometheus :9153
            forward . /etc/resolv.conf
            cache 30
            loop
            reload
            loadbalance
          }
    '';
  };

  environment.etc."k3s/coredns-deployment.yaml" = {
    mode = "0750";
    text = ''
      apiVersion: v1
      kind: Service
      metadata:
        name: kube-dns
        namespace: kube-system
        labels:
          k8s-app: kube-dns
          kubernetes.io/cluster-service: "true"
          kubernetes.io/name: "CoreDNS"
      spec:
        selector:
          k8s-app: kube-dns
        clusterIP: 10.43.0.10
        ports:
        - name: dns
          port: 53
          protocol: UDP
        - name: dns-tcp
          port: 53
          protocol: TCP
        - name: metrics
          port: 9153
          protocol: TCP
      ---
      apiVersion: apps/v1
      kind: Deployment
      metadata:
        name: coredns
        namespace: kube-system
        labels:
          k8s-app: kube-dns
      spec:
        replicas: 1
        selector:
          matchLabels:
            k8s-app: kube-dns
        template:
          metadata:
            labels:
              k8s-app: kube-dns
          spec:
            containers:
            - name: coredns
              image: coredns/coredns:1.11.1
              args:
              - -conf
              - /etc/coredns/Corefile
              ports:
              - containerPort: 53
                name: dns
                protocol: UDP
              - containerPort: 53
                name: dns-tcp
                protocol: TCP
              - containerPort: 9153
                name: metrics
                protocol: TCP
              volumeMounts:
              - name: config-volume
                mountPath: /etc/coredns
              resources:
                limits:
                  memory: 170Mi
                requests:
                  cpu: 100m
                  memory: 70Mi
              livenessProbe:
                httpGet:
                  path: /health
                  port: 8080
                  scheme: HTTP
                initialDelaySeconds: 60
                timeoutSeconds: 5
                successThreshold: 1
                failureThreshold: 5
              readinessProbe:
                httpGet:
                  path: /ready
                  port: 8181
                  scheme: HTTP
            volumes:
            - name: config-volume
              configMap:
                name: coredns
                items:
                - key: Corefile
                  path: Corefile
            dnsPolicy: Default
      ---
      apiVersion: v1
      kind: ConfigMap
      metadata:
        name: coredns
        namespace: kube-system
      data:
        Corefile: |
          .:53 {
              errors
              health
              ready
              kubernetes cluster.local in-addr.arpa ip6.arpa {
                pods insecure
                fallthrough in-addr.arpa ip6.arpa
                ttl 30
              }
              hosts /etc/coredns/NodeHosts {
                  ttl 60
                  reload 15s
                  fallthrough
              }
              prometheus :9153
              forward . /etc/resolv.conf
              cache 30
              loop
              reload
              loadbalance
          }
        NodeHosts: |
          ${ip} ${domain}
    '';
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/rancher/k3s/server/manifests 0755 root root -"
    "L /var/lib/rancher/k3s/server/manifests/00-coredns-custom.yaml - - - - /etc/k3s/coredns-custom.yaml"
    "L /var/lib/rancher/k3s/server/manifests/01-coredns-deployment.yaml - - - - /etc/k3s/coredns-deployment.yaml"
  ];
}
