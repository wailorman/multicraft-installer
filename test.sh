#!/bin/bash


  # //-a --all - Установить всё
  # -r --repos - Не устанавливать репозитории
  # -l --lamp - Не устанавливать LAMP
  # -rp --root-pass <ПАРОЛЬ> - Root пароль
  # -j --java - Не устанавливать Java
  # -m --mysql-pass - Не менять пароль root MySQL
  # -aс --apache-conf - Не добавлять конфиг апача
  # -pma - Не устанавливать phpMyAdmin

  for i in $* ; do
    
    #Помощь
    if [ "$i" = "--help" ]; then
      echo -e "\t-r --repos - Do not write repos to sources.list"
      echo -e "\t-l --lamp - Do not install LAMP"
      echo -e "\t-rp --root-pass <PASSWORD> - Password for Multicraft < !!!"
      echo -e "\t-j --java - Do not install Java"
      echo -e "\t-m --mysql-pass - Do not change MySQL root password"
      echo -e "\t-aс --apache-conf - Do not add Apache conf"
      echo -e "\t-pma - Do not install phpMyAdmin"
      exit
    fi
    
    #Проверка, ввел ли юзер рутовый пароль
    if [ "$i" = "-p" -o "$1" = "--root-pass" ]; then
      attr_root_pass="$2"
    fi
    
    
    if [ "$i" = "-r" -o "$i" = "--repos" ]; then
      #Не устанавливаем репозитории
      attr_install_repos="off"
    else
      attr_install_repos="on"
    fi
    
    if [ "$i" = "-l" -o "$i" = "--lamp" ]; then
      #Не устанавливаем LAMP
      attr_install_lamp="off"
    else
      attr_install_lamp="on"
    fi
    
    if [ "$i" = "-j" -o "$i" = "--java" ]; then
      #Не устанавливаем Java
      attr_install_java="off"
    else
      attr_install_java="on"
    fi
    
    if [ "$i" = "-m" -o "$i" = "--mysql-pass" ]; then
      #Не меняем пароль root у MySQL
      attr_install_mysql="off"
    else
      attr_install_mysql="on"
    fi
    
    if [ "$i" = "ac" -o "$i" = "--apache-conf" ]; then
      #Не устанавливаем Apache conf
      attr_install_apache="off"
    else
      attr_install_apache="on"
    fi
    
    if [ "$i" = "-pma" ]; then
      #Не устанавливаем PMA
      attr_install_pma="off"
    else
      attr_install_pma="on"
    fi
    
  done
  
  echo -e "And so..."
  echo -e "\tRoot password: ${attr_root_pass}"
  echo -e "\t[${attr_install_repos}] \t Repositories"
  echo -e "\t[${attr_install_lamp}] \t LAMP"
  echo -e "\t[${attr_install_java}] \t Java"
  echo -e "\t[${attr_install_mysql}] \t Change root MySQL"
  echo -e "\t[${attr_install_apache}] \t Apache conf"
  echo -e "\t[${attr_install_pma}] \t phpMyAdmin"

  read -p "Does this information correct? [Y]/n : "
  if [ "$REPLY" = "n" ]; then
		exit;
	fi
  
  echo "Done!"