#!/bin/sh
# By Eduardo Moraes <emoraes25@gmail.com>
# Script de Instalação do cid
#---------------------------------------------------#

Control () {
DEB="`ls | grep '.deb'`"

clear

echo "
--------------------------------------------------------------------------
 -> PESQUISANDO VERSÕES ANTERIORES...
--------------------------------------------------------------------------
"

sleep 2

if [ "`which cid`" != "" ]; then

	New_Version="`ls -l | grep '.deb' | cut -d "_" -f 2`"

	Current_Version="`dpkg -p cid | grep 'Version' | cut -d " " -f 2`"

	OPNew_1=`echo $New_Version | cut -d "." -f 1`

	OPCurrent_1=`echo $Current_Version | cut -d "." -f 1`

	OPNew_2=`echo $New_Version | cut -d "." -f 2`

	OPCurrent_2=`echo $Current_Version | cut -d "." -f 2`

	if [ "$OPNew_1" -eq "$OPCurrent_1" ]; then

		if [ "$OPNew_2" -lt "$OPCurrent_2" ]; then

			echo "
	***********************************************************
	 A VERSÃO INSTALADA É MAIS RECENTE QUE A VERSÃO DO PACOTE!
	***********************************************************
"
			exit 0

		elif [ "$OPNew_2" -gt "$OPCurrent_2" ]; then

			echo "
	*****************************************
	 ATUALIZANDO VERSÃO DO PACOTE INSTALADO!
	*****************************************
"

			apt-get install nss-updatedb libnss-db libpam-ccreds -y
			dpkg -i $DEB
			apt-get -f install --fix-missing --force-yes -y

			End
		
		else

			echo "
	***************************************
	 A VERSÃO DO PACOTE JÁ ESTÁ INSTALADA!
	***************************************
"
			exit 0
		fi
	else
		if [ "$OPNew_1" -lt "$OPCurrent_1" ]; then

			echo "
	***********************************************************
	 A VERSÃO INSTALADA É MAIS RECENTE QUE A VERSÃO DO PACOTE!
	***********************************************************
"
			exit 0

		else

			echo "
	*****************************************
	 ATUALIZANDO VERSÃO DO PACOTE INSTALADO!
	*****************************************
"
			apt-get install nss-updatedb libnss-db libpam-ccreds -y
			dpkg -i $DEB
			apt-get -f install --fix-missing --force-yes -y

			End
		fi
	fi
else
	echo "
	*************************************
	 NENHUMA VERSÃO ANTERIOR ENCONTRADA!
	*************************************
"

	Install

	End
fi
}



Install () {

sleep 2


echo "
--------------------------------------------------------------------------
 -> ATUALIZANDO LISTA DE REPOSITÓRIOS...
--------------------------------------------------------------------------
"

apt-get update --fix-missing


sleep 2


echo "
--------------------------------------------------------------------------
 -> INSTALANDO PRÉ-DEPENDÊNCIAS...
--------------------------------------------------------------------------
"

apt-get install sudo -y
apt-get install zenity -y


sleep 2


echo "
--------------------------------------------------------------------------
 -> INSTALANDO DEPENDÊNCIAS...
--------------------------------------------------------------------------
"

apt-get install samba -y
apt-get install smbclient -y
apt-get install smbfs -y
apt-get install cifs-utils -y
apt-get install libpam-mount -y
apt-get install libnss-winbind -y
apt-get install libpam-winbind -y
apt-get install winbind -y
apt-get install ntpdate -y

if [ ! -e /etc/krb5.conf ]; then
	echo '[libdefaults]
	default_realm = ATHENA.MIT.EDU
	krb4_config = /etc/krb.conf
	krb4_realms = /etc/krb.realms
	kdc_timesync = 1
	ccache_type = 4
	forwardable = true
	proxiable = true
	fcc-mit-ticketflags = true

[realms]
	ATHENA.MIT.EDU = {
		kdc = kerberos.mit.edu:88
		admin_server = kerberos.mit.edu
		default_domain = mit.edu
	}

[domain_realm]
	.mit.edu = ATHENA.MIT.EDU
	mit.edu = ATHENA.MIT.EDU

[login]
	krb4_convert = true
	krb4_get_tickets = false' > /etc/krb5.conf
fi

apt-get install libpam-krb5 -y
apt-get install krb5-user -y
apt-get install krb5-config -y
apt-get install nss-updatedb libnss-db libpam-ccreds -y


sleep 2


echo "
--------------------------------------------------------------------------
 -> INSTALANDO PACOTES RECOMENDADOS E SUGERIDOS...
--------------------------------------------------------------------------
"

if [ -e /etc/init.d/kdm ]; then
	apt-get install kdesudo -y
else
	apt-get install gksu -y
fi

if [ "`which nslookup`" = "" ]; then
	apt-get install dnsutils -y
fi

apt-get install aptitude -y
apt-get install gconf-editor -y
apt-get install dconf-tools -y


sleep 2


echo "
--------------------------------------------------------------------------
 -> CORRIGINDO POSSÍVEIS FALHAS...
--------------------------------------------------------------------------
"

dpkg --configure -a
apt-get -f install --fix-missing --force-yes -y


sleep 2


echo "
--------------------------------------------------------------------------
 -> INSTALANDO PACOTE $DEB...
--------------------------------------------------------------------------
"

DEB="`ls | grep '.deb'`"
dpkg -i $DEB


echo "
---------------------------------------------------------------------------------------
"
}



End () {

sleep 2

clear

echo "
---------------------------------------------------------------------------------------
 -> VERIFICANDO INSTALAÇÃO...
---------------------------------------------------------------------------------------
"

sleep 2

if [ "`dpkg -s cid | grep "Status" | grep "ok"`" != "" ] && [ "`which cid`" != "" ]; then

	clear

	echo "
	*******************************
	 PACOTE INSTALADO COM ÊXITO!!!
	*******************************

"

else

	clear

	echo "
	##################################
	 FALHA NA INSTALAÇÃO DO PACOTE!
	 TENTE INSTALÁ-LO EM MODO GRÁFICO
	##################################

"
fi


exit 0
}

Control
