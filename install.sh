#! /bin/bash
# Secció install popserver
#####################################

# Creació usuaris
useradd marta
useradd pere

echo "pere" | passwd --stdin pere
echo "marta" | passwd --stdin marta

# Modificació fitxers xinetd

cp /opt/docker/ipop3 /etc/xinetd.d/ipop3
cp /opt/docker/pop3s /etc/xinetd.d/pop3s

# Crear el correu a les bústies

cat mail >> /var/spool/mail/marta 
cat mail >> /var/spool/mail/pere
