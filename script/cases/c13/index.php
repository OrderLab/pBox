<?php

  if( $_GET["arg"] ) {
    usleep(3000000); // 3s
    echo "arg is ". $_GET['arg']. "<br />";
    exit();
  }

  echo phpinfo();
?>
