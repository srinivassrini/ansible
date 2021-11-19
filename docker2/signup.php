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

<?php
    include 'endpoint.php';
	$url=$alb1_login;
?>
<b1> App Server</b1>

<body>


<form action="<?=$url?>" method="post">

      <button class="animation a6" name="save">Login</button>

</form>


</body>
</html>
