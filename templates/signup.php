<?php

        $servername="myrdsdb.cvx1xix5yaol.us-east-2.rds.amazonaws.com";
        $username="admin";
        $password="password";
        $dbname = "myrdsdb";
        $db = mysqli_connect($servername, $username, $password, $dbname);
        if (!$db) {
        die("Connection failed: " . mysqli_connect_error());
        }
        echo "Connected successfully";


        // REGISTER USER
        if(isset($_POST["save"]))
        {
                // receive all input values from the form
                $email = $_POST['email'];
                $password = $_POST['password'];
                $cpassword = $_POST['cpassword'];

                if($password == $cpassword)
                {
                        $query = "INSERT INTO `login` (`email`, `password`) VALUES ('$email', '$password')";
                        $result = mysqli_query($db, $query);

                        if($result)
                        {
                                echo '<script type="text/javascript">alert("Registration Done...!");</script>';
                                header("location: login.php");
                        }
                        else
                        {
                                echo '<script type="text/javascript">alert("Not Register!");</script>';

                        }

                        mysqli_close($db);
                }
                else
                {
                        echo '<script type="text/javascript">alert("password mismatch");</script>';
                }

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
.right-section {
  flex: 1;
  background: linear-gradient(to right, #f50629 0%, #fd9d08 100%);
  transition: 1s;
  background-image: url(https://webdevtrick.com/wp-content/uploads/login-page-image.jpg);
  background-size: cover;
  background-repeat: no-repeat;
  background-position: center;
}
.header > h1 {
  margin: 0;
  color: #f50629;
}
.header > h4 {
  margin-top: 10px;
  font-weight: normal;
  font-size: 15px;
  color: rgba(0, 0, 0, 0.4);
}
.form {
  max-width: 80%;
  display: flex;
  flex-direction: column;
}
.form > p {
  text-align: right;
}
.form > p > a {
  color: #000;
  font-size: 14px;
}
.form-field {
  height: 46px;
  padding: 0 16px;
  border: 2px solid #ddd;
  border-radius: 4px;
  font-family: 'Rubik', sans-serif;
  outline: 0;
  transition: .2s;
  margin-top: 20px;
}
.form-field:focus {
  border-color: #0f7ef1;
}
.form > button {
  padding: 12px 10px;
  border: 0;
  background: linear-gradient(to right, #f50629 0%, #fd9d08 100%);
  border-radius: 3px;
  margin-top: 10px;
  color: #fff;
  letter-spacing: 1px;
  font-family: 'Rubik', sans-serif;
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
.a2 {
  -webkit-animation-delay: 2.1s;
          animation-delay: 2.1s;
}
.a3 {
  -webkit-animation-delay: 2.2s;
          animation-delay: 2.2s;
}
.a4 {
  -webkit-animation-delay: 2.3s;
          animation-delay: 2.3s;
}
.a5 {
  -webkit-animation-delay: 2.4s;
          animation-delay: 2.4s;
}
.a6 {
  -webkit-animation-delay: 2.5s;
          animation-delay: 2.5s;
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
    padding: 20px 40px;
    width: 440px;
  }
}
</style>
<body>

<div class="container">
  <div class="left-section">
    <div class="header">
      <h1 class="animation a1">Welcome Back!</h1>
      <h4 class="animation a2">Signup from Webserver.</h4>
    </div>

<form method="post">
    <div class="form">
      <input type="email" class="form-field animation a3" name="email" placeholder="Email" required>
      <input type="password" class="form-field animation a4" name="password" placeholder="Password" required>
          <input type="password" class="form-field animation a4" name="cpassword" placeholder="Confirm Password" required>

      <button class="animation a6" name="save">SIGNUP</button>
      <button class="animation a6" ><a href="login.php">LOGIN</a></button>


    </div>
  </div>
</form>


  <div class="right-section"></div>
</div>

</body>
</html>