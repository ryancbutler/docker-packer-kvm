  
FROM mcr.microsoft.com/powershell
ENV PACKER_VERSION 1.5.6
#ENV PLUGIN_VERSION 2.0.1
ENV ANSIBLE_VERSION 2.9
RUN pwsh -c 'Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted' && \
apt-get update && \
apt-get install wget unzip python3 software-properties-common python3-pip jq ssh -y && \
#pip3 install awscli && \
pwsh -c 'install-module az -force -confirm:$false' && \
pwsh -c 'install-module VMware.PowerCLI -force -confirm:$false' && \
pwsh -c 'Set-PowerCLIConfiguration -InvalidCertificateAction:Ignore -confirm:$false' && \
wget https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip && \
unzip packer_${PACKER_VERSION}_linux_amd64.zip -d /usr/bin && \
chmod +x /usr/bin/packer && \
pip3 install "ansible>=${ANSIBLE_VERSION}" && \
pip3 install "pywinrm" && \
apt-get install qemu -y
# Install Wok
RUN pip3 install cheetah3
RUN wget https://github.com/kimchi-project/wok/releases/download/3.0.0/wok-3.0.0-0.ubuntu.noarch.deb
RUN apt-get install python3-ldap logrotate python3-psutil python3-lxml python3-websockify python3-jsonschema nginx python3-cherrypy3 python3-pam python-m2crypto gettext python3-openssl -y
#RUN apt install -y wok-3.0.0-0.ubuntu.noarch.deb
RUN dpkg --ignore-depends=python3-cheetah -i wok-3.0.0-0.ubuntu.noarch.deb

# Some Kimchi dependencies need to be installed via pip
RUN apt install -y python3-pip pkg-config libnl-route-3-dev && \
pip3 install -r https://raw.githubusercontent.com/kimchi-project/kimchi/master/requirements-UBUNTU.txt

RUN git clone https://github.com/kimchi-project/kimchi.git &&\
  cd kimchi &&\
  ./autogen.sh --system &&\
  make &&\
  make install &&\
  cd / &&\
  rm -rf /var/lib/kimchi/isos /kimchi

RUN (sed -i "s/#create_iso_pool = true/create_iso_pool = false/g" /etc/kimchi/kimchi.conf &&\
  sed -i "s/#display_proxy_port = 64667/display_proxy_port = 64668/g" /etc/kimchi/kimchi.conf)

ENTRYPOINT ["kimchid"]
CMD ["--host=0.0.0.0"]
