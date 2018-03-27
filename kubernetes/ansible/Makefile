.PHONY: run kubernetes
build:
# Provisioning Compute Resources
	 cd ~/rastamalik_microservices/kubernetes/ansible/
# 1. Networking and firewall
	 @ansible-playbook net.yml
#	 2. Create instances
	 @ansible-playbook instance.yml
#	3. Provisioning a CA and Generating TLS Certificates
# 4. Generating Kubernetes Configuration Files for Authentication
# 5.  Generating the Data Encryption Config and Key
	 cd template/; bash sert.sh
# 6. Bootstrapping the etcd Cluster
	 @ansible-playbook boots.yml
# 7. 	Bootstrapping the Kubernetes Control Plane
	 @ansible-playbook kube.yml
# 8. The Kubernetes Frontend Load Balancer
	 cd template/; bash load_balancer.sh
# 9. 	Bootstrapping the Kubernetes Worker Nodes
	 cd ~/rastamalik_microservices/kubernetes/ansible
	 @ansible-playbook worker.yml
# 10. 	Configuring kubectl for Remote Access
	 cd template/; bash kubectl.sh
# 11. Provisioning Pod Network Routes
	 bash pod_networks.sh
