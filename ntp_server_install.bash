#!/bin/bash

# Horodatage
current_date=$(date '+%Y-%m-%d')

# Emplacement du fichier log
LOG_FILE="/var/log/ntp_setup.log"

# Emplacement du fichier de configuration NTP
NTP_CONF_FILE="/etc/ntpsec/ntp.conf"

# Emplacement du fichier de sauvegarde 
NTP_BACKUP_DIR="/etc/ntp_backup"

# Fonction pour la gestion des erreurs
function log_error {
    local MESSAGE="$1"
    local TIMESTAMP=$(date +'%Y-%m-%d %H:%M:%S')
    echo "ERREUR [$TIMESTAMP]: $MESSAGE" >&2
    echo "ERREUR [$TIMESTAMP]: $MESSAGE" >> "$LOG_FILE"
    exit 1
}

# Vérification des privilèges de l'utilisateur
check_root_user() {
  if [[ $EUID -ne 0 ]]; then
    log_error "Ce script doit être exécuté en tant que root."
  else 
    echo "L'utilisateur connecté est bien root." | tee -a "$LOG_FILE"
  fi
}

# Vérification si le serveur NTP est déjà installé
check_ntp_installed() {
  dpkg -s ntpsec ntpdate > /dev/null 2>&1
}

# Installation du serveur NTP
install_ntp() {
  echo "Installation du serveur NTP en cours..." | tee -a "$LOG_FILE"
  apt-get -y update > /dev/null
  apt-get -y install ntpsec ntpdate > /dev/null
}

# Vérification de la réussite de l'installation de NTP
check_ntp_installation_success() {
  echo "Vérification de l'installation du serveur NTP..." | tee -a "$LOG_FILE"
  if dpkg -s ntpsec > /dev/null 2>&1; then
    echo "L'installation du serveur NTP a réussi." | tee -a "$LOG_FILE"
  else
    log_error "L'installation du serveur NTP a échoué."
  fi
}

# Configuration du fichier de conf NTP avec les serveurs FR
configure_ntp() {
  echo "Configuration du fichier ntp.conf en cours..." | tee -a "$LOG_FILE"
  if grep -i "pool 0.debian.pool.ntp.org iburst" $NTP_CONF_FILE > /dev/null; then
      echo "Le serveur NTP utilise le pool NTP Debian 00."| tee -a "$LOG_FILE"
      echo "Ajout du serveur de temps NTP français 00 en cours..."| tee -a "$LOG_FILE"
      sed -i "s/pool 0.debian.pool.ntp.org iburst/server 0.fr.pool.ntp.org/g" $NTP_CONF_FILE
  elif grep -v '^ *#' $NTP_CONF_FILE | grep -i "server 0.fr.pool.ntp.org" > /dev/null; then
      echo "Le serveur NTP utilise bien le pool NTP FR 00." | tee -a "$LOG_FILE"
  else    
      log_error "La configuration du paramètre a échoué."
  fi

  if grep -i "pool 1.debian.pool.ntp.org iburst" $NTP_CONF_FILE > /dev/null; then
      echo "Le serveur NTP utilise le pool NTP Debian 01." | tee -a "$LOG_FILE"
      echo "Ajout du serveur de temps NTP français 01 en cours..." | tee -a "$LOG_FILE"
      sed -i "s/pool 1.debian.pool.ntp.org iburst/server 1.fr.pool.ntp.org/g" $NTP_CONF_FILE
  elif grep -v '^ *#' $NTP_CONF_FILE | grep -i "server 1.fr.pool.ntp.org" > /dev/null; then
      echo "Le serveur NTP utilise bien le pool NTP FR 01." | tee -a "$LOG_FILE"
  else
      log_error "La configuration du paramètre a échoué."    
  fi
  
  if grep -i "pool 2.debian.pool.ntp.org iburst" $NTP_CONF_FILE > /dev/null; then
      echo "Le serveur NTP utilise le pool NTP Debian 02." | tee -a "$LOG_FILE"
      echo "Ajout du serveur de temps NTP français 02 en cours..." | tee -a "$LOG_FILE"
      sed -i "s/pool 2.debian.pool.ntp.org iburst/server 2.fr.pool.ntp.org/g" $NTP_CONF_FILE
  elif grep -v '^ *#' $NTP_CONF_FILE | grep -i "server 2.fr.pool.ntp.org" > /dev/null; then
      echo "Le serveur NTP utilise bien le pool NTP FR 02." | tee -a "$LOG_FILE"
  else
      log_error "La configuration du paramètre a échoué."
  fi

  if grep -i "pool 3.debian.pool.ntp.org iburst" $NTP_CONF_FILE > /dev/null; then
      echo "Le serveur NTP utilise le pool NTP Debian 03." | tee -a "$LOG_FILE"
      echo "Ajout du serveur de temps NTP français 03 en cours..." | tee -a "$LOG_FILE"
      sed -i "s/pool 3.debian.pool.ntp.org iburst/server 3.fr.pool.ntp.org/g" $NTP_CONF_FILE
  elif grep -v '^ *#' $NTP_CONF_FILE | grep -i "server 3.fr.pool.ntp.org" > /dev/null; then
      echo "Le serveur NTP utilise bien le pool NTP FR 03." | tee -a "$LOG_FILE"
  else
      log_error "La configuration du paramètre a échouée."
  fi 
  echo "Configuration du fichier ntp.conf terminée." | tee -a "$LOG_FILE"
}

# Vérification de la connectivité au serveur NTP
check_ntp_connectivity() {
  echo "Vérification de la connectivité au serveur NTP..." | tee -a "$LOG_FILE"
  if ! ntpdate -q 0.fr.pool.ntp.org > /dev/null; then
    log_error "Impossible de joindre le serveur NTP."
  else
    echo "La connectivité au serveur NTP est fonctionnelle." | tee -a "$LOG_FILE"
  fi
}

# Activation du NTP au démarrage du système
enable_ntp_at_startup() {
  echo "Activation du service NTP au démarrage du système..." | tee -a "$LOG_FILE"
  systemctl enable ntpsec 2> /dev/null
}

# Vérification de l'activation du NTP
check_ntp_enabled() {
  echo "Vérification de l'activation du service NTP..." | tee -a "$LOG_FILE"
  if ! systemctl is-enabled ntpsec > /dev/null; then
    log_error "Le service NTP n'est pas activé au démarrage du système."
  else
    echo "Le service NTP a bien été activé au démarrage du système." | tee -a "$LOG_FILE"
  fi
}

# Redémarrage du service NTP
restart_ntp_service() {
  echo "Redémarrage du service NTP..." | tee -a "$LOG_FILE"
  systemctl restart ntpsec > /dev/null
}

# Vérification du redémarrage du service NTP
check_ntp_service_status() {
  echo "Vérification du redémarrage du service NTP en cours..." | tee -a "$LOG_FILE"
  if ! systemctl is-active ntpsec > /dev/null; then
    log_error "Le service NTP n'a pas redémarré correctement."
  else
    echo "Le service NTP a bien redémarré." | tee -a "$LOG_FILE"
  fi
}

# Sauvegarde du fichier de configuration avec horodatage
backup_ntp_config() {
  if [ -f "$NTP_BACKUP_DIR/ntp.conf_$current_date.bak" ]; then
    echo "Le fichier de sauvegarde existe déjà." | tee -a "$LOG_FILE"
  else
    echo "Sauvegarde du fichier de configuration..." | tee -a "$LOG_FILE"
    mkdir -p "$NTP_BACKUP_DIR" > /dev/null
    cp "$NTP_CONF_FILE" "$NTP_BACKUP_DIR/ntp.conf_${current_date}.bak" > /dev/null
    echo "Vérification de la sauvegarde..." | tee -a "$LOG_FILE"
    if [ -f "$NTP_BACKUP_DIR/ntp.conf_$current_date.bak" ]; then
      echo "La sauvegarde a réussi." | tee -a "$LOG_FILE"
    else
    log_error "La sauvegarde a échoué."
    fi
  fi
}

# Vérification si l'utilisateur est root
check_root_user

# Vérification si le serveur NTP est déjà installé avant de lancer une nouvelle installation
if check_ntp_installed; then
  echo "Le serveur NTP est déjà installé." | tee -a "$LOG_FILE"
  exit 0
else
  echo "Installation du serveur NTP en cours..." | tee -a "$LOG_FILE"
  install_ntp
fi

check_ntp_installation_success
backup_ntp_config
configure_ntp
check_ntp_connectivity
enable_ntp_at_startup
check_ntp_enabled
restart_ntp_service
check_ntp_service_status

# Message de fin de script
echo "L'Installation et la Configuration du serveur NTP est terminée." | tee -a "$LOG_FILE"

exit 0
