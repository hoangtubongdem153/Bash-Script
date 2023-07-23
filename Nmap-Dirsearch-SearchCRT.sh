#!/bin/bash
#Thực hiện scanning port , searching directory trên một domain, searching certificate 

#Funct Nmap
nmap_scan(){
  nmap $DOMAIN > $DIRECTORY/nmap  
  echo "The results of nmap scan are stored in $DIRECTORY/nmap."
}

#Funct Dirsearch
dirsearch_scan(){
  dirsearch -u $DOMAIN -e php --simple-report=$DIRECTORY/dirsearch
  echo "The results of dirsearch scan are stored in $DIRECTORY/dirsearch."
}
#Funct crt
crt_scan(){
  curl "https://crt.sh/?q=$DOMAIN&output=json" -o $DIRECTORY/crt  
  echo "The results of cert parsing is stored in $DIRECTORY/crt."
}

getopts "m:" OPTION #Tạo option m nhận các tham số
MODE=$OPTARG

for i in "${@:$OPTIND:$#}" #Hàm duyệt nhiều các target trong command line
 do  
    DOMAIN=$i  
    DIRECTORY=${DOMAIN}_recon  
    echo "Creating directory $DIRECTORY."  
    mkdir $DIRECTORY  #Tạo direct dạng {DOMAIN}_recon
    case $MODE in  
	nmap-only)
		      nmap_scan
	              ;;    
	dirsearch-only)
		      dirsearch_scan
		      ;;    
	crt-only)
		      crt_scan
		      ;;    
	*)      
		nmap_scan      
		dirsearch_scan
	        crt_scan      
		;;       
    esac  
    echo "Generating recon report for $DOMAIN..."    
    TODAY=$(date)  
    echo "This scan was created on $TODAY" > $DIRECTORY/report    
    if [ -f $DIRECTORY/nmap ];then 
        echo "Results for Nmap:" >> $DIRECTORY/report    
	grep -E "^\s*\S+\s+\S+\s+\S+\s*$" $DIRECTORY/nmap >> $DIRECTORY/report                        fi    
    if [ -f $DIRECTORY/dirsearch ];then 
        echo "Results for Dirsearch:" >> $DIRECTORY/report    
        cat $DIRECTORY/dirsearch >> $DIRECTORY/report  
fi     
    if [ -f $DIRECTORY/crt ];then 
        echo "Results for crt.sh:" >> $DIRECTORY/report
        jq -r ".[] | .name_value" $DIRECTORY/crt >> $DIRECTORY/report  
fi  
  done