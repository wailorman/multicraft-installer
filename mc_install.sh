#!/bin/bash
function ask_install_reps {
	echo
	read -p "    Would you like to install repositories? ([y]/n) : "
	echo
    if [ "$REPLY" != "n" ]; then
		echo "deb http://mirror.hetzner.de/debian/packages squeeze main contrib non-free" | tee -a /etc/apt/sources.list
		echo "deb http://mirror.hetzner.de/debian/security squeeze/updates main contrib non-free" | tee -a /etc/apt/sources.list
		echo "deb http://cdn.debian.net/debian/  squeeze  main non-free contrib" | tee -a /etc/apt/sources.list
		echo "deb-src http://cdn.debian.net/debian/  squeeze  main non-free contrib" | tee -a /etc/apt/sources.list
		echo "deb http://security.debian.org/  squeeze/updates  main contrib non-free" | tee -a /etc/apt/sources.list
		echo "deb-src http://security.debian.org/  squeeze/updates  main contrib non-free" | tee -a /etc/apt/sources.list
		echo "deb http://mirror.hetzner.de/debian/backports squeeze-backports main contrib non-free" | tee -a /etc/apt/sources.list
		echo "deb http://backports.debian.org/debian-backports squeeze-backports main contrib non-free" | tee -a /etc/apt/sources.list
		apt-get update
	fi
}
function ask_install_lamp {
	echo
	read -p "    Would you like to install LAMP? ([y]/n) : "
	echo
    if [ "$REPLY" != "n" ]; then
        apt-get update ; apt-get --force-yes install apache2 php5 php5-mysql php5-sqlite php5-gd libapache2-mod-php5 mysql-server mysql-client zip sqlite nano php5-mcrypt proftpd
		get_debian-sys-maint_pass > /dev/null 2>&1
		installing_mysql_root > /dev/null 2>&1
		edit_apache_conf
	fi
}
function ask_root_pass {
	echo
	read -p "    Whats your root password?  : "
	echo
	MY_ROOT_PASSWORD="$REPLY"
}
function get_debian-sys-maint_pass {
	echo "    Getting debian-sys-maint password"
	cp /etc/mysql/debian.cnf ./debian.back.cnf
	sed -e "s/\[client\]//g" ./debian.back.cnf > ./debian.out.cnf ; cat ./debian.out.cnf
	cp ./debian.out.cnf ./debian.back.cnf
	sed -e "s/host     = localhost//g" ./debian.back.cnf > ./debian.out.cnf ; cat ./debian.out.cnf
	cp ./debian.out.cnf ./debian.back.cnf
	sed -e "s/user     = debian-sys-maint//g" ./debian.back.cnf > ./debian.out.cnf ; cat ./debian.out.cnf
	cp ./debian.out.cnf ./debian.back.cnf
	sed -e "s/socket   = \/var\/run\/mysqld\/mysqld.sock//g" ./debian.back.cnf > ./debian.out.cnf ; cat ./debian.out.cnf
	cp ./debian.out.cnf ./debian.back.cnf
	sed -e "s/\[mysql_upgrade\]//g" ./debian.back.cnf > ./debian.out.cnf ; cat ./debian.out.cnf
	cp ./debian.out.cnf ./debian.back.cnf
	sed -e "s/basedir  = \/usr//g" ./debian.back.cnf > ./debian.out.cnf ; cat ./debian.out.cnf
	cp ./debian.out.cnf ./debian.back.cnf
	sed -e "s/password/dsm_password/g" ./debian.back.cnf > ./debian.out.cnf ; cat ./debian.out.cnf
	cp ./debian.out.cnf ./debian.back.cnf
	sed -e "s/ //g" ./debian.back.cnf > ./debian.out.cnf ; cat ./debian.out.cnf
	cp ./debian.out.cnf ./debian.back.cnf
	source "./debian.back.cnf"
	rm ./debian.back.cnf
	rm ./debian.out.cnf
}
function installing_mysql_root {
	echo "    Installing MySQL root user"
	echo "DROP USER root@localhost; CREATE USER 'root'@'localhost' IDENTIFIED BY '${MY_ROOT_PASSWORD}'; GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' WITH GRANT OPTION; GRANT RELOAD,PROCESS ON *.* TO 'root'@'localhost';" > ./adding.sql
	mysql -u debian-sys-maint -p${dsm_password} < ./adding.sql
	rm ./adding.sql
	service mysql restart
}
function edit_apache_conf {
	echo "    Editing apache2 configuration"
	wget "http://dl.dropbox.com/u/13248852/mr-hosting/default" -O /etc/apache2/sites-available/default
	service apache2 restart
}
function ask_multicraft_lic_key {
	echo
	read -p "    Is 2AEF-326B-02BF-CA92 license key correct? If no, type another  ([y/type) : "
	echo
    if [ "$REPLY" != "y" ]; then
        MULTICRAFT_KEY = "$REPLY"
	else
		MULTICRAFT_KEY = "2AEF-326B-02BF-CA92"
	fi
}
function ask_install_java7 {
    echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu precise main" | tee -a /etc/apt/sources.list ; echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu precise main" | tee -a /etc/apt/sources.list ; apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886 ; apt-get update ; apt-get --force-yes -y -q install oracle-java7-installer
}
echo
echo
echo "     *** Mr.Hosting script for installing Multicraft ***"
echo
echo
ask_root_pass
ask_install_reps
ask_install_lamp
ask_install_java7
wget http://www.multicraft.org/download?arch=linux64 -O multicraft.tar.gz ; tar xvzf multicraft.tar.gz ; cd multicraft
#!/bin/bash
#/**
# *
# *   Copyright © 2010-2012 by xhost.ch GmbH
# *
# *   All rights reserved.
# *
# **/
CFG_FILE="setup.config"
### Function definitions
function ask {
    if [ ! "`eval echo \\$$1`" = "" ]; then
        var="`eval echo \\$$1`"
        eval echo $4
        return
    fi
    def=$2
    eval read -p '"'$3' "'
    if [ "$REPLY" = "" ]; then
        export eval $1="$def"
    else
        export eval $1="$REPLY"
    fi
}
function askSave {
    read -p "Save entered settings? ([y]/n) "
    if [ "$REPLY" != "n" ]; then
        save
    fi
}
function save {
    echo "Saving settings to '$CFG_FILE'."
    export | grep ' MC_'  > $CFG_FILE
    echo
}
function quit {
    askSave
    exit
}
function sigQuit {
    echo
    quit
}
trap sigQuit SIGINT SIGTERM
INSTALL="bin/ jar/ launcher/ scripts/ eula.txt multicraft.conf.dist"
for i in $INSTALL; do
    if [ ! -e "$i" ]; then
        echo "Error: Can't find '$i'! This script needs to be started from inside the Multicraft package directory."
        echo "Aborting setup."
        quit
    fi
done
echo
echo "***"
echo "*** Welcome to Multicraft!"
echo "***"
echo
echo "This installer will help you get Multicraft up and running."
echo "No changes are made to the system until all of the required information has been collected."
echo
echo "NOTE: This script automates the installation as described on the Multicraft website. Use it at your own risk."
echo
echo
FILE_ARCH="64bit"
SYS_ARCH="64bit"
if [ "`uname -m | grep 'x86_64'`" = "" ]; then
    SYS_ARCH="32bit"
fi
if [ ! "$FILE_ARCH" = "$SYS_ARCH" ]; then
    echo
    echo "WARNING: It seems that the system architecture ($SYS_ARCH) does not match the package you've downloaded ($FILE_ARCH). Please download the correct version of Multicraft for your system."
    read -p "Press [Enter] to proceed anyway, Ctrl-C to abort."
fi
if [ -e "$CFG_FILE" ] ; then
    ask "LOAD_CFG" "y" "Found '$CFG_FILE', load settings from this file? [\$def]/n" "-"
    if [ "$LOAD_CFG" = "y" ]; then
        source "$CFG_FILE"
    fi
fi
ask "MC_MULTIUSER" "y" "Run each Minecraft server under its own user? (Multicraft will create system users): [\$def]/n" "Create system user for each Minecraft server: \$var"
if [ "$USER" = "root" ]; then
    def="minecraft"
else
    def="$USER"
fi
ask "MC_USER" "$def" "Run Multicraft under this user: [\$def]" "Multicraft will run as \$var"
if [ "`cat /etc/passwd | awk -F: '{ print $1 }' | grep $MC_USER`" = "" ]; then
    ask "MC_CREATE_USER" "y" "User not found. Create user '$MC_USER' on start of installation? [\$def]/n" "Create user '$MC_USER': \$var"
    if [ "$MC_CREATE_USER" != "y" ]; then
        echo "Won't create user, aborting."
        quit
    fi
    MC_USER_EXISTS="n"
else
    MC_USER_ESISTS="y"
fi
ask "MC_DIR" "/home/$MC_USER/multicraft" "Install Multicraft in: [\$def]" "Installation directory: \$var"
if [ -e "$MC_DIR" ]; then
    ask "MC_DIR_OVERWRITE" "y" "Warning: '$MC_DIR' exists! Continue installing in this directory? [\$def]/n" "Installing in existing directory: \$var"
    if [ "$MC_DIR_OVERWRITE" != "y" ]; then
        echo "Won't install in existing directory, aborting."
        quit
    fi
fi
ask "MC_KEY" "2AEF-326B-02BF-CA92" "If you have a license key you can enter it now: [\$def]" "License key: \$var"
ask "MC_DAEMON_ID" "1" "If you control multiple machines from one control panel you need to assign each daemon a unique ID (requires a Dynamic or custom license). Daemon ID? [\$def]" "Daemon ID: \$var"
echo
echo
ask "MC_LOCAL" "y" "Will the PHP frontend run on this machine? [\$def]/n" "Local front end: \$var"
IP="`ifconfig 2>/dev/null | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}' | head -n1`"
if [ "$MC_LOCAL" != "y" ]; then
    export MC_DB_TYPE="mysql"
    ask "MC_DAEMON_IP" "$IP" "IP the daemon will bind to: [\$def]" "Daemon listening on IP: \$var"
    IP="$MC_DAEMON_IP"
	MY_SCRIPT_IP="$IP"
    ask "MC_DAEMON_PORT" "25465" "Port the daemon to listen on: [\$def]" "Daemon port: \$var"
    ask "MC_DAEMON_PW" "none" "Please enter a password for connection authentication (if you don't otherwise secure the connection between the PHP frontend and the daemon) [\$def]" "Daemon connection password: \$var"
else
    W_USR="www-data"
    W_DIR="/var/www"
    if [ ! "`cat /etc/issue | grep CentOS`" = "" ]; then
        W_USR="apache"
        W_DIR="/var/www/html"
    fi
    ask "MC_WEB_USER" "$W_USR" "User of the webserver: [\$def]" "Webserver user: \$var"
    ask "MC_WEB_DIR" "$W_DIR/multicraft" "Location of the PHP frontend: [\$def]" "PHP frontend directory: \$var"
    if [ -e "$MC_WEB_DIR" ]; then
        ask "MC_WEB_DIR_OVERWRITE" "y" "Warning: '$MC_WEB_DIR' exists! Continue installing the PHP frontend in this directory? [\$def]/n" "Installing in existing PHP frontend directory: \$var"
        if [ "$MC_WEB_DIR_OVERWRITE" != "y" ]; then
            echo "Won't install in existing PHP frontend directory, aborting."
            quit
        fi
    fi
fi
echo
echo
ask "MC_FTP_SERVER" "y" "Enable builtin FTP server? [\$def]/n" "Enable builtin FTP server: \$var"
if [ "$MC_FTP_SERVER" = "y" ]; then
    ask "MC_FTP_IP" "$IP" "IP the FTP server will listen on (empty for same as daemon): [\$def]" "FTP server IP: \$var"
    ask "MC_FTP_PORT" "2121" "FTP server port: [\$def]" "FTP server port: \$var"

    ask "MC_PLUGINS" "n" "Block FTP upload of .jar files and other executables (potentially dangerous plugins)? [\$def]/n" "Block .jar and executable upload: \$var"
    echo
fi
echo
echo
ask "MC_DB_TYPE" "sqlite" "What kind of database do you want to use? [\$def]/mysql" "Database type: \$var"
if [ "$MC_DB_TYPE" = "mysql" ]; then
    echo
    echo "NOTE: This is for the daemon config, the front end has an installation routine for database configuration and initialization."
    ask "MC_DB_HOST" "127.0.0.1" "Database host: [\$def]" "Database host: \$var"
    ask "MC_DB_NAME" "multicraft_daemon" "Database name: [\$def]" "Database name: \$var"
    ask "MC_DB_USER" "root" "Database user: [\$def]" "Database user: \$var"
    ask "MC_DB_PASS" "" "Database password: [\$def]" "Database password: \$var"
    echo
elif [ "$MC_DB_TYPE" = "sqlite" ]; then
    echo
    echo "The database will be located at: '$MC_DIR/data/data.db'"
else
    echo "Unsupported database type '$MC_DB_TYPE'!"
    echo "Aborting."
    quit
fi
echo "***"
echo "*** Please use the control panel to initialize the database."
echo "***"
echo
MC_JAVA="`which java`"
MC_ZIP="`which zip`"
MC_UNZIP="`which unzip`"
if [ "$MC_JAVA" = "" ]; then
    ask "MC_JAVA" "/usr/bin/java" "Path to java program: [\$def]" "Path to java: \$var"
fi
if [ "$MC_ZIP" = "" ]; then
    ask "MC_ZIP" "/usr/bin/zip" "Path to zip program: [\$def]" "Path to zip: \$var"
fi
if [ "$MC_UNZIP" = "" ]; then
    ask "MC_UNZIP" "/usr/bin/unzip" "Path to unzip program: [\$def]" "Path to unzip: \$var"
fi
if [ "$MC_MULTIUSER" = "y" ]; then
    MC_USERADD="`which useradd`"
    MC_GROUPADD="`which groupadd`"
    MC_USERDEL="`which userdel`"
    MC_GROUPDEL="`which groupdel`"
    if [ "$MC_USERADD" = "" ]; then
        ask "MC_USERADD" "/usr/sbin/useradd" "Path to useradd program: [\$def]" "Path to useradd program: \$var"
    fi
    if [ "$MC_GROUPADD" = "" ]; then
        ask "MC_GROUPADD" "/usr/sbin/groupadd" "Path to groupadd program: [\$def]" "Path to groupadd program: \$var"
    fi
    if [ "$MC_USERDEL" = "" ]; then
        ask "MC_USERDEL" "/usr/sbin/userdel" "Path to userdel program: [\$def]" "Path to userdel program: \$var"
    fi
    if [ "$MC_GROUPDEL" = "" ]; then
        ask "MC_GROUPDEL" "/usr/sbin/groupdel" "Path to groupdel program: [\$def]" "Path to groupdel program: \$var"
    fi
fi
echo
echo "NOTE: Any running daemon will be stopped!"
ask "START_INSTALL" "y" "Ready to install Multicraft. Start installation? [\$def]/n" "-"
if [ "$START_INSTALL" != "y" ]; then
    echo "Not installing."
    quit
fi
echo
echo "***"
echo "*** INSTALLING"
echo "***"
echo
if [ -e "$MC_DIR/bin/multicraft" ]; then
    echo "Stopping daemon if running..."
    "$MC_DIR/bin/multicraft" -v stop
    echo "done."
    sleep 1
fi
if [ "$MC_USER_EXISTS" = "n" ]; then
    echo
    echo "Creating user '$MC_USER'"
    adduser "$MC_USER" --gecos "" --disabled-login --quiet
    if [ ! "$?" = "0" ]; then
        echo "Creating the user failed, trying with different parameters..."
        adduser "$MC_USER"
    fi
    if [ ! "$?" = "0" ]; then
        echo "Error: Can't create user '$MC_USER'! Please create this user manually and re-run the setup script."
    fi
fi
echo
echo "Creating directory '$MC_DIR'"
mkdir -p "$MC_DIR"
echo
echo "Ensuring the home directory exists and is owned and writable by the user"
MC_HOME="`grep "^$MC_USER:" /etc/passwd | awk -F":" '{print $6}'`"
mkdir -p "$MC_HOME"
chown "$MC_USER":"$MC_USER" "$MC_HOME"
chmod u+rwx "$MC_HOME"
chmod go+x "$MC_HOME"
echo
if [ -e "$MC_DIR/bin" -a "$( cd "bin/" && pwd )" != "$( cd "$MC_DIR/bin" 2>/dev/null && pwd )" ]; then
    mv "$MC_DIR/bin" "$MC_DIR/bin.bak"
fi
for i in $INSTALL; do
    echo "Installing '$i' to '$MC_DIR/'"
    cp -a "$i" "$MC_DIR/"
done
rm -f "$MC_DIR/bin/_weakref.so"
rm -f "$MC_DIR/bin/collections.so"
rm -f "$MC_DIR/bin/libpython2.5.so.1.0"
rm -f "$MC_DIR/bin/"*-py2.5*.egg
if [ "$MC_KEY" != "no" ]; then
    echo
    echo "Installing license key"
    echo "$MC_KEY" > "$MC_DIR/multicraft.key"
fi
echo
CFG="$MC_DIR/multicraft.conf"
if [ -e "$CFG" ]; then
    ask "OVERWRITE_CONF" "n" "The 'multicraft.conf' file already exists, overwrite? y/[\$def]" "-"
fi
if [ "$MC_DB_TYPE" = "mysql" ]; then
    DB_STR="mysql:host=$MC_DB_HOST;dbname=$MC_DB_NAME"
fi
function repl {
    sed -i 's,^\s*#\?\s*'"$1"'\s*=\s*.*$,'"$1"' = '"`echo $2 | sed "s/'/\\'/"`"',' "$CFG"
}
if [ ! -e "$CFG" -o "$OVERWRITE_CONF" = "y" ]; then
    if [ -e "$CFG" ]; then
        echo "Multicraft.conf exists, backing up..."
        cp -a "$CFG" "$CFG.bak"
    fi
    echo "Generating 'multicraft.conf'"
    cp -a "$CFG.dist" "$CFG"
    repl "java" "$MC_JAVA"
    repl "command" "$MC_ZIP"' -qr "{WORLD}-tmp.zip" . -i "{WORLD}"*/*'
    repl "unpackCmd" "$MC_UNZIP"' -quo "{FILE}"'
    if [ "$MC_MULTIUSER" = "y" ]; then
        repl "multiuser" "true"
        repl "addUser" "$MC_USERADD"' -c "Multicraft Server {ID}" -d "{DIR}" -g "{GROUP}" -s /bin/false "{USER}"'
        repl "addGroup" "$MC_GROUPADD"' "{GROUP}"'
        repl "delUser" "$MC_USERDEL"' "{USER}"'
        repl "delGroup" "$MC_GROUPDEL"' "{GROUP}"'
    fi
    repl "user" "$MC_USER"
    if [ "$MC_LOCAL" != "y" ]; then
        repl "ip" "$MC_DAEMON_IP"
        repl "port" "$MC_DAEMON_PORT"
        repl "password" "$MC_DAEMON_PW"
    fi
    repl "id" "$MC_DAEMON_ID"
    if [ "$MC_DB_TYPE" = "mysql" ]; then
        repl "database" "$DB_STR"
        repl "dbUser" "$MC_DB_USER"
        repl "dbPassword" "$MC_DB_PASS"
        repl "webUser" ""
    else
        repl "webUser" "$MC_WEB_USER"
    fi
    repl "baseDir" "$MC_DIR" 
    if [ "$MC_FTP_SERVER" = "y" ]; then
        repl "enabled" "true"
        repl "ftpIp" "$MC_FTP_IP"
        repl "ftpPort" "$MC_FTP_PORT"
    else
        repl "enabled" "false"
    fi

    if [ "$MC_PLUGINS" = "n" ]; then
        repl "forbiddenFiles" ""
    fi
fi
echo
echo "Setting owner of '$MC_DIR' to '$MC_USER'"
chown "$MC_USER":"$MC_USER" "$MC_DIR"
chown -R "$MC_USER":"$MC_USER" "$MC_DIR/bin"
chown -R "$MC_USER":"$MC_USER" "$MC_DIR/launcher"
chmod 555 "$MC_DIR/launcher/launcher"
chown -R "$MC_USER":"$MC_USER" "$MC_DIR/jar"
chown -R "$MC_USER":"$MC_USER" "$MC_DIR/scripts"
echo "Setting special file permissions"
if [ "$MC_MULTIUSER" = "y" ]; then
    chown 0:"$MC_USER" "$MC_DIR/bin/useragent"
    chmod 4550 "$MC_DIR/bin/useragent"
fi
chmod 755 "$MC_DIR/jar/"*.jar 2> /dev/null
if [ "$MC_LOCAL" = "y" ]; then
    echo
    if [ -e "$MC_WEB_DIR" -a -e "$MC_WEB_DIR/protected/data/data.db" ]; then
        echo "Web directory exists, backing up protected/data/data.db"
        cp -a "$MC_WEB_DIR/protected/data/data.db" "$MC_WEB_DIR/protected/data/data.db.bak"
    fi
    echo "Creating directory '$MC_WEB_DIR'"
    mkdir -p "$MC_WEB_DIR"
    echo "Installing PHP frontend files from 'panel/' to '$MC_WEB_DIR'"
    cp -a panel/* "$MC_WEB_DIR"
    cp -a panel/.ht* "$MC_WEB_DIR"
    echo "Setting owner of '$MC_WEB_DIR' to '$MC_WEB_USER'"
    chown -R "$MC_WEB_USER":"$MC_WEB_USER" "$MC_WEB_DIR"
else
    echo
    echo "* NOTE: The PHP frontend will not be installed on this machine. Please put the contents of the directory 'panel/' in the www root of the machine you want to run the PHP frontend on and run the installer (install.php)."
fi
echo "Temporarily starting daemon to set DB permissions."
"$MC_DIR/bin/multicraft" -v set_permissions
echo
echo
echo "***"
echo "*** Installation complete!"
echo "***"
echo "***"
echo
echo "PLEASE READ:"
echo
echo "Before starting the daemon you need to run the control panel installer to initialize your database. (example: http://your.address/multicraft/install.php)"
echo
echo "The daemon WILL NOT work correctly as long as the database hasn't been initialized."
echo
echo
echo "After running the control panel installer start the daemon using the following command:"
echo "$MC_DIR/bin/multicraft -v start"
echo
echo
echo "If there are any issues, please check the log file: '$MC_DIR/multicraft.log'"
echo
echo
echo "After reading the instructions above, press [Enter] to continue."
echo
echo
echo "In case you want to rerun this script you can save the entered settings."
/home/minecraft/multicraft/bin/multicraft -v start
echo '/home/minecraft/multicraft/bin/multicraft -v start' | cat - /etc/rc.local > temp && mv temp /etc/rc.local
echo
echo "    Installing phpMyAdmin"
echo
cd /var/www ; wget http://dl.dropbox.com/u/13248852/rwm/myadmin.zip ; unzip myadmin.zip ; mv phpMyAdmin-3.5.5-all-languages myadmin ; rm myadmin.zip
echo
echo "    Installing Multicraft russian translations"
echo
cd /var/www/multicraft ; wget http://multicraft.org/files/translation/multicraft-translation-ru.zip ; unzip multicraft-translation-ru.zip ; rm multicraft-translation-ru.zip
echo
echo "    Installing craftbukkit"
echo
su - minecraft -c "cd /home/minecraft/multicraft/jar ; wget -c "http://32225.selcdn.ru/links/craftbukkit-1.4.7-R0.1.jar" -O craftbukkit.jar"
echo
echo
echo
echo "    *** Installed data ***"
echo
echo "       *** MULTICRAFT ***"
echo "    Multicraft URL: http://$IP/multicraft"
echo "    Login: admin"
echo "    Password: $MY_ROOT_PASSWORD"
echo
echo "       *** FTP ***"
echo "    Host: $IP"
echo "    Port: 2121"
echo "    Login: admin.1"
echo "    Password: $MY_ROOT_PASSWORD"
echo
echo "       *** MySQL ***"
echo "    Host: localhost"
echo "    Login: root"
echo "    Password: $MY_ROOT_PASSWORD"
echo "    phpMyAdmin: http://$IP/myadmin" 
quit



