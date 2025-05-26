decode_password() {
  echo "SEFtemF6aURBTkUyMDA=" | base64 -d
}
