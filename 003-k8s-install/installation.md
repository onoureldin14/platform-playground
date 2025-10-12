# 🛠️ Kubernetes Cluster Installation Commands

This file contains all the key commands used in **Platform Playground – Episode 2** to manually install a Kubernetes cluster using `kubeadm` on AWS EC2.

---

## ✅ Step 1 – Install Container Runtime (containerd)

```bash
# Update and install dependencies
sudo apt-get update && sudo apt-get install -y \
    curl gnupg2 software-properties-common apt-transport-https ca-certificates

# Install containerd
sudo apt-get install -y containerd

# Generate default config
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml > /dev/null

# Enable and start the service
sudo systemctl enable containerd
sudo systemctl restart containerd
sudo systemctl status containerd
```

---

## ✅ Step 2 – Install Kubelet, Kubeadm, Kubectl (v1.34)

```bash
# Update and install required packages
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gpg

# Create keyring directory (if needed)
sudo mkdir -p -m 755 /etc/apt/keyrings

# Add GPG key
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.34/deb/Release.key | \
  sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# Add Kubernetes apt repo
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] \
  https://pkgs.k8s.io/core:/stable:/v1.34/deb/ /" | \
  sudo tee /etc/apt/sources.list.d/kubernetes.list > /dev/null

# Install components
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# Enable kubelet service
sudo systemctl enable --now kubelet
```

---

## 🔧 Step 3 – Pre-Cluster Config

```bash
# Disable memory swap
sudo swapoff -a

# Make it permanent
sudo sed -i '/ swap / s/^/#/' /etc/fstab

# Enable IP forwarding
sudo sysctl -w net.ipv4.ip_forward=1

# Persist the setting
echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# Optional: Set /etc/hosts for name resolution
sudo nano /etc/hosts
# Example entry:
# 192.168.1.100 master-node
```

---

## 🚀 Step 4 – Initialize the Control Plane

```bash
sudo kubeadm init
```

> This creates:
> - Static pod manifests in `/etc/kubernetes/manifests`
> - TLS certificates in `/etc/kubernetes/pki`
> - Cluster configuration in `/etc/kubernetes`

---

## 🔑 Step 5 – Configure kubectl Access

```bash
# Copy kubeconfig to default user path
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# OR export KUBECONFIG directly (temporary)
export KUBECONFIG=/etc/kubernetes/admin.conf
```

---

✅ You now have a working Kubernetes master node ready for worker nodes to join!