#!/bin/bash
# Puppet Master Install with The Foreman 1.8 on Debian Jessie 8.2
# Author: John McCarthy
#Contributor : Yamlal Gotame
# <http://www.midactstech.blogspot.com> <https://www.github.com/Midacts>
# Date: 14 of November, 2015
# Version 1.5
#
# To God only wise, be glory through Jesus Christ forever. Amen.
# Romans 16:27, I Corinthians 15:1-4
#---------------------------------------------------------------
######## FUNCTIONS ########
function setHostname()
{
	# Edits the /etc/hosts file
		IP=`hostname -I`
		Hostname=`hostname`
		FQDN=`hostname -f`
		echo -e "127.0.0.1	localhost			localhosts.localdomain	$FQDN\n$IP	$FQDN	$Hostname		puppet" > /etc/hosts
}

function checkIfInstalled ()
{
	# Check if application is installed or not 
	appInstalled=`which $1`
	#Double check
	appPkg=`dpkg --get-selections | grep $1`
}
function installApp()
{
        # Installs the latest version of application send in parameter
        echo
       	echo -e '\e[01;34m+++ Installing '$1' ....\e[0m'
        apt-get install $1 -y
        echo -e '\e[01;37;42mThe '$1' has been installed!\e[0m'
}

function puppetRepos()
{
	# Gets the latest puppet repos
		echo
		echo -e '\e[01;34m+++ Getting repositories...\e[0m'
		wget http://apt.puppetlabs.com/puppetlabs-jessie-wheezy.deb
		dpkg -i puppetlabs-jessie-wheezy.deb
		apt-get update
		echo -e '\e[01;37;42mThe Latest Puppet Repos have been acquired!\e[0m'
}
function installPuppet()
{
	# Installs the latest version of puppetmaster
		echo
		echo -e '\e[01;34m+++ Installing Puppet Master...\e[0m'
		apt-get install puppetmaster-passenger -y
		echo -e '\e[01;37;42mThe Puppet Master has been installed!\e[0m'
}
function enablePuppet()
{
	# Enables the puppetmaster service to be set to ensure it is running
		echo
		echo -e '\e[01;34m+++ Enabling Puppet Master Service...\e[0m'
		puppet resource service puppetmaster ensure=running enable=true
		echo -e '\e[01;37;42mThe Puppet Master Service has been initiated!\e[0m'
}
function foremanRepos()
{
	# Gets the latest foreman repos
		echo
		echo -e '\e[01;34m+++ Getting repositories...\e[0m'
		echo "deb http://deb.theforeman.org/ jessie 1.8" > /etc/apt/sources.list.d/foreman.list
		echo "deb http://deb.theforeman.org/ plugins 1.8" >> /etc/apt/sources.list.d/foreman.list
		wget -q http://deb.theforeman.org/pubkey.gpg -O- | apt-key add -
		apt-get update
		echo -e '\e[01;37;42mThe Latest Foreman Repos have been acquired!\e[0m'
}
function installForeman()
{
	# Downloads the foreman-installer
		echo
		echo -e '\e[01;34m+++ Installing The Foreman...\e[0m'
		apt-get install foreman-installer -y
		echo -e '\e[01;37;42mThe Foreman Installer has been downloaded!\e[0m'

	# Stars foreman-installer
		echo
		echo -e '\e[01;34mInitializing The Foreman Installer...\e[0m'
		echo "-------------------------------------"
		sleep 1
		echo -e '\e[33mMake any additional changes you would like\e[0m'
		sleep 1
		echo -e '\e[33mSelect option "24" and hit ENTER to run the install\e[0m'
		sleep 1
		echo
		echo -e '\e[97mHere\e[0m'
		sleep .5
		echo -e '\e[97mWe\e[0m'
		sleep .5
		echo -e '\e[01;97;42mG O  ! ! ! !\e[0m'
		foreman-installer -i -v

	# Sets foreman and foreman-proxy services to start on boot
		sed -i 's/START=no/START=yes/g' /etc/default/foreman
		echo "START=yes" >> /etc/default/foreman-proxy

	# Sets it so you the puppetmaster and puppet services starts on boot
		sed -i 's/START=no/START=yes/g' /etc/default/puppet

	# Makes changes for Puppet 3.6.2 deprecation warning
		#sed -i '0,/\[main\]/s/\[main\]/&\n    # Puppet 3.6.2 Modification\n    environmentpath=$confdir\/environments\n/g' /etc/puppet/puppet.conf
		#sed -i '/\[development\]/d' /etc/puppet/puppet.conf
		#sed -i '/\[production\]/d' /etc/puppet/puppet.conf
		#sed -i '/modulepath/d' /etc/puppet/puppet.conf
		#sed -i '/config_version/d' /etc/puppet/puppet.conf

	# Restarts the foreman and foreman-proxy services
		service foreman restart
		service foreman-proxy restart
		echo -e '\e[01;37;42mThe Foreman has been installed!\e[0m'

	# Restarts the apache2 service
		echo
		echo -e '\e[01;34m+++ Restarting the apache2 service...\e[0m'
		service apache2 restart
		echo -e '\e[01;37;42mThe apache2 service has been restarted!\e[0m'
}
function doAll()
{
	# Calls the setHostname function
		echo
		echo -e "\e[33m=== Set Machine's Hostname for Puppet Runs ? [RECOMMENDED] (y/n)\e[0m"
		read yesno
		if [ "$yesno" = "y" ]; then
			setHostname
		fi
	# Calls the function checkIFInstalled to check Apache2 status
		echo
		echo -e "\e[33m=== Check Apache2 Status? [RECOMMENDED] (y/n)\e[0m"
		read yesno
		if [ "$yesno" = "y" ]; then
			checkIfInstalled apache2
		fi
	# Calls the function installApp if apache2 is not installed	
		echo
		if [ $appInstalled = "" && $appPkg == ""]
		then
        		echo -e "\e[33m=== Application Apache2 not installed. Install it? [RECOMMENDED] (y/n)\e[0m"
			read yesno
			if [ "$yesno" = "y" ]; then
				installApp apache2
			fi
		fi
		
		
	# Calls the puppetRepos function
		echo
		echo -e "\e[33m=== Get Latest Puppet Repos ? (y/n)\e[0m"
		read yesno
		if [ "$yesno" = "y" ]; then
			puppetRepos
		fi

	# Calls the installPuppet function
		echo
		echo -e "\e[33m=== Install Puppet Master ? (y/n)\e[0m"
		read yesno
		if [ "$yesno" = "y" ]; then
			installPuppet
		fi

	# Calls the enablePuppet function
		echo
		echo -e "\e[33m=== Enable Puppet Master Service ? (y/n)\e[0m"
		read yesno
		if [ "$yesno" = "y" ]; then
			enablePuppet
		fi
	# Calls the foremanRepos function
		echo
		echo -e "\e[33m=== Get Latest Foreman Repos ? (y/n)\e[0m"
		read yesno
		if [ "$yesno" = "y" ]; then
			foremanRepos
		fi

	# Calls the installForeman function
		echo
		echo -e "\e[33m=== Install The Foreman ? (y/n)\e[0m"
		read yesno
		if [ "$yesno" = "y" ]; then
			installForeman
		fi

	# End of Script Congratulations, Farewell and Additional Information
		clear
		farewell=$(cat << EOZ

  \e[01;37;42mWell done! You have completed your Puppet Master and Foreman Installation! \e[0m

                  \e[01;39mProceed to your Foreman web UI, https://fqdn\e[0m

                         \e[01;39mForeman Default Credentials:\e[0m
                               \e[34mUsername\e[0m\e[01;39m: admin\e[0m
                               \e[34mPassword\e[0m\e[01;39m: changeme\e[0m

  \e[30;01mCheckout similar material at midactstech.blogspot.com and github.com/Midacts\e[0m

                            \e[01;37m########################\e[0m
                            \e[01;37m#\e[0m \e[31mI Corinthians 15:1-4\e[0m \e[01;37m#\e[0m
                            \e[01;37m########################\e[0m


EOZ
)

	#Calls the End of Script variable
		echo -e "$farewell"
		echo
		echo
		exit 0
}

# Check privileges
	[ $(whoami) == "root" ] || die "You need to run this script as root."

# Welcome to the script
	clear
	welcome=$(cat << EOA


             \e[01;37;42mWelcome to Midacts Mystery's Puppet Master Installer!\e[0m



EOA
)

# Calls the welcome variable
	echo -e "$welcome"

# Calls the doAll function
	case "$go" in
		* )
			doAll ;;
	esac

	exit 0
