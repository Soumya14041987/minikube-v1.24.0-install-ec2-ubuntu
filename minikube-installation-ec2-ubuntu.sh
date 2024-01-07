# Uninstall old versions
sudo apt-get remove docker docker-engine docker.io containerd runc

#Install the necccessary & Downloads and installs the Docker GPG key.
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg lsb-release

#Adds the Docker repository to the system’s package sources & Installs Docker CE, Docker CLI, containerd.io, docker-buildx-plugin, and docker-compose-plugin.

sudo mkdir -m 0755 -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

#Checks the status of the Docker service. #Enables the Docker service to start at boot. #Adds the current user to the docker group. #Restarts the Docker service.

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo chmod a+r /etc/apt/keyrings/docker.gpg
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo systemctl status docker
sudo systemctl enable --now docker
sudo usermod -aG docker ec2-user
newgrp docker
sudo systemctl restart docker
docker ps



#Install Kubectl

Reference Documentation : https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
mv kubectl /bin/kubectl
chmod a+x /bin/kubectl



#Install Minikube
Reference Documentation :-
https://aws.plainenglish.io/running-kubernetes-using-minikube-cluster-on-the-aws-cloud-4259df916a07
https://minikube.sigs.k8s.io/docs/start/
https://minikube.sigs.k8s.io/docs/drivers/none/#requirements


curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/bin/minikube
sudo apt install conntrack -y


Kubernetes v1.24 dropped support for Dockershim, so if you want to use the combination of the none driver, Kubernetes v1.24+, and the Docker container runtime you'll need to install cri-dockerd on your system, as listed in our requirements page. 

Reference Documentation :- Follow https://github.com/Mirantis/cri-dockerd#build-and-install


#Install cri-dockerd
apt install git -y
git clone https://github.com/Mirantis/cri-dockerd.git






##This code is used to build the cri-dockerd binary file. The first line creates a new directory named bin. The second line sets the VERSION variable to the latest Git tag, or if there is no tag, it sets the version to the latest commit hash. The PRERELEASE variable is set to “pre” if the version contains “dev”, otherwise it is set to an empty string. The REVISION variable is set to the latest commit hash. The PRERELEASE variable is set to “pre” if the version contains “dev”, otherwise it is set to an empty string. The REVISION variable is set to the latest commit hash.

##The third line builds the cri-dockerd binary file with the following flags:

mkdir bin
VERSION=$((git describe --abbrev=0 --tags | sed -e 's/v//') || echo $(cat VERSION)-$(git log -1 --pretty='%h')) PRERELEASE=$(grep -q dev <<< "${VERSION}" && echo "pre" || echo "") REVISION=$(git log -1 --pretty='%h')
go build -ldflags="-X github.com/Mirantis/cri-dockerd/version.Version='$VERSION}' -X github.com/Mirantis/cri-dockerd/version.PreRelease='$PRERELEASE' -X github.com/Mirantis/cri-dockerd/version.BuildTime='$BUILD_DATE' -X github.com/Mirantis/cri-dockerd/version.GitCommit='$REVISION'" -o cri-dockerd

##This code is used to build and install the cri-dockerd binary file on an Ubuntu system. The first line changes the current directory to cri-dockerd. The second line creates a new directory named bin. The third line builds the cri-dockerd binary file and saves it in the bin directory. The fourth line creates a new directory named /usr/local/bin. The fifth line installs the cri-dockerd binary file with the appropriate permissions in the /usr/local/bin directory. The sixth line copies the systemd service files from the packaging/systemd directory to the /etc/systemd/system directory. The seventh line modifies the cri-docker.service file to use the newly installed cri-dockerd binary file. The eighth line reloads the systemd daemon. The ninth line enables the cri-docker.service service to start at boot. The tenth line enables the cri-docker.socket socket to start at boot. Please note that this code should be run with root privileges.



cd cri-dockerd
mkdir bin
go build -o bin/cri-dockerd
mkdir -p /usr/local/bin
install -o root -g root -m 0755 bin/cri-dockerd /usr/local/bin/cri-dockerd
cp -a packaging/systemd/* /etc/systemd/system
sed -i -e 's,/usr/bin/cri-dockerd,/usr/local/bin/cri-dockerd,' /etc/systemd/system/cri-docker.service
systemctl daemon-reload
systemctl enable cri-docker.service
systemctl enable --now cri-docker.socket


##Install CRICTL
https://github.com/kubernetes-sigs/cri-tools/blob/master/docs/crictl.md

VERSION="v1.26.0" # check latest version in /releases page
wget https://github.com/kubernetes-sigs/cri-tools/releases/download/$VERSION/crictl-$VERSION-linux-amd64.tar.gz
sudo tar zxvf crictl-$VERSION-linux-amd64.tar.gz -C /usr/local/bin
rm -f crictl-$VERSION-linux-amd64.tar.gz

cat <<EOF | sudo tee /etc/crictl.yaml
runtime-endpoint: unix:///run/containerd/containerd.sock
image-endpoint: unix:///run/containerd/containerd.sock
timeout: 2
debug: false
pull-image-on-create: false
EOFnstall CRICTL
https://github.com/kubernetes-sigs/cri-tools/blob/master/docs/crictl.md

VERSION="v1.26.0" # check latest version in /releases page
wget https://github.com/kubernetes-sigs/cri-tools/releases/download/$VERSION/crictl-$VERSION-linux-amd64.tar.gz
sudo tar zxvf crictl-$VERSION-linux-amd64.tar.gz -C /usr/local/bin
rm -f crictl-$VERSION-linux-amd64.tar.gz

cat <<EOF | sudo tee /etc/crictl.yaml
runtime-endpoint: unix:///run/containerd/containerd.sock
image-endpoint: unix:///run/containerd/containerd.sock
timeout: 2
debug: false
pull-image-on-create: false
EOF


##Start Minikube
minikube start --vm-driver=none


##Test the setup
kubectl run hello-minikube --image=gcr.io/google_containers/echoserver:1.4 --port=8080
kubectl expose pod hello-minikube --type=NodePort










