<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>Calculator App</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;600&display=swap" rel="stylesheet">
    <style>
        body {
            font-family: 'Poppins', sans-serif;
            margin: 0;
            padding: 20px;
            background-color: #f5f5f5;
            color: #333;
        }

        .container {
            max-width: 800px;
            margin: 0 auto;
            background: #fff;
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        }

        h1 {
            color: #0275d8;
            text-align: center;
            font-weight: 600;
        }

        p {
            font-size: 1.1rem;
            line-height: 1.6;
        }

        .features {
            list-style: none;
            padding: 0;
        }

        .features li {
            padding: 10px 0;
            border-bottom: 1px solid #ddd;
        }

        .features li:last-child {
            border-bottom: none;
        }

        .icon {
            margin-right: 10px;
            color: #0275d8;
        }

        .buttons {
            text-align: center;
            margin-top: 20px;
        }

        .button {
            display: inline-block;
            padding: 10px 20px;
            background-color: #0275d8;
            color: #fff;
            border-radius: 5px;
            text-decoration: none;
            font-weight: 600;
        }

        .button:hover {
            background-color: #025aa5;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Calculator App</h1>
        <p>Welcome to the official repository of the <strong>Calculator App</strong>. This app provides a variety of financial and business calculators such as EMI, loan, tax, and real estate calculators. Designed for a seamless and intuitive user experience.</p>

        <h2>Key Features:</h2>
        <ul class="features">
            <li><span class="icon">✔</span> Over 35 types of calculators, including EMI, business, and finance</li>
            <li><span class="icon">✔</span> Professionally designed user interface with animations</li>
            <li><span class="icon">✔</span> Real-time calculation results</li>
            <li><span class="icon">✔</span> Multi-language and currency support</li>
            <li><span class="icon">✔</span> Lightweight and fast performance</li>
        </ul>

        <div class="buttons">
            <a href="#" class="button">Get the App</a>
            <a href="#" class="button">Documentation</a>
        </div>
    </div>
</body>
</html>
