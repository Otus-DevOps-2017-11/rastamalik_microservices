#!/bin/bash


  cat > 10-bridge.conf <<EOF
  {
      "cniVersion": "0.3.1",
      "name": "bridge",
      "type": "bridge",
      "bridge": "cnio0",
      "isGateway": true,
      "ipMasq": true,
      "ipam": {
          "type": "host-local",
          "ranges": [
            [{"subnet": "${POD_CIDR}"}]
          ],
          "routes": [{"dst": "0.0.0.0/0"}]
      }
  }
EOF
cat > 99-loopback.conf <<EOF
{
    "cniVersion": "0.3.1",
    "type": "loopback"
}
EOF
for HOSTNAME in worker-0 worker-1 worker-2; do
sudo mv 10-bridge.conf 99-loopback.conf /etc/cni/net.d/
sudo mv /root/${HOSTNAME}-key.pem /root/${HOSTNAME}.pem /var/lib/kubelet/
sudo mv /root/${HOSTNAME}.kubeconfig /var/lib/kubelet/kubeconfig
sudo mv /root/ca.pem /var/lib/kubernetes/
done
HOSTNAME="`cat /etc/hostname`"
cat > kubelet.service <<EOF
[Unit]
Description=Kubernetes Kubelet
Documentation=https://github.com/kubernetes/kubernetes
After=cri-containerd.service
Requires=cri-containerd.service

[Service]
ExecStart=/usr/local/bin/kubelet \\
  --allow-privileged=true \\
  --anonymous-auth=false \\
  --authorization-mode=Webhook \\
  --client-ca-file=/var/lib/kubernetes/ca.pem \\
  --cloud-provider= \\
  --cluster-dns=10.32.0.2 \\
  --cluster-domain=cluster.local \\
  --container-runtime=remote \\
  --container-runtime-endpoint=unix:///var/run/cri-containerd.sock \\
  --image-pull-progress-deadline=2m \\
  --kubeconfig=/var/lib/kubelet/kubeconfig \\
  --network-plugin=cni \\
  --pod-cidr=${POD_CIDR} \\
  --register-node=true \\
  --runtime-request-timeout=15m \\
  --tls-cert-file=/var/lib/kubelet/${HOSTNAME}.pem \\
  --tls-private-key-file=/var/lib/kubelet/${HOSTNAME}-key.pem \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

sudo mv /root/kube-proxy.kubeconfig /var/lib/kube-proxy/kubeconfig
cat > kube-proxy.service <<EOF
[Unit]
Description=Kubernetes Kube Proxy
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-proxy \\
  --cluster-cidr=10.200.0.0/16 \\
  --kubeconfig=/var/lib/kube-proxy/kubeconfig \\
  --proxy-mode=iptables \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
sudo mv kubelet.service kube-proxy.service /etc/systemd/system/
