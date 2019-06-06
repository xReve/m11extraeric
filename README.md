## PopServer
### Eric Escriba

### Pas a Pas

#### Connexió AWS

* En primer lloc cal obrir una instància a Amazon per poder treballar. Una vegada engegada ens hi connectarem de la següent manera:

```
[isx47983457@i23 ~]$ ssh -i .ssh/home_keys.pem fedora@3.8.209.63
The authenticity of host '3.8.209.63 (3.8.209.63)' can't be established.
ECDSA key fingerprint is SHA256:9vdVcwt/xtghLJL1GIn+rpzTsOkNwb79aqFJn0k9Q78.
ECDSA key fingerprint is MD5:31:7f:bb:67:22:96:d2:8f:db:36:1d:90:fb:58:01:c4.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added '3.8.209.63' (ECDSA) to the list of known hosts.
Last login: Thu Apr  4 14:56:17 2019 from 90.74.16.47
[fedora@ip-172-31-28-34 ~]$ sudo /bin/bash

```

* Per poder treballar sense que res ens molesti, haurem de obrir els ports necessaris a **AWS**. En aquest cas ens interessen els ports **110** i **995**.

* Aquesta part es configura a la part de **grup** al qual està associat la instància de aws i s'han d'editar les regles d'**INBOUND**.

* Arribats en aquest punt ja podem començar a treballar.

#### Creació entorn docker

* Descarga de docker: `dnf -y install docker`, i activació: `systemctl start docker`

* Creació xarxa: `docker network create popnet`

* Creació del docker per treballar:  `docker run --name popserver -h popserver --network popnet -p 110:110 -p 995:995 -it fedora:27 /bin/bash` 

#### Treballar en la imatge

* Instal·lem els paquets necessàris:

```
dnf -y install uw-imap passwd procps nmap telnet
```

* Creem els usuaris

```
useradd pere

useradd marta

passwd pere

passwd marta - marta

```

* Creem correu a les seves bústies

```
cat mail >> /var/spool/mail/marta 
cat mail >> /var/spool/mail/pere
```

* Canviem la configuració dels serveis dins del directori `xinet.d`. Establim la opció **disable = no**.


* Activem el servei xinted `/usr/sbin/xinetd` 


* Comprovació del estat actual:

```
[root@popserver docker]# nmap localhost

Starting Nmap 7.60 ( https://nmap.org ) at 2019-06-06 07:59 UTC
Nmap scan report for localhost (127.0.0.1)
Host is up (0.0000060s latency).
Other addresses for localhost (not scanned): ::1
Not shown: 998 closed ports
PORT    STATE SERVICE
110/tcp open  pop3
995/tcp open  pop3s

Nmap done: 1 IP address (1 host up) scanned in 1.62 seconds
```

Tenim els ports que voliem oberts correctament!


* Comprovació servidor en funcionament

```
[root@popserver docker]# telnet  localhost 110
Trying ::1...
Connected to localhost.
Escape character is '^]'.
+OK POP3 localhost 2007f.104 server ready
USER pere
+OK User name accepted, password please
USER marta
+OK User name accepted, password please
USE^C^[^@^[^]
telnet> Connection closed.
[root@popserver docker]# telnet  localhost 110
Trying ::1...
Connected to localhost.
Escape character is '^]'.
+OK POP3 localhost 2007f.104 server ready
USER pere
+OK User name accepted, password please
PASS pere
+OK Mailbox open, 2 messages
LIST
+OK Mailbox scan listing follows
1 166
2 90
.
RETR 2
+OK 90 octets
Received: from ... by ... with SMTP
Subject: Iggeret
To: <you@aoeu.snth>
Status:  O
```


#### EXECUCIÓ CONTAINER AUTOMATITZAT AMB DETACH

* Abans que res creem la imatge del servidor amb la següent ordre:

```
docker build -t eescriba/m11extraeric:latest .
```

Important recordar que aquesta ordre agafarà la configuració de la imatge del directori **actual**.


* **Execució**

```
docker run --rm --name popserver -h popserver --network popnet -p 110:110 -p 995:995 -d eescriba/m11extraeric:latest
```

* Comprovem que amazon ara té els ports **110** i **995** oberts:

```
[root@ip-172-31-28-34 m11extraeric]# nmap localhost
Starting Nmap 7.70 ( https://nmap.org ) at 2019-06-06 08:02 UTC
Nmap scan report for localhost (127.0.0.1)
Host is up (0.0000070s latency).
Other addresses for localhost (not scanned): ::1
Not shown: 995 closed ports
PORT    STATE SERVICE
7/tcp   open  echo
13/tcp  open  daytime
22/tcp  open  ssh
110/tcp open  pop3
995/tcp open  pop3s
```

* Comprovació funcionament 




#### Descarrèga de mails

* Descarreguem el mail de **pere** des del host de l'aula utilitzant **POP3**:

```
[root@i23 tmp]# telnet 3.8.209.63 110
Trying 3.8.209.63...
Connected to 3.8.209.63.
Escape character is '^]'.
+OK POP3 popserver 2007f.104 server ready
USER pere
+OK User name accepted, password please
PASS pere
+OK Mailbox open, 2 messages
LIST
+OK Mailbox scan listing follows
1 166
2 88
.
RETR 1
+OK 166 octets
Received: from ... by ... with ESMTP;
Subject: Prueba
From: <build.9.0.2416@ixazon.dynip.com>
To: <junkdtectr@carolina.rr.com>
Status:   

> Prova Correu Fake
.
```

* Els commands **USER** i **PASS** són per autenticar-se contra el servidor. 

* **LIST** per llistar els mails que tens i el seu **size**  

* **RETR 1** per visualitzar el correu 1 de la safata d'entrada.


* Descarrèga del mail d'anna amb **POP3S** des del host de l'aula:

```
[root@i23 tmp]# openssl s_client -connect 3.8.209.63:995
CONNECTED(00000003)
depth=0 C = --, ST = SomeState, L = SomeCity, O = SomeOrganization, OU = SomeOrganizationalUnit, CN = localhost.localdomain, emailAddress = root@localhost.localdomain
verify error:num=18:self signed certificate
verify return:1
depth=0 C = --, ST = SomeState, L = SomeCity, O = SomeOrganization, OU = SomeOrganizationalUnit, CN = localhost.localdomain, emailAddress = root@localhost.localdomain
verify return:1
---
Certificate chain
 0 s:/C=--/ST=SomeState/L=SomeCity/O=SomeOrganization/OU=SomeOrganizationalUnit/CN=localhost.localdomain/emailAddress=root@localhost.localdomain
   i:/C=--/ST=SomeState/L=SomeCity/O=SomeOrganization/OU=SomeOrganizationalUnit/CN=localhost.localdomain/emailAddress=root@localhost.localdomain
---
Server certificate
-----BEGIN CERTIFICATE-----
MIIETjCCAzagAwIBAgIJAIPAp2rFr6A7MA0GCSqGSIb3DQEBCwUAMIG7MQswCQYD
VQQGEwItLTESMBAGA1UECAwJU29tZVN0YXRlMREwDwYDVQQHDAhTb21lQ2l0eTEZ
MBcGA1UECgwQU29tZU9yZ2FuaXphdGlvbjEfMB0GA1UECwwWU29tZU9yZ2FuaXph
dGlvbmFsVW5pdDEeMBwGA1UEAwwVbG9jYWxob3N0LmxvY2FsZG9tYWluMSkwJwYJ
KoZIhvcNAQkBFhpyb290QGxvY2FsaG9zdC5sb2NhbGRvbWFpbjAeFw0xOTA2MDYw
NzUyMDBaFw0yMDA2MDUwNzUyMDBaMIG7MQswCQYDVQQGEwItLTESMBAGA1UECAwJ
U29tZVN0YXRlMREwDwYDVQQHDAhTb21lQ2l0eTEZMBcGA1UECgwQU29tZU9yZ2Fu
aXphdGlvbjEfMB0GA1UECwwWU29tZU9yZ2FuaXphdGlvbmFsVW5pdDEeMBwGA1UE
AwwVbG9jYWxob3N0LmxvY2FsZG9tYWluMSkwJwYJKoZIhvcNAQkBFhpyb290QGxv
Y2FsaG9zdC5sb2NhbGRvbWFpbjCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoC
ggEBAMhY2fLkwOW2qER+oLBG7T0wXScZ6sapB3sVxZkN6jvXXnBiGi3jcCpWBgT5
BnnVr6Gqwcqi9740bWTJR+MRUx83Ulhy3xXxWDwoWcxGpQiZWOenLbQDKJ45Z1kS
7JbSsBlNjPeQljkqZyX2dWkMLowoZ8GLTBWLKpZz7mJAc1UK50EfwW1YuA1fro6P
Zdv404WrD9TPTFlBsyv3yE3J1DCUPOZnvychtnxEeoaCZbjV+4sVU98JNfmv1AeQ
TkV+EgYetbhRqGDQ8DhKOUM4E+dBsdXc6eWHlNVF0IIpUSUpmxBBuKa9ZYX0LjzS
rLzNF81Z5Lvi5yojetmUvqXCBL0CAwEAAaNTMFEwHQYDVR0OBBYEFA82d6IFGjND
pL80jt2NixJwtRoiMB8GA1UdIwQYMBaAFA82d6IFGjNDpL80jt2NixJwtRoiMA8G
A1UdEwEB/wQFMAMBAf8wDQYJKoZIhvcNAQELBQADggEBAKDQQmkzp1ZkS9+EbW5b
Yu8v2cQ3OmZa1FtDn0W2yakTHJHsE0b5IHJJK5sRjx02Zxu0bgvh5+pxPGtqE2RQ
LDelvibvkA66uZGHb8MpG5vFQF9jztDko04zlA6exkUvnnoBv8mhjwkNY1i9oSB6
AD24DS91LC5Rdf81UnS5DNW3nyM/s6hhpeQTaMo9WlRC7cV0K3q/vmg/AGPwFLvQ
ivZXWZTyXvHOjp8vYSYOahcaHP/pV6+sK3XtR99DV5abh3Mketv4U3TpFutmeVdQ
Grwk3ctNv9us6fF4tkKYldRTBT6g/uZc7W8kaQ1e26x4wbQBU34dXvRdNWHJQMGv
Yog=
-----END CERTIFICATE-----
subject=/C=--/ST=SomeState/L=SomeCity/O=SomeOrganization/OU=SomeOrganizationalUnit/CN=localhost.localdomain/emailAddress=root@localhost.localdomain
issuer=/C=--/ST=SomeState/L=SomeCity/O=SomeOrganization/OU=SomeOrganizationalUnit/CN=localhost.localdomain/emailAddress=root@localhost.localdomain
---
No client certificate CA names sent
Peer signing digest: SHA512
Server Temp Key: X25519, 253 bits
---
SSL handshake has read 1731 bytes and written 347 bytes
Verification error: self signed certificate
---
New, TLSv1.2, Cipher is ECDHE-RSA-AES256-GCM-SHA384
Server public key is 2048 bit
Secure Renegotiation IS supported
Compression: NONE
Expansion: NONE
No ALPN negotiated
SSL-Session:
    Protocol  : TLSv1.2
    Cipher    : ECDHE-RSA-AES256-GCM-SHA384
    Session-ID: BBB25A488825BF6A684825977F21ADA3A0D95A0110ED24CC5D900D7ABBD7F22F
    Session-ID-ctx: 
    Master-Key: 7C58C0CE37152A385F276E457D6980EB1AD5DC1DDB94A138F635526964BDE968611A93FB13A1E4E22BBBA8F38746DBA4
    PSK identity: None
    PSK identity hint: None
    SRP username: None
    TLS session ticket lifetime hint: 7200 (seconds)
    TLS session ticket:
    0000 - 38 48 1b 3b ff 3e 18 e3-a6 ae fb c0 f5 58 e2 5f   8H.;.>.......X._
    0010 - ca f4 a1 00 fb 1a 90 ba-c5 bd 3a c0 12 96 ff 1c   ..........:.....
    0020 - 4f 16 81 55 88 e0 fe 6a-4d 63 7d 1b 02 9e c2 69   O..U...jMc}....i
    0030 - bd 13 7e 46 46 e7 f1 ec-f6 b0 b8 ae 9a 30 fa cb   ..~FF........0..
    0040 - 7d ad 42 0f 00 26 6f 61-c2 51 da ee 60 cb 24 52   }.B..&oa.Q..`.$R
    0050 - 78 9e e9 d5 12 7c 70 13-e3 c4 3c 21 92 ba 17 1a   x....|p...<!....
    0060 - b1 8b 4c c3 32 7a 39 ef-18 4f b7 a1 a2 08 14 f1   ..L.2z9..O......
    0070 - 2d fd 9f 52 a6 84 d9 44-67 0c ff e4 94 77 db 00   -..R...Dg....w..
    0080 - 2a 19 77 54 4a ce c3 95-d2 a3 78 36 53 25 f6 04   *.wTJ.....x6S%..
    0090 - 04 d2 0d e9 c4 52 9f 91-02 9d a8 f1 78 bd 0f 80   .....R......x...

    Start Time: 1559808870
    Timeout   : 7200 (sec)
    Verify return code: 18 (self signed certificate)
    Extended master secret: yes
---
+OK POP3 popserver 2007f.104 server ready
USER marta
+OK User name accepted, password please
PASS marta
+OK Mailbox open, 2 messages
RETR 2
RENEGOTIATING
depth=0 C = --, ST = SomeState, L = SomeCity, O = SomeOrganization, OU = SomeOrganizationalUnit, CN = localhost.localdomain, emailAddress = root@localhost.localdomain
verify error:num=18:self signed certificate
verify return:1
depth=0 C = --, ST = SomeState, L = SomeCity, O = SomeOrganization, OU = SomeOrganizationalUnit, CN = localhost.localdomain, emailAddress = root@localhost.localdomain
verify return:1

```

* La connexió i autentiació via **POP3s** és correcta.

* Alhora de descarregar els missatges el servidor ens respon que tenim un **CERTIFICAT AUTOSIGNAT** i ens denega l'accès als correus. 


#### THUNDERBIRD

* Descarreguem el software: 

```
dnf -y install thunderbird
```


* En primer lloc hem de **configurar** un compte de correu :

* Definir l'username i password de **pere** i en la secció mail definir el mail de pere.


No troba el servidor pop i no hem deixa autenticar amb els usuaris.


### ORDRES GIT I DOCKER

* Per **guardar i pujar** els canvis fets en repositori git al local, seguirem els següents passos:

	- git add
	- git commit -m "commit message"
	- git push (Validar-se contra github amb les credencials)


* Per pujar les imatges al **Dockerhub** primer guardarem les imatges en local en els tags corresponents:

```
docker tag eescriba/m11extraeric:latest eescriba/m11extraeric:v1

```

* Actualitzar el remot:

```
[root@ip-172-31-28-34 m11extraeric]# docker push eescriba/m11extraeric:v1

[root@ip-172-31-28-34 m11extraeric]# docker push eescriba/m11extraeric:latest
```






