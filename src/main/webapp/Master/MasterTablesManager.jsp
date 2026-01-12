<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<title>Master Tables Manager</title>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

<style>
body {
    font-family: Segoe UI, Arial;
    background: #eef0ff;
    margin: 0;
    padding: 30px;
}

h1 {
    margin-bottom: 25px;
}

#cards-container {
    display: flex;
    gap: 25px;
    flex-wrap: wrap;
}

.master-card {
    width: 260px;
    height: 150px;
    background: linear-gradient(135deg, #5aa2ff, #3c7be0);
    border-radius: 22px;
    padding: 25px;
    color: white;
    cursor: pointer;
    box-shadow: 0 10px 20px rgba(0,0,0,0.15);
}

.master-card:hover {
    transform: translateY(-5px);
}

.card-title {
    font-size: 18px;
    font-weight: 600;
}

.card-text {
    margin-top: 30px;
    font-size: 22px;
    font-weight: bold;
}
</style>
</head>

<body>

<h1>Master Tables Manager</h1>

<div id="cards-container"></div>

<script>
$(document).ready(function () {

    $.ajax({
        url: "getMasters",
        type: "GET",
        success: function (data) {

            let container = $("#cards-container");
            container.empty();

            if (data.length === 0) {
                container.append("<h3>No master tables found</h3>");
                return;
            }

            data.forEach(row => {
                let card = $(`
                    <div class="master-card">
                        <div class="card-title">${row.DESCRIPTION}</div>
                        <div class="card-text">Click to open</div>
                    </div>
                `);

                card.click(() => {
                    alert("Open table: " + row.TABLE_NAME);
                });

                container.append(card);
            });
        },
        error: function () {
            alert("ERROR: getMasters servlet not working");
        }
    });

});
</script>

</body>
</html>
