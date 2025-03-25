# **Deploying an Application to Amazon EKS using GitHub Actions CI/CD**

## **Overview**
This project demonstrates a **CI/CD pipeline** using **GitHub Actions** to deploy a **containerized application** to **Amazon EKS (Elastic Kubernetes Service)**. The deployment process is automated with **Terraform, Docker, and Kubernetes**, ensuring a streamlined **DevOps workflow**.

![image](https://github.com/user-attachments/assets/92e9172d-dae0-46c5-8e55-0c14cf3936ee)


![image](https://github.com/user-attachments/assets/d12c6a8c-f94e-43fd-bc6a-1821d907c46c)



## **🚀 Features**
- **Automated CI/CD Pipeline** using **GitHub Actions**
- **Infrastructure as Code (IaC)** using **Terraform**
- **Secure containerization** with **Docker & Amazon ECR**
- **Kubernetes Deployment** on **AWS EKS**
- **External Access** using **Nginx Ingress & DuckDNS**
- **Security Scanning** using **Trivy**

---

## **🛠️ Prerequisites**
Ensure the following tools are installed on your system:
- **Terraform**
- **AWS CLI**
- **Kubectl**
- **Docker**

### **Install Terraform, AWS CLI, and Kubectl**
```bash
# Update and upgrade system packages
sudo apt update && sudo apt upgrade -y

# Install Terraform
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install -y terraform

# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Install Kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo chmod +x kubectl
sudo mv kubectl /usr/local/bin/
```
Verify installations:
```bash
terraform version
aws --version
kubectl version --client
```

---

## **⚡ Setting Up the GitHub Repository**
### **Fork the Repository (Recommended)**
1. Go to: [GitHub Repository](https://github.com/sandeepkalathil/githubactions-eks)
2. Click **Fork**
3. Clone it locally:
   ```bash
   git clone https://github.com/<your-github-username>/githubactions-eks.git
   cd githubactions-eks
   ```

### **Alternative: Clone and Push to a New Repo**
```bash
git clone https://github.com/sandeepkalathil/githubactions-eks.git
cd githubactions-eks
git remote remove origin
git remote add origin https://github.com/<your-username>/new-repo.git
git push -u origin main
```

### **Generate a GitHub Token**
1. Go to **GitHub → Developer Settings → Personal Access Tokens**
2. Generate a new token with the following scopes:
   - ✅ `repo` → Full repository access
   - ✅ `workflow` → Allows updating workflows
3. Copy the token and update your repository:
   ```bash
   git remote set-url origin https://USERNAME:TOKEN@github.com/USERNAME/REPO.git
   ```

---

## **🌍 Deploying Infrastructure with Terraform**
```bash
cd terraform/
terraform init
terraform plan
terraform apply
```
Save the Terraform output for later use.

---

## **🔗 Setting Up Ingress for External Access**
Navigate to `terraform-ingress/nginx-ingress.yaml` and update:
- `host`
- `cluster_ca_certificate` (from Terraform output)

Run the following commands:
```bash
terraform init
terraform plan
terraform apply
```

---

## **🔐 Adding Secrets to GitHub Actions**
Go to **GitHub → Repository Settings → Secrets and Variables → Actions**

| Name | Value |
|------|-------|
| `AWS_REGION` | `eu-north-1` |
| `AWS_ROLE_ARN` | `arn:aws:iam::794038256791:role/GitHubActionsECRRole` |
| `ECR_REPOSITORY` | `freshfarm-repo` |
| `EKS_CLUSTER_NAME` | `Freshfarm-cluster` |

### **Update IAM Role Trust Policy**
Go to **AWS IAM → Roles → GitHubActionsECRRole** and update the trust policy.

---

## **🚀 Running the Deployment Workflow**
```bash
aws eks update-kubeconfig --region eu-north-1 --name Freshfarm-cluster
kubectl get nodes
```

### **Manually Map IAM Role to Kubernetes RBAC**
```bash
kubectl get configmap aws-auth -n kube-system -o yaml
kubectl apply -f aws-auth.yaml
```

---

## **📦 Running GitHub Actions CI/CD**
Once everything is set up, **trigger the GitHub Actions workflow** to deploy the application. The workflow will:
1. **Build & Push Docker Image** to Amazon ECR
2. **Deploy Application to EKS**
3. **Apply Kubernetes Service & Ingress**

### **Verify the Deployment**
```bash
kubectl get ingress -n freshmart
kubectl get svc -n ingress-nginx
kubectl get deploy -n freshmart
kubectl get pods -n freshmart
kubectl get all -n freshmart
```

### **Check the Website**
Visit **[http://freshmart.duckdns.org](http://freshmart.duckdns.org)** in a browser.

---

## **🛠️ Troubleshooting Common Issues**
### **1️⃣ Application Returning 404 Not Found?**
```bash
kubectl logs -l app.kubernetes.io/name=ingress-nginx -n ingress-nginx --tail=50 | grep "GET"
```

### **2️⃣ AWS Load Balancer Not Forwarding Requests?**
```bash
kubectl get svc -n ingress-nginx
```

### **3️⃣ Ingress Hostname Mismatch?**
```bash
curl -v -H "Host: freshmart.duckdns.org" http://<AWS-LOAD-BALANCER>
```

### **4️⃣ DuckDNS Not Pointing to Correct IP?**
```bash
dig +short freshmart.duckdns.org
curl "https://www.duckdns.org/update?domains=freshmart&token=YOUR_DUCKDNS_TOKEN&ip=<AWS-LOAD-BALANCER>"
```

---

## **🎯 Conclusion**
By following this guide, you have successfully **deployed an application to AWS EKS using GitHub Actions CI/CD**. 🎉

👉 **For the complete project, check out the repository:**
🔗 [GitHub Repository](https://github.com/sandeepkalathil/githubactions-eks)

💬 **Questions or feedback? Let’s connect and discuss!** 🚀

