print_exit() {
    printf "\n${1}\n"
    exit 1
}

get_user_input() {
    # Ask the user for input, lower case it, and assign it to a supplied variable
    #  $1 is the question to send to the users terminal
    #  $2 is the default response if the user only presses return
    #  $3 is the timeout for the question (will exit on timeout)
    #  $4 is the variable that stores the response for retrieval outside this func
    # Requires function print_exit()
    read -t "$3" -p "$1" var || print_exit "Timeout occured"
    var=${var:-$2}
    var=$(echo ${var} | tr '[:upper:]' '[:lower:]')
    eval $4=$var

    # Sample usage:
    #  response=
    #  get_user_input "Proceed with HDD erase? [Y|n]: " "Y" 5 response
    #  echo $response
    
}

response=
get_user_input "Proceed with HDD erase? [Y|n]: " "y" 5 response
echo $response
