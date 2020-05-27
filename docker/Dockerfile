  
FROM mcr.microsoft.com/powershell
ENV PACKER_VERSION 1.5.6
#ENV PLUGIN_VERSION 2.0.1
ENV ANSIBLE_VERSION 2.9
RUN pwsh -c 'Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted' && \
apt-get update && \
apt-get install wget unzip python3 software-properties-common python3-pip jq ssh -y && \
pip3 install awscli && \
pwsh -c 'install-module az -force -confirm:$false' && \
pwsh -c 'install-module VMware.PowerCLI -force -confirm:$false' && \
pwsh -c 'Set-PowerCLIConfiguration -InvalidCertificateAction:Ignore -confirm:$false' && \
wget https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip && \
unzip packer_${PACKER_VERSION}_linux_amd64.zip -d /usr/bin && \
chmod +x /usr/bin/packer && \
pip3 install "ansible>=${ANSIBLE_VERSION}" && \
pip3 install "pywinrm" && \
apt-get install qemu -y