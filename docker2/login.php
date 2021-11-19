<?php

        include 'endpoint.php';
        $servername=$endpoint;
        $username=$username;
        $password=$password;
        $dbname =$dbname;
        $db = mysqli_connect($servername, $username, $password, $dbname);
        if (!$db) {
        die("Connection failed: " . mysqli_connect_error());
        }
        echo "Database Connected successfully ";


        // REGISTER USER
        if(isset($_POST["login"]))
        {
                // receive all input values from the form
                $email = $_POST['email'];
                $password = $_POST['password'];

                $query = "SELECT * FROM `login` WHERE `email`='$email' and `password`='$password'";
                $result = mysqli_query($db, $query);


                $count = mysqli_num_rows($result);

                if($count == 1)
                {
         $_SESSION['email'] = $email;
         echo '<script type="text/javascript">alert("LOGIN Successful...!");</script>';
                 }
                 else
                 {
						header("refresh:0; url=$alb1");
                        echo '<script type="text/javascript">alert("Your Login Name or Password is invalid");</script>';
                 }

                mysqli_close($db);
                }

 ?>
 
 
 
 <!DOCTYPE html>
<html lang="en" >
<head>
  <meta charset="UTF-8">
  <title>Animated Login Page</title>
  <link href="https://fonts.googleapis.com/css?family=Rubik&display=swap" rel="stylesheet">
<link rel="stylesheet" href="style.css">
</head>
<style>
* {
  box-sizing: border-box;
}
body {
  font-family: 'Rubik', sans-serif;
  margin: 0;
  padding: 0;
}
.container {
  display: flex;
  height: 100vh;
}
.left-section {
  overflow: hidden;
  display: flex;
  flex-wrap: wrap;
  flex-direction: column;
  justify-content: center;
  -webkit-animation-name: left-section;
          animation-name: left-section;
  -webkit-animation-duration: 1s;
          animation-duration: 1s;
  -webkit-animation-fill-mode: both;
          animation-fill-mode: both;
  -webkit-animation-delay: 1s;
          animation-delay: 1s;
}
.header > h1 {
  text-align: center;
  color: #f50629;
}

.animation {
  -webkit-animation-name: move;
          animation-name: move;
  -webkit-animation-duration: .4s;
          animation-duration: .4s;
  -webkit-animation-fill-mode: both;
          animation-fill-mode: both;
  -webkit-animation-delay: 2s;
          animation-delay: 2s;
}

.a1 {
  -webkit-animation-delay: 2s;
          animation-delay: 2s;
}
@keyframes move {
  0% {
    opacity: 0;
    visibility: hidden;
    -webkit-transform: translateY(-40px);
            transform: translateY(-40px);
  }
  100% {
    opacity: 1;
    visibility: visible;
    -webkit-transform: translateY(0);
            transform: translateY(0);
  }
}
@keyframes left-section {
  0% {
    opacity: 0;
    width: 0;
  }
  100% {
    opacity: 1;
    width: 100%;
  }
}
</style>
<body>

<div class="container">
  <div class="left-section">
    <div class="header">
      <h1 class="animation a1">Welcome to AppServer "<?php echo $email; ?>"!</h1>
    </div>
</div>
</div>
</body>
</html>